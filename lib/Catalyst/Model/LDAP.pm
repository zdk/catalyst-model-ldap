package Catalyst::Model::LDAP;

use strict;
use base qw/Catalyst::Model/;
use Carp ();
use NEXT;
use Net::LDAP;

our $VERSION = '0.08';
our $AUTOLOAD;

=head1 NAME

Catalyst::Model::LDAP - LDAP model class for Catalyst

=head1 SYNOPSIS

  # Use the Catalyst helper
  script/myapp_create.pl model Person LDAP ldap.ufl.edu ou=People,dc=ufl,dc=edu

  # lib/MyApp/Model/Person.pm
  package MyApp::Model::Person;

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
  my $mesg = $c->model('Person')->search('(sn=TEST)');
  my @entries = $mesg->entries;
  print $entries[0]->get_value('sn');

=head1 DESCRIPTION

This is the L<Net::LDAP> model class for Catalyst. It is nothing more
than a simple wrapper for L<Net::LDAP>.

This class simplifies LDAP searches by letting you configure a base
DN. Other L<Net::LDAP> methods are supported via Perl's AUTOLOAD
mechanism.

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

=head2 _client

Bind the client using the current configuration and return it.

=cut

sub _client {
    my ($self) = @_;

    # Default to an anonymous bind
    my @args;
    if (exists $self->config->{dn}) {
        push @args, $self->config->{dn};
        push @args, password => $self->config->{password}
            if exists $self->config->{password};
        push @args, %{ $self->config->{options} }
            if exists $self->config->{options};
    }

    my $client = Net::LDAP->new(
        $self->config->{host},
        %{ exists $self->config->{options} ? $self->config->{options} : {} },
    ) or Carp::croak($@);

    my $mesg = $client->bind(@args);
    Carp::croak('LDAP error: ' . $mesg->error) if $mesg->is_error;

    return $client;
}

=head2 _execute

Execute the specified LDAP command.

=cut

sub _execute {
    my ($self, $op, @args) = @_;

    my $client = $self->_client;
    my $mesg   = $client->$op(@args, %{ $self->config->{options} });

    return $mesg;
}

# Based on Catalyst::Model::NetBlogger
sub AUTOLOAD {
    my ($self, @args) = @_;

    return if $AUTOLOAD =~ /::DESTROY$/;
    $AUTOLOAD =~ s/^.*:://;

    if ($AUTOLOAD eq 'search' and scalar @args == 1) {
        # Simplify common case
        @args = (
            filter => $args[0],
            base   => $self->config->{base},
        );
    }

    return $self->_execute($AUTOLOAD, @args);
}

=head1 SEE ALSO

=over 4

=item * L<Catalyst>

=item * L<Net::LDAP>

=back

=head1 AUTHOR

Daniel Westermann-Clark E<lt>danieltwc@cpan.orgE<gt>

Based on work started by E<lt>salih@ip-plus.netE<gt> on the Catalyst
mailing list:

L<http://lists.rawmode.org/pipermail/catalyst/2005-June/000712.html>

=head1 ACKNOWLEDGEMENTS

=over 4

=item * Christopher H. Laco, for C<AUTOLOAD> idea

=back

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
