use strict;
use warnings;

use Test::More tests => 6;

use MediaWiki::Bot;
use Data::Dumper;


my $bot = MediaWiki::Bot->new({
			       protocol => 'http',
			       host => 'foodfinds.referata.com',
			       path => 'w/',
			      });



my $results1 = $bot->ask({
			  format=>'simplified',
			  query=>"[[Category:All Good Eats]] [[City::New York]]
|?Cuisine
",
});


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
