use strict;
use warnings;

use MediaWiki::Bot;
use Data::Dumper;




my $bot = MediaWiki::Bot->new({
			       protocol => 'http',
			       host => 'rwbookclub.com',
			       path => 'w/',
			       debug=>2,
			      });


my $results2 = $bot->ask({
			  query=>"[[Category:Book]]
|?Has Amazon ASIN
|?Has rating average
|?Has rating count
|?Has short title
|?Has vote average
|sort=Has rating average
|order=desc
",
});
#|limit=5

print "Num results:",scalar keys %{$results2->{query}->{results}},"\n";

foreach my $key (@{$results2->{query}->{order}}) {
  print "$key\n";
  foreach my $field (keys %{$results2->{query}->{results}->{$key}->{printouts}}) {
    my $val = $results2->{query}->{results}->{$key}->{printouts}->{$field}->[0];
    if (ref($val)) {
      #print Dumper $val;
      print "  $field\t",$results2->{query}->{results}->{$key}->{printouts}->{$field}->[0]->{fulltext},"\n";
    } else {
      print "  $field\t",@{$results2->{query}->{results}->{$key}->{printouts}->{$field}},"\n";
    }
  }
}



