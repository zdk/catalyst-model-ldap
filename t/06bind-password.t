use strict;
use warnings;
use Test::More;

plan skip_all => 'set LDAP_TEST_LIVE to enable this test' unless $ENV{LDAP_TEST_LIVE};
plan skip_all => 'set LDAP_BINDDN and LDAP_PASSWORD to enable this test'
    unless $ENV{LDAP_BINDDN} and $ENV{LDAP_PASSWORD};
plan tests    => 6;

use FindBin;
use lib "$FindBin::Bin/lib";
use TestApp::Model::LDAP;

TestApp::Model::LDAP->config(
    dn       => $ENV{LDAP_BINDDN},
    password => $ENV{LDAP_PASSWORD},
);

ok(my $ldap = TestApp::Model::LDAP->new, 'created model class');
is($ldap->config->{dn}, $ENV{LDAP_BINDDN}, 'configured bind DN');
is($ldap->config->{password}, $ENV{LDAP_PASSWORD}, 'configured bind password');

my $UID = 'dwc';
my $mesg = $ldap->search("(uid=$UID)");
ok(! $mesg->is_error, 'server response okay');

my @entries = $mesg->entries;
is(scalar @entries, 1, 'got one entry');
is($entries[0]->get_value('uid'), $UID, 'entry uid matches');
