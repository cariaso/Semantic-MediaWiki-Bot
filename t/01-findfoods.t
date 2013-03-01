use strict;
use warnings;

use Test::More tests => 11;

BEGIN {
    use_ok('MediaWiki::Bot');
}
use Data::Dumper;

my $hostname = 'foodfinds.referata.com';
my $botparams = {
		 protocol => 'http',
		 host => $hostname,
		 path => 'w/',
		};

my $bot = new_ok('MediaWiki::Bot' => [$botparams]);


my $results1 = $bot->ask({
			  format=>'simplified',
			  query=>"[[Category:All Good Eats]] [[City::New York]]
|?Cuisine
",
});

ok $results1 , "got a response from $hostname";

my $num_italian = 0;
my $num_cambodian = 0;
foreach my $row (@$results1) {
  $num_italian++ if $row->{Cuisine} =~ /italian/i;
  $num_cambodian++ if $row->{Cuisine} =~ /cambodian/i;
}

ok $num_italian, "found $num_italian Italian resturants in New York";
ok $num_cambodian, "found $num_cambodian Cambodian resturants in New York";
ok $num_cambodian < $num_italian , "found more Italian resturants than Cambodian resturants in New York";







my $results_california = $bot->ask({
			  format=>'simplified',
			  query=>"[[Category:All Good Eats]] [[State::California]]
|?Cuisine
|?City
|?Price Range
",
});


my $num_mexican = 0;
my $num_french = 0;
foreach my $row (@$results_california) {

  if ($row->{_title} =~ /Chez Panisse/) {
    ok $row->{City} =~ /Berkeley/, "Chez Panisse is located in Berkeley";
  }

  if ($row->{_title} =~ /Breads of India/) {
    ok $row->{'Price Range'} =~ /cheap/i, "Breads of India is still inexpensive";
  }

  $num_mexican++ if $row->{Cuisine} =~ /mexican/i;
  $num_french++ if $row->{Cuisine} =~ /french/i;

}


ok $num_mexican > $num_french, "California has more Mexican than French resturants";



my $results_simple = $bot->ask({
			  format=>'simplified',
			  query=>"[[Category:All Good Eats]] [[City::San Francisco]]
|?Cuisine
",
});





my $simple_ppq_name = 'PPQ Dungeness Island';
my $simple_ppq_cuisine = 'default not found';
foreach my $row (@$results_simple) {
  next unless $row->{_title} =~ /$simple_ppq_name/;
  ok $row->{Cuisine} =~ /Vietnamese/i, "$simple_ppq_name is a Vietnamese resturant";
  $simple_ppq_cuisine = $row->{Cuisine};
}



my $results_complex = $bot->ask({
			  query=>"[[Category:All Good Eats]] [[City::San Francisco]]
|?Cuisine
",
});


foreach my $key (keys %{$results_complex->{query}->{results}}) {
  my $obj = $results_complex->{query}->{results}->{$key};
  next unless $obj->{fulltext} =~ /$simple_ppq_name/;

  my $foundall = 1;
  foreach my $cuisine (@{$obj->{printouts}->{Cuisine}}) {
    my $name = $cuisine->{fulltext};
    $foundall &= $simple_ppq_cuisine =~ /$name/;
  }
  ok $foundall, "simple and complex agree about the cuisines at $simple_ppq_name : ($simple_ppq_cuisine)";
}
