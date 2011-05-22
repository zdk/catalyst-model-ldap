use strict;
use warnings;
use Catalyst::Model::LDAP::Connection;
use Test::More tests => 8;

BEGIN {
    use lib 't/lib';
    use_ok( 'TestServer' );
    my $ts   = TestServer->new();
    $ts->start();
    our %opts = %{ $ts->opts };
}

{
    our %opts;
    my $SN = 'BAR';

    my $ldap = Catalyst::Model::LDAP::Connection->new(
        host => 'localhost',
        port => $opts{port},
        base => $opts{base} );

    isa_ok($ldap, 'Catalyst::Model::LDAP::Connection', 'created connection');

    my $mesg = $ldap->search("(sn=$SN)");

    isa_ok($mesg, 'Catalyst::Model::LDAP::Search');
    ok(! $mesg->is_error, 'server response okay');
    ok($mesg->entries, 'got entries');

    my $entry = $mesg->entry(0);
    isa_ok($entry, 'Catalyst::Model::LDAP::Entry');
    is(uc($entry->get_value('sn')), $SN, 'first entry sn matches');
    is(uc($entry->sn), $SN, 'first entry sn via AUTOLOAD matches');
}
