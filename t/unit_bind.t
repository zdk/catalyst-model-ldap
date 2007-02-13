use strict;
use warnings;
use Catalyst::Model::LDAP::Connection;
use Test::More;

plan skip_all => 'set LDAP_TEST_LIVE, LDAP_BINDDN, and LDAP_PASSWORD to enable this test'
    unless $ENV{LDAP_TEST_LIVE} and $ENV{LDAP_BINDDN} and $ENV{LDAP_PASSWORD};
plan tests    => 7;

my $UID = 'dwc';

my $ldap = Catalyst::Model::LDAP::Connection->new(
    host => 'ldap.ufl.edu',
    base => 'ou=People,dc=ufl,dc=edu',
);
ok($ldap, 'created connection');

$ldap->bind(
    dn       => $ENV{LDAP_BINDDN},
    password => $ENV{LDAP_PASSWORD},
);

my $mesg = $ldap->search("(uid=$UID)");

isa_ok($mesg, 'Catalyst::Model::LDAP::Search');
ok(! $mesg->is_error, 'server response okay');
is($mesg->count, 1, 'got one entry');

isa_ok($mesg->entry(0), 'Catalyst::Model::LDAP::Entry');
is($mesg->entry(0)->get_value('uid'), $UID, 'entry uid matches');
is($mesg->entry(0)->uid, $UID, 'entry uid via AUTOLOAD matches');
