use strict;
use warnings;

use Test::More tests => 15;

BEGIN {
    use_ok('MediaWiki::Bot');
}
use Data::Dumper;

my $username = $ENV{'SemanticMediaWikiBotUsername'};
my $password = $ENV{'SemanticMediaWikiBotPassword'};

ok $username, "Username is set: $username";
ok $password, "Password available";


my $hostname = 'localhost';
my $botparams = {
		 protocol => 'http',
		 host => $hostname,
		 path => '/',

		};

my $bot = new_ok('MediaWiki::Bot' => [$botparams]);


my $login = $bot->login({
		 username    => $username,
		 password    => $password,
		}) or die("unable to login");
ok $login, "Login successful";

my $title = 'Main Page';
my $text = $bot->get_text($title);
ok $text, "Read text from $title";

my $response = $bot->edit({
        page    => $title,
        text    => $text,
        summary => 'Adding null content',
    });

ok $response->{edit}->{result} eq 'Success' , "Able to null edit a page";






$title = 'Other Page';
my $beforetext = $bot->get_text($title);
my $addendum = "*More Text\n";
$text = $beforetext . $addendum;

$response = $bot->edit({
        page    => $title,
        text    => $text,
        summary => 'Adding new content',
    });

ok $response->{edit}->{result} eq 'Success' , "Able to edit a page";


$response = $bot->edit({
        page    => $title,
        text    => $beforetext,
        summary => 'restoring previous content',
    });

ok $response->{edit}->{result} eq 'Success' , "Restored previous version page";

my $aftertext = $bot->get_text($title);
ok $beforetext eq $aftertext , "Original and current versions match";




foreach my $title ('Larry',
		   'Moe',
		   'Curly') {
  $text = "[[Stooge::Yes]]\n";

  $response = $bot->edit({
			  page    => $title,
			  text    => $text,
			  summary => 'Adding new content',
			  #section => 'new',
			 });

  ok $response->{edit}->{result} eq 'Success' , "wrote $title";
}




my $results1 = $bot->ask({
			  format=>'simplified',
			  query=>"[[Stooge::+]]
|?Stooge
",
});

ok $results1 , "got a response from $hostname";

my $num_stooges = 0;
foreach my $row (@$results1) {
  $num_stooges++;
}

ok 3 == $num_stooges, "found $num_stooges stooges";


