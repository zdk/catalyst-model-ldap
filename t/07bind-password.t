use strict;
use Catalyst::Model::LDAP;
use Test::More;

plan skip_all => 'set LDAP_BINDDN and LDAP_PASSWORD to enable this test' unless $ENV{LDAP_BINDDN} and $ENV{LDAP_PASSWORD};
plan tests => 2;

my $ldap = Catalyst::Model::LDAP->new;
$ldap->config(
    host     => 'ldap.ufl.edu',
    base     => 'ou=People,dc=ufl,dc=edu',
    dn       => $ENV{LDAP_BINDDN},
    password => $ENV{LDAP_PASSWORD},
);

my $uid = 'dwc';
my $entries = $ldap->search("(uid=$uid)");
ok(scalar @{ $entries } == 1);
ok($entries->[0]->get_value('uid') eq $uid);
