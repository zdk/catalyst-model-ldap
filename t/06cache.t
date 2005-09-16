use strict;
use Catalyst::Model::LDAP;
use Test::More;

eval 'use Cache::FastMmap';
if ($@) {
    plan skip_all => 'Cache::FastMmap required';
}
else {
    plan tests => 2;
}

my $ldap = Catalyst::Model::LDAP->new;
$ldap->config(
    host  => 'ldap.ufl.edu',
    base  => 'ou=People,dc=ufl,dc=edu',
    cache => Cache::FastMmap->new,
);

my $entries = $ldap->search('(sn=TEST)');
ok(scalar @{ $entries } > 0);

my $entries2 = $ldap->search('(sn=TEST)');
ok(scalar @{ $entries } == scalar @{ $entries2 });
