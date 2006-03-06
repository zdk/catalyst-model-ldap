use strict;
use warnings;
use Test::More;

plan skip_all => 'set LDAP_TEST_LIVE to enable this test' unless $ENV{LDAP_TEST_LIVE};
plan tests    => 2;

use FindBin;
use lib "$FindBin::Bin/lib";
use TestApp::Model::LDAP;

ok(my $ldap = TestApp::Model::LDAP->new, 'created model class');

my $version = $ldap->version;
ok($version, 'got a version');
