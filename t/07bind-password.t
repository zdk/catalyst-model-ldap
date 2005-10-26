use strict;
use warnings;
use Test::More;

use FindBin;
use lib "$FindBin::Bin/lib";
use TestApp::M::LDAP;

plan skip_all => 'set LDAP_BINDDN and LDAP_PASSWORD to enable this test' unless $ENV{LDAP_BINDDN} and $ENV{LDAP_PASSWORD};
plan tests => 5;

TestApp::M::LDAP->config(
    dn       => $ENV{LDAP_BINDDN},
    password => $ENV{LDAP_PASSWORD},
);

ok(my $ldap = TestApp::M::LDAP->new);
ok($ldap->config->{dn} eq $ENV{LDAP_BINDDN});
ok($ldap->config->{password} eq $ENV{LDAP_PASSWORD});

my $uid = 'dwc';
my $entries = $ldap->search("(uid=$uid)");
ok(scalar @{ $entries } == 1);
ok($entries->[0]->get_value('uid') eq $uid);
