use strict;
use warnings;

use MediaWiki::Bot;
use Data::Dumper;

# still uses POST, not GET until this is fixed
# https://rt.cpan.org/Public/Bug/Display.html?id=75296

my $bot = MediaWiki::Bot->new();
$bot->set_wiki({
    protocol => 'http',
    host => 'bots.snpedia.com',
    path => '/',
});


my $results = $bot->ask({
    query=>"[[Category:Is a genotype]] [[On chromosome::1]]
|?Allele1
|?Allele2
|?On chromosome
|limit=500",
});



my $i = 0;
foreach my $key (keys %$results) {
    my ($a1, $a2, $chrom) = ($results->{$key}->{printouts}->{Allele1}[0], 
		     $results->{$key}->{printouts}->{Allele2}[0], 
		     $results->{$key}->{printouts}->{'On chromosome'}[0]);
    my $geno = "($a1;$a2)";
    if ($key =~ /$geno/) {
#	print "Yes $i $key $a1 $a2\n";
    } else {
	print "NO  $i $key $a1 $a2    $chrom\n";
    }
    $i++;
}
