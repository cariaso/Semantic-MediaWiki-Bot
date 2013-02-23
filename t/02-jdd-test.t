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


my $results1 = $bot->ask({
			  query=>"[[Category:Is a genotype]] [[On chromosome::1]]
|?Allele1
|?Allele2
|?On chromosome
|limit=500",
});

my $results2 = $bot->askargs({
			      conditions=>join("|", ("Category:Is a genotype","On chromosome::3", "Allele1::T")),
			      outs=>['Allele1','Allele2','On chromosome','Summary','Magnitude'],
			      parameters=>'|limit=100000|sort=Magnitude|order=desc',
			     });
#print Dumper $results2;

print scalar keys %$results2,"\n";
#exit;
foreach my $key (keys %$results2) {
  print "$key\n";
  foreach my $field (keys %{$results2->{$key}->{printouts}}) {
    print "  $field\t",@{$results2->{$key}->{printouts}->{$field}},"\n";

  }
  #print Dumper $results2->{$key}->{printouts};
}

__END__
my $i = 0;
foreach my $key (keys %$results) {
    my ($a1, $a2) = ($results->{$key}->{printouts}->{Allele1}[0], $results->{$key}->{printouts}->{Allele2}[0]);
    my $geno = "($a1;$a2)";
    if ($key =~ /$geno/) {
#	print "Yes $i $key $a1 $a2\n";
    } else {
	print "NO  $i $key $a1 $a2\n";
    }
    $i++;
}

