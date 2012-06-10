use strict;
use warnings;
use Test::More tests => 4;
BEGIN {
    use_ok('MediaWiki::Bot');
}

my $bot = new_ok('MediaWiki::Bot' => [{ host => 'bots.snpedia.com', path => '/' }]);
can_ok($bot, qw(ask askargs));

my $results = $bot->askargs({
    conditions  => '[[Category:Is a snp]] [[On chromosome::3]] [[Repute::+]]',
    outs        => ['Repute','Magnitude','Chromosome position'],
    parameters  => 'limit=5'
});

ok $results->{'Rs113169049(C;C)'}, 'askargs got an expected result';
