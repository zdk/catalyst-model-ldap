package Catalyst::Model::LDAP;

use strict;
use base qw/Catalyst::Base/;
use Carp ();
use NEXT;
use Net::LDAP;

our $VERSION = '0.07';

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
      options      => {},  # Options passed to all Net::LDAP methods
                           # (e.g. SASL for bind or sizelimit for
                           # search)
  );

  1;

  # In your controller
  my $entries = $c->comp('M::People')->search('(sn=TEST)');
  print $entries->[0]->get_value('sn');

=head1 DESCRIPTION

This is the L<Net::LDAP> model class for Catalyst. It is nothing more
than a simple wrapper for L<Net::LDAP>.

=head1 METHODS

=head2 new

Create a new Catalyst LDAP model component.

=cut

sub new {
    my ($self, $c, $config) = @_;

    $self = $self->NEXT::new($c, $config);
    $self->config($config);

    return $self;
}

=head2 search

Search the directory using a given filter. Returns an arrayref
containing the matching L<Net::LDAP::Entry> objects (if any).

  my $entries = $c->comp('M::People')->search('(sn=TEST)');
  print $entries->[0]->get_value('sn');

=cut

sub search {
    my ($self, $filter) = @_;

    my @args = (
        base   => $self->config->{base},
        filter => $filter,
    );
    my $mesg = $self->_execute('search', @args);

    my @entries = $mesg->entries;

    return \@entries;
}

=head2 _execute

Bind to the server and execute the specified L<Net::LDAP> method,
passing in the specified arguments.

=cut

sub _execute {
    my ($self, $op, @args) = @_;

    my $ldap = $self->_client;

    my $mesg = $ldap->$op(@args, %{ $self->config->{options} });
    $self->code($mesg->code);
    $self->error($mesg->error);

    $ldap->unbind;

    return $mesg;
}

=head2 _client

Return an LDAP connection, bound to the server using the current
configuration.

=cut

sub _client {
    my ($self) = @_;

    my $ldap = Net::LDAP->new(
        $self->config->{host},
        %{ $self->config->{options} },
    ) or Carp::croak $@;

    # Default to an anonymous bind
    my @args;
    if (exists $self->config->{dn}) {
        push @args, $self->config->{dn};
        push @args, password => $self->config->{password} if exists $self->config->{password};
        push @args, %{ $self->config->{options} }         if exists $self->config->{options};
    }

    my $mesg = $ldap->bind(@args);
    Carp::croak 'LDAP error: ' . $mesg->error if $mesg->is_error;

    return $ldap;
}

=head1 SEE ALSO

=over 4

=item * L<Catalyst>

=item * L<Net::LDAP>

=item * L<Catalyst::Model::LDAP::Cached>

=back

=head1 TODO

=over 4

=item * Add other LDAP methods

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
