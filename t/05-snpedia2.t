use strict;
use warnings;

use MediaWiki::Bot;
use Data::Dumper;

my $bot = MediaWiki::Bot->new({
			       protocol => 'http',
			       host => 'bots.snpedia.com',
			       path => '/',
			       debug=>2,
			      });


if (0) {
  my $results1 = $bot->ask({
			  query=>"[[Category:Is a genotype]] [[On chromosome::1]]
|?Allele1
|?Allele2
|?On chromosome
|limit=5",
});

  print Dumper $results1;
  exit;
}


my $results2 = $bot->askargs({
			      conditions=>join("|", ("Category:Is a genotype","On chromosome::19", "Allele1::T")),
			      outs=>['Allele1','Allele2','On chromosome','Summary','Magnitude'],
			      parameters=>'|limit=10|sort=Magnitude|order=desc',
			     });

print "Num results:",scalar keys %{$results2->{query}->{results}},"\n";

foreach my $key (@{$results2->{query}->{order}}) {
  print "$key\n";
  foreach my $field (keys %{$results2->{query}->{results}->{$key}->{printouts}}) {
    print "  $field\t",@{$results2->{query}->{results}->{$key}->{printouts}->{$field}},"\n";
  }
}



