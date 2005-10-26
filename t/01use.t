use strict;
use Test::More tests => 3;

BEGIN { use_ok('Catalyst::Model::LDAP') }
BEGIN { use_ok('Catalyst::Model::LDAP::Cached') }
BEGIN { use_ok('Catalyst::Helper::Model::LDAP') }
