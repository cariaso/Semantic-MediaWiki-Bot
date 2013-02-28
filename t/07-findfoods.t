use strict;
use warnings;

use MediaWiki::Bot;
use Data::Dumper;


sub showResponse {
  my $results1 = shift;

  print "Num results:",scalar keys %{$results1->{query}->{results}},"\n";

  foreach my $key  (@{$results1->{query}->{order}}) {
    print "$key\n";				  
    foreach my $field (keys %{$results1->{query}->{results}->{$key}->{printouts}}) {
      my $val = $results1->{query}->{results}->{$key}->{printouts}->{$field}->[0];
      if (ref($val)) {
	print "  $field\t",$results1->{query}->{results}->{$key}->{printouts}->{$field}->[0]->{fulltext},"\n";
      } else {
	print "  $field\t",@{$results1->{query}->{results}->{$key}->{printouts}->{$field}},"\n";
      }
    }
  }
}




my $bot = MediaWiki::Bot->new({
			       protocol => 'http',
			       host => 'foodfinds.referata.com',
			       path => 'w/',
			       debug=>2,
			      });



my $results1 = $bot->ask({
			  query=>"[[Category:All Good Eats]] [[City::New York]]
|?Cuisine
",
});


showResponse($results1);








