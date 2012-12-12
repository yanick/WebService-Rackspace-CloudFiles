package WebService::Rackspace::CloudFiles::CustomLocations;

use strict;
use warnings;

use Moose;

extends 'WebService::Rackspace::CloudFiles';

my %locations = (
    au  => 'http://localhost/v1.0',
);

has '+location' => (
    default => 'au',
);

# need to overload the method here with the exact same code,
# to have it access the right %locations
sub _authenticate {
    my $self = shift;

    if ( ! exists $locations{$self->{location}} ) {
	confess "location $self->{location} unknown: valid locations are " .
		join(', ', keys %locations);
    }

    my $request = HTTP::Request->new(
        'GET',
        $locations{$self->{location}},
        [   'X-Auth-User' => $self->user,
            'X-Auth-Key'  => $self->key,
        ]
    );
    my $response = $self->_request($request);

    confess 'Unauthorized'  if $response->code == 401;
    confess 'Unknown error' if $response->code != 204;

    my $storage_url = $response->header('X-Storage-Url')
        || confess 'Missing storage url';
    my $token = $response->header('X-Auth-Token')
        || confess 'Missing auth token';
    my $cdn_management_url = $response->header('X-CDN-Management-Url')
        || confess 'Missing CDN management url';

    $self->storage_url($storage_url);
    $self->token($token);
    $self->cdn_management_url($cdn_management_url);
}

__PACKAGE__->meta->make_immutable;

1;



