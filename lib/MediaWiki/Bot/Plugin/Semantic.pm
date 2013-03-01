package MediaWiki::Bot::Plugin::Semantic;

use strict;
use warnings;
use Carp;

use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;

our $VERSION = '0.1.1';

=head1 NAME

MediaWiki::Bot::Plugin::Semantic - a plugin for MediaWiki::Bot which interacts with Semantic MediaWiki websites

=head1 SYNOPSIS

    use strict;
    use warnings;

    use MediaWiki::Bot;
    use Data::Dumper;

    my $bot = MediaWiki::Bot->new();
    $bot->set_wiki('bots.snpedia.com','/');
    my $results = $bot->askargs({
        conditions=>'[[Category:Is a snp]] [[On chromosome::3]] [[Repute::+]]',
        outs=>['Repute','Magnitude','Chromosome position'],
                }
        );

    # parameters{limit} isn't yet respected, but that seems to be a server side issue

    my $i = 0;
    foreach my $key (keys %$results) {
        $i++;
        print "$i $key ",Dumper $results->{$key};
    }

=head1 DESCRIPTION

L<MediaWiki::Bot> is a framework that can be used to write Mediawiki
bots. MediaWiki::Bot::Plugin::Semantic can be used for data retrieval
and reporting bots related to Semantic MediaWiki.

https://github.com/cariaso/Semantic-MediaWiki-Bot

=head1 AUTHOR

Michael Cariaso

=head1 METHODS

=over 4

=item import()

Calling import from any module will, quite simply, transfer these
subroutines into that module's namespace. This is possible from any
module which is compatible with MediaWiki/Bot.pm.

=cut

sub import {
	no strict 'refs';
	foreach my $method (qw/ask askargs/) {
		*{caller() . "::$method"} = \&{$method};
	}
}

=item _get_order($self, $response)

Return the order of the results

=cut

use Data::Dumper;
sub _get_order {
    my ($self, $response) = @_;

    my $rawresponse;

    my $encoding = $self->{api}->{response}->{_headers}->{'content-encoding'} || '';
    if ($encoding eq 'gzip') {
	gunzip \$self->{api}->{response}->{_content} => \$rawresponse;
    } else {
	$rawresponse = $self->{api}->{response}->{_content};
    }

    unless ($rawresponse) {
	print "****No Raw Response? returning random ordering******\n";
	return [keys %{$self->{api}->{response}}];
    };

    my @allorderedkeys = $rawresponse =~ /"([^"]*)"\s*:\s*\{/sg;
    my @orderedkeys = ();
    my %seen = ();

    if (ref $response->{query}->{results} eq 'HASH') {
	foreach my $string (@allorderedkeys) {
	    if ($response->{query}->{results}->{$string} &&!$seen{$string}) {
		$seen{$string}++;
		push @orderedkeys, $string;
	    }
	}
    }
    return \@orderedkeys;
}


=item ask($params)

Ask the query, return the result.

Do a Dumper to consider if you prefer using the 
 format => 'simplified'

=cut

use Data::Dumper;

sub ask {
    my $self = shift;
    my $args = shift;
    croak 'query must be set' unless $args->{query};

    my $askhash = {
        action => $args->{action} || 'ask',
        query  => $args->{query},
    };

    my $smw = $self->{api};
    my $response = $self->{api}->api($askhash)
        || die $smw->{error}->{code} . ': ' . $smw->{error}->{details};


    my $order = _get_order($self, $response);
    $response->{query}->{order} = $order;

    if ($args->{format} && $args->{format} eq 'simplified') {
	return simplify($response);
    } else {

	return $response;

    }
}


=item askargs($params)

Ask the query, return the result.

alternative interface. I don't see much value in it. 

Do a Dumper to consider if you prefer using the 
 format => 'simplified'

=cut


sub askargs {
    my $self = shift;
    my $args = shift;
    croak 'conditions must be set' unless $args->{conditions};

    my $askhash = {
        action      => $args->{action} || 'askargs',
        conditions  => $args->{conditions},
        printouts   => $args->{printouts} || join('|', @{ $args->{outs} }),
        parameters  => $args->{parameters},
    };

    my $smw = $self->{api};
    my $response = $smw->api($askhash)
        || die $smw->{error}->{code} . ': ' . $smw->{error}->{details};


    my $order = _get_order($self, $response);
    $response->{query}->{order} = $order;

    if ($args->{format} && $args->{format} eq 'simplified') {
	return simplify($response);
    } else {

	return $response;

    }
}

=item simplify($results)

Turn the result of an ask() into an flatter, eaiser to work with structure. 

=cut



sub simplify {
  my $results1 = shift;
  my @out = ();
  foreach my $key  (@{$results1->{query}->{order}}) {
      my $element = {
	  _title => $key,
      };
      my $printouts = $results1->{query}->{results}->{$key}->{printouts};
      foreach my $field (keys %$printouts) {
	  my @extra;
	  foreach my $val (@{$printouts->{$field}}) {
	      my $extra;
	      if (ref($val) && exists $val->{fulltext}) {
		  $extra = $val->{fulltext};
	      } else {
		  $extra = $val;
	      }
	      push @extra, $extra;
	  }
	  $element->{$field} = join(', ',@extra);
      }
      push @out, $element;
  }
  return \@out;
}


1;
