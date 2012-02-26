                                                                                                                                                                     
use strict;
use warnings;

use MediaWiki::Bot;
use Data::Dumper;

# https://rt.cpan.org/Public/Bug/Display.html?id=75296

my $bot = MediaWiki::Bot->new();
$bot->set_wiki('bots.snpedia.com','/');


my $results = $bot->ask({
    query=>"[[Category:Is a genotype]] [[On chromosome::1]]
|?Allele1
|?Allele2
|limit=500",
			});



my $results = $bot->askargs({
    conditions=>"[[Category:Is a genotype]] [[On chromosome::1]]",
    outs=>['Allele1','Allele2'],
    #parameters=>'|limit=5',
    
			});
print Dumper $results;
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

