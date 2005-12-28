use strict;
use warnings;
use Test::More tests => 4;
use Net::LDAP::Constant qw(LDAP_SIZELIMIT_EXCEEDED);

use FindBin;
use lib "$FindBin::Bin/lib";
use TestApp::Model::LDAP;

my $SIZELIMIT = 2;

TestApp::Model::LDAP->config(
    options => {
        sizelimit => $SIZELIMIT,
    },
);
ok(my $ldap = TestApp::Model::LDAP->new, 'created model class');
is($ldap->config->{options}->{sizelimit}, $SIZELIMIT, 'sizelimit configured');

my $mesg = $ldap->search("(sn=SMITH)");

is($mesg->code, LDAP_SIZELIMIT_EXCEEDED, 'server response okay');
is(scalar $mesg->entries, $ldap->config->{options}->{sizelimit}, 'number of entries matches sizelimit');
