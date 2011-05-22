use strict;
use warnings;
use Test::More tests => 4;

use Net::LDAP::Server::Test;
use Catalyst::Model::LDAP::Connection;

BEGIN {
    use lib 't/lib';
    use_ok( 'TestServer' );
    my $ts   = TestServer->new();
    $ts->start();
    our %opts = %{ $ts->opts };    
}

{
    eval {
        my $ldap = Catalyst::Model::LDAP::Connection->new(
            host    => 'example.com',
            base    => 'ou=People,dc=ufl,dc=edu',
            timeout => 0.5,
        );
    };

    diag($@);
    ok($@, 'failed to connect to invalid host');
}

{
    our %opts;
    my $ldap = Catalyst::Model::LDAP::Connection->new(
        host    => 'localhost',
        port    => $opts{port},
        base    => $opts{base},
        timeout => 2,
    );

    ok(!$@, 'connected to valid host');
    isa_ok($ldap, 'Catalyst::Model::LDAP::Connection');
}
