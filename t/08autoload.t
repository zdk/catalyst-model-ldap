use strict;
use warnings;
use Test::More tests => 2;

use FindBin;
use lib "$FindBin::Bin/lib";
use TestApp::Model::LDAP;

ok(my $ldap = TestApp::Model::LDAP->new, 'created model class');

my $version = $ldap->version;
ok($version, 'got a version');
