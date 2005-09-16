use strict;
use Catalyst::Model::LDAP;
use Test::More tests => 2;

ok(my $ldap = Catalyst::Model::LDAP->new);
$ldap->config(
    host => 'ldap.ufl.edu',
    base => 'ou=People,dc=ufl,dc=edu',
);

my $entries = $ldap->search('(sn=TEST)');
ok(scalar @{ $entries } > 0);
