package Catalyst::Model::LDAP;

use strict;
use base qw/Catalyst::Base/;
use Net::LDAP;
use NEXT;

our $VERSION = '0.05';

__PACKAGE__->mk_accessors('code', 'error');

=head1 NAME

Catalyst::Model::LDAP - LDAP model class for Catalyst

=head1 SYNOPSIS

  # Use the Catalyst helper
  script/myapp_create.pl model People LDAP ldap.ufl.edu ou=People,dc=ufl,dc=edu

  # lib/MyApp/Model/People.pm
  package MyApp::Model::People;

  use base 'Catalyst::Model::LDAP';

  __PACKAGE__->config(
      host         => 'ldap.ufl.edu',
      base         => 'ou=People,dc=ufl,dc=edu',
      dn           => '',
      password     => '',
      options      => {},     # Net::LDAP method options (e.g. SASL
                              # for bind or sizelimit for search)
      cache        => undef,  # Reference to a Cache object (e.g.
                              # Cache::FastMmap) to cache results
  );

  1;

  # As object method
  $c->comp('M::People')->search('(sn=TEST)');

  # As class method
  MyApp::Model::People->search('(sn=TEST)');

=head1 DESCRIPTION

This is the L<Net::LDAP> model class for Catalyst. It is nothing more
than a simple wrapper for L<Net::LDAP>.

=head1 METHODS

=head2 new

Create a new Catalyst LDAP model component.

=cut

sub new {
    my $self = shift;

    return $self->NEXT::new(@_);
}

=head2 search

Search the directory using a given filter. Returns an arrayref
containing the matching entries (if any).

This method sets the C<code> and C<error> properties. This allows you
to check for nonfatal error conditions, such as hitting the search
time limit.

If a L<Cache> object is specified in the configuration, it is used to
store responses from the LDAP server. On subsequent searches using the
same filter, the cached response is used. (Note: The C<code> and
C<error> values are not cached.)

=cut

sub search {
    my ($self, $filter) = @_;

    my $entries = $self->_cache($filter);

    unless (defined $entries) {
        my $client = $self->_client;
        my $mesg = $client->search(
            base   => $self->config->{base},
            filter => $filter,
            %{ $self->config->{options} },
        );
        $self->code($mesg->code);
        $self->error($mesg->error);

        $entries = [ $mesg->entries ];
        $client->unbind;

        $self->_cache($filter, $entries);
    }

    return $entries;
}

=head2 _client

Return a reference to an LDAP client bound using the current
configuration. If the bind fails, the method sets the C<code> and
C<error> property and dies with the error message.

=cut

sub _client {
    my ($self) = @_;

    my $client = Net::LDAP->new(
        $self->config->{host},
        %{ $self->config->{options} }
    ) or die $@;

    my $mesg;
    if ($self->config->{dn} and $self->config->{password}) {
        $mesg = $client->bind(
            $self->config->{dn},
            password => $self->config->{password},
            %{ $self->config->{options} },
        );
    }
    elsif ($self->config->{dn} and %{ $self->config->{options} }) {
        $mesg = $client->bind(
            $self->config->{dn},
            %{ $self->config->{options} },
        );
    }
    else {
        $mesg = $client->bind;
    }

    $self->code($mesg->code);
    $self->error($mesg->error);
    die 'LDAP error: ' . $mesg->error if $mesg->is_error;

    return $client;
}

=head2 _cache

Get and set cache values, if a L<Cache> object is configured. If only
a key is specified, return the cached value, if one exists. If a value
is also given, set the value in the cache.

=cut

sub _cache {
    my ($self, $key, $value) = @_;

    my $cache = $self->config->{cache};
    return unless $cache;

    if (defined $value) {
        $cache->set($key, $value);
    }

    my $cached = $cache->get($key);

    return $cached;
}

=head1 SEE ALSO

L<Catalyst>, L<Net::LDAP>, L<Cache>

=head1 TODO

=over 4

=item *

Add other LDAP methods.

=item *

Cache the LDAP code value and error message?

=item *

Maybe move caching code to a separate class, e.g.
C<Catalyst::Model::LDAP::Cached>.

=back

=head1 AUTHOR

Daniel Westermann-Clark E<lt>danieltwc@cpan.orgE<gt>

Based on work started by E<lt>salih@ip-plus.netE<gt> on the Catalyst
mailing list:

L<http://lists.rawmode.org/pipermail/catalyst/2005-June/000712.html>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
