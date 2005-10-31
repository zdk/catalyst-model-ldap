package Catalyst::Model::LDAP::Cached;

use strict;
use base qw/Catalyst::Model::LDAP/;

=head1 NAME

Catalyst::Model::LDAP::Cached - Cached LDAP model class for Catalyst

=head1 SYNOPSIS

  # lib/MyApp/Model/People.pm
  package MyApp::Model::People;

  use base 'Catalyst::Model::LDAP::Cached';

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

  # In your controller
  my $entries = $c->comp('M::People')->search('(sn=TEST)');
  print $entries->[0]->get_value('sn');

=head1 DESCRIPTION

This is the L<Net::LDAP> model class for Catalyst. It is nothing more
than a simple wrapper for L<Net::LDAP>.

=head1 METHODS

=head2 search

Search the directory using a given filter, but check the configured
cache first for a matching filter. Returns an arrayref containing the
matching L<Net::LDAP::Entry> objects (if any).

  my $entries = $c->comp('M::People')->search('(sn=TEST)');
  print $entries->[0]->get_value('sn');

=cut

sub search {
    my ($self, $filter) = @_;

    my $entries = $self->_cache($filter);
    unless ($entries) {
        $entries = $self->SUPER::search($filter);
        $self->_cache($filter, $entries);
    }

    return $entries;
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

=over 4

=item * L<Catalyst>

=item * L<Net::LDAP>

=item * L<Cache>

=item * L<Catalyst::Model::LDAP>

=back

=head1 TODO

=over 4

=item * Cache the LDAP code value and error message?

=item * Create C<Helper> class

=back

=head1 AUTHOR

Daniel Westermann-Clark E<lt>danieltwc@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
