use Test::More tests => 2;
BEGIN {push @INC, "./lib"; use_ok('MediaWiki::Bot') };

my $bot = MediaWiki::Bot->new();
$bot->set_wiki('bots.snpedia.com','/');
my $results = $bot->ask({
    conditions=>'[[Category:Is a snp]] [[On chromosome::3]] [[Repute::+]]',
    outs=>['Repute','Magnitude','Chromosome position'],
    parameters=>'limit=5'
			});

ok($results->{'Rs113169049(C;C)'}, "askargs got an expected result");
