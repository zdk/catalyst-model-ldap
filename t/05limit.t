use strict;
use Catalyst::Model::LDAP;
use Net::LDAP::Constant qw(LDAP_SIZELIMIT_EXCEEDED);
use Test::More tests => 3;

my $ldap = Catalyst::Model::LDAP->new;
$ldap->config(
    host    => 'ldap.ufl.edu',
    base    => 'ou=People,dc=ufl,dc=edu',
    options => {
        sizelimit => 2,
    },
);

my $entries = $ldap->search("(sn=SMITH)");
ok(scalar @{ $entries } == $ldap->config->{options}->{sizelimit});
ok($ldap->code == LDAP_SIZELIMIT_EXCEEDED);
ok($ldap->error =~ /sizelimit/i);
