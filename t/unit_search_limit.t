use strict;
use warnings;
use Catalyst::Model::LDAP::Connection;
use Net::LDAP::Constant qw/LDAP_SIZELIMIT_EXCEEDED/;
use Test::More;

plan skip_all => 'set LDAP_TEST_LIVE to enable this test' unless $ENV{LDAP_TEST_LIVE};
plan tests    => 7;

my $SIZELIMIT = 2;
my $SN        = 'SMITH';

my $ldap = Catalyst::Model::LDAP::Connection->new(
    host    => 'ldap.ufl.edu',
    base    => 'ou=People,dc=ufl,dc=edu',
    options => {
        sizelimit => $SIZELIMIT,
    },
);
ok($ldap, 'created connection');

my $mesg = $ldap->search("(sn=$SN)");

isa_ok($mesg, 'Catalyst::Model::LDAP::Search');
is($mesg->code, LDAP_SIZELIMIT_EXCEEDED, 'server response okay');
is($mesg->count, $SIZELIMIT, 'number of entries matches sizelimit');

isa_ok($mesg->entry(0), 'Catalyst::Model::LDAP::Entry');
is($mesg->entry(0)->get_value('sn'), $SN, 'entry sn matches');
is($mesg->entry(0)->sn, $SN, 'entry sn via AUTOLOAD matches');
