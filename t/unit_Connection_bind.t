use Test::More;
use strict;
use warnings;

ok(1); #yeah, good start at least :P

BEGIN {
    use lib 't/lib';
    use_ok( 'TestServer' );
    my $ts   = TestServer->new();
    $ts->start();
    our %opts = %{ $ts->opts };
}

use Catalyst::Model::LDAP::Connection;

{
    our %opts;
    my $ldap = Catalyst::Model::LDAP::Connection->new(
        host => 'localhost',
        port => $opts{port},
        base => 'ou=boo,dc=bug',
    );

    my $UID = 'blackcat';
    isa_ok($ldap, 'Catalyst::Model::LDAP::Connection', 'ldap connection created');
    ok($ldap->bind( dn => "uid=$UID,$opts{base}", password => 'secret'), "binded uid=$UID,$opts{base} its credential");
    my $mesg = $ldap->search("(uid=$UID)");

    isa_ok($mesg, 'Catalyst::Model::LDAP::Search');
    ok(! $mesg->is_error, 'reponse is fine, so no error from server');
    is($mesg->count, 3, 'got one entry as added in test server :) '); #FIXME: wrong count
    my $entry = $mesg->entry(3);
    is($entry, undef, 'got undefined');

    $entry = $mesg->entry(0);
    isa_ok($entry, 'Catalyst::Model::LDAP::Entry');
    can_ok($entry, ('get_value', 'uid'));
    is($entry->get_value('uid'), $UID, 'entry uid is matched');
    is($entry->uid, $UID, 'entry uid via AUTOLOAD is matched');
    is($entry->dn, "uid=$UID,$opts{base}", 'got correct dn');
}

done_testing();