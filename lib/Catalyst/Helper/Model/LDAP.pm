package Catalyst::Helper::Model::LDAP;

use strict;

=head1 NAME

Catalyst::Helper::Model::LDAP - Helper for LDAP models

=head1 SYNOPSIS

  script/myapp_create.pl model People LDAP ldap.ufl.edu ou=People,dc=ufl,dc=edu

=head1 DESCRIPTION

Helper for the C<Catalyst> LDAP model.

=head1 METHODS

=head2 mk_compclass

Makes the LDAP model class.

=cut

sub mk_compclass {
    my ($self, $helper, $host, $base, $dn, $password) = @_;

    $helper->{host}     = $host     || '';
    $helper->{base}     = $base     || '';
    $helper->{dn}       = $dn       || '';
    $helper->{password} = $password || '';

    my $file = $helper->{file};
    $helper->render_file('ldapclass', $file);

    return 1;
}

=head2 mk_comptest

Makes tests for the LDAP model.

=cut

sub mk_comptest {
    my ($self, $helper) = @_;

    my $test = $helper->{test};

    $helper->render_file('ldaptest', $test);
}

=head1 SEE ALSO

L<Catalyst::Manual>, L<Catalyst::Test>, L<Catalyst::Helper>

=head1 AUTHOR

Daniel Westermann-Clark E<lt>danieltwc@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;


__DATA__

__ldapclass__
package [% class %];

use strict;
use base 'Catalyst::Model::LDAP';

__PACKAGE__->config(
    host         => '[% host %]',
    base         => '[% base %]',
    dn           => '[% dn %]',
    password     => '[% password %]',
    options      => {},
    cache        => undef,
);

=head1 NAME

[% class %] - LDAP Catalyst model component

=head1 SYNOPSIS

See L<[% app %]>.

=head1 DESCRIPTION

LDAP Catalyst model component.

=head1 AUTHOR

[% author %]

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
__ldaptest__
use Test::More tests => 2;
use_ok(Catalyst::Test, '[% app %]');
use_ok('[% class %]');
