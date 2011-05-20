use Test::More tests => 12;
use strict;
use warnings;

use Net::LDAP::Server::Test;
use Net::LDAP::Entry;
use Catalyst::Model::LDAP::Connection;

ok(1); #yeah, good start at least :P

my %opts = (
    port  => '99389',
    dnc   => 'ou=boo,dc=bug',
    debug => $ENV{PERL_DEBUG} || 0,
);

my @mydata;
my $entry = Net::LDAP::Entry->new;
$entry->dn('ou=boo');
$entry->add(
    dn  => 'ou=boo,dc=bug',
    sn  => 'samtalee',
    cn  => 'di',
    uid => 'zdk',
    password => 'secret'
);
push @mydata, $entry;

ok( my $server = Net::LDAP::Server::Test->new( $opts{port}, data => \@mydata ),
    "spawn new server with our own data" );

my $UID = 'zdk';

my $ldap = Catalyst::Model::LDAP::Connection->new(
    host => 'localhost',
    port => $opts{port},
    base => 'ou=boo' );

isa_ok($ldap, 'Catalyst::Model::LDAP::Connection', 'ldap connection created');

ok($ldap->bind( dn => "uid=$UID,$opts{dnc}", password => 'secret'), "binded uid=$UID,$opts{dnc} its credential");

my $mesg = $ldap->search("(uid=$UID)");

isa_ok($mesg, 'Catalyst::Model::LDAP::Search');
ok(! $mesg->is_error, 'reponse is fine, so no error from server');
is($mesg->count, 1, 'got one entry as added in test server :) ');
$entry = $mesg->entry(1);
is($entry, undef, 'got undefined');

$entry = $mesg->entry(0);
isa_ok($entry, 'Catalyst::Model::LDAP::Entry');
can_ok($entry, ('get_value', 'uid'));
is($entry->get_value('uid'), $UID, 'entry uid is matched');
is($entry->uid, $UID, 'entry uid via AUTOLOAD is matched');

# ok( $mesg = $ldap->unbind, "LDAP unbind()" ); #no need
