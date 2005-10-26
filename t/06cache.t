package main;

use strict;
use warnings;
use Test::More;

eval 'use Cache::FastMmap';
if ($@) {
    plan skip_all => 'Cache::FastMmap required';
}
else {
    plan tests => 3;
}


{
    package TestApp::M::LDAP::Cached;

    use strict;
    use warnings;
    use base qw/Catalyst::Model::LDAP::Cached/;
    use Cache::FastMmap;

    use FindBin;
    use lib "$FindBin::Bin/lib";
    use TestApp::M::LDAP;

    my $ldap = TestApp::M::LDAP->new;

    __PACKAGE__->config(
        host  => $ldap->config->{host},
        base  => $ldap->config->{base},
        cache => Cache::FastMmap->new,
    );

    1;
}


ok(my $ldap = TestApp::M::LDAP::Cached->new);

my $entries = $ldap->search('(sn=TEST)');
ok(scalar @{ $entries } > 0);

my $entries2 = $ldap->search('(sn=TEST)');
ok(scalar @{ $entries } == scalar @{ $entries2 });
