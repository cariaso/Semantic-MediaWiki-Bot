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


my $results1 = $bot->ask({
    query=>"[[Category:Is a genotype]] [[On chromosome::1]]
|?Allele1
|?Allele2
|?On chromosome
|limit=500",
});



my $results2 = $bot->askargs({
    conditions=>"[[Category:Is a genotype]] [[On chromosome::1]]",
    outs=>['Allele1','Allele2','On chromosome'],
    #parameters=>'|limit=5',
});
print Dumper $results1;
print Dumper $results2;

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

