use strict;
use warnings;
use Test::More tests => 2;

use FindBin;
use lib "$FindBin::Bin/lib";
use TestApp::M::LDAP;

ok(my $ldap = TestApp::M::LDAP->new);

my $entries = $ldap->search('(sn=TEST)');
ok(scalar @{ $entries } > 0);
