use strict;
use warnings;
use Test::More tests => 5;
use Net::LDAP::Constant qw(LDAP_SIZELIMIT_EXCEEDED);

use FindBin;
use lib "$FindBin::Bin/lib";
use TestApp::M::LDAP;

my $SIZELIMIT = 2;

TestApp::M::LDAP->config(
    options => {
        sizelimit => $SIZELIMIT,
    },
);
ok(my $ldap = TestApp::M::LDAP->new);
ok($ldap->config->{options}->{sizelimit} == $SIZELIMIT);

my $entries = $ldap->search("(sn=SMITH)");
ok(scalar @{ $entries } == $ldap->config->{options}->{sizelimit});

ok($ldap->code == LDAP_SIZELIMIT_EXCEEDED);
ok($ldap->error =~ /sizelimit/i);
