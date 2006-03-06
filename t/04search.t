use strict;
use warnings;
use Test::More;

plan skip_all => 'set LDAP_TEST_LIVE to enable this test' unless $ENV{LDAP_TEST_LIVE};
plan tests    => 3;

use FindBin;
use lib "$FindBin::Bin/lib";
use TestApp::Model::LDAP;

ok(my $ldap = TestApp::Model::LDAP->new, 'created model class');

my $mesg = $ldap->search('(sn=TEST)');

ok(! $mesg->is_error, 'server response okay');
ok($mesg->entries, 'got entries');
