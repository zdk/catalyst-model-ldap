use strict;
use warnings;
use Catalyst::Model::LDAP::Connection;
use Test::More;

plan skip_all => 'set LDAP_TEST_LIVE to enable this test' unless $ENV{LDAP_TEST_LIVE};
plan tests    => 7;

my $SN = 'TEST';

my $ldap = Catalyst::Model::LDAP::Connection->new(
    host => 'ldap.ufl.edu',
    base => 'ou=People,dc=ufl,dc=edu',
);
ok($ldap, 'created connection');

my $mesg = $ldap->search("(sn=$SN)");

isa_ok($mesg, 'Catalyst::Model::LDAP::Search');
ok(! $mesg->is_error, 'server response okay');
ok($mesg->entries, 'got entries');

isa_ok($mesg->entry(0), 'Catalyst::Model::LDAP::Entry');
is($mesg->entry(0)->get_value('sn'), $SN, 'first entry sn matches');
is($mesg->entry(0)->sn, $SN, 'first entry sn via AUTOLOAD matches');
