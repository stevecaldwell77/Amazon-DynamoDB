package Amazon::DynamoDB::MojoUA;

use strict;
use warnings;

=head1 NAME

Amazon::DynamoDB::MojoUA - make requests using L<Mojo::UserAgent>

=head1 DESCRIPTION

Provides a L</request> method which will use L<LWP::UserAgent> to make
requests and return a L<Future> containing the result. Used internally by
L<Amazon::DynamoDB>.

=cut

use Future;
use Mojo::UserAgent;

=head2 new

Instantiate.

=cut

sub new { my $class = shift; bless {@_}, $class }

=head2 request

Issues the request. Expects a single L<HTTP::Request> object,
and returns a L<Future> which will resolve to the decoded
response content on success, or the failure reason on failure.

=cut

sub request {
	my $self = shift;
	my $req = shift;
	my $method = lc $req->method;
	my $tx = $self->ua->$method(''.$req->uri => { map {; $_ => ''.$req->header($_) } $req->header_field_names } => $req->content);
	if(my $res = $tx->success) {
		return Future->new->done($res->body)
	}

	my $status = $tx->res->code;
	return Future->new->fail($status, $tx->res, $req)
}

=head2 ua

Returns the L<LWP::UserAgent> instance.

=cut

sub ua { shift->{ua} ||= Mojo::UserAgent->new }

1;

