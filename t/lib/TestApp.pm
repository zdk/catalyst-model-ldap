package TestApp;

use strict;
use warnings;
use Catalyst;# qw/-Debug/;
use Data::Dumper;

our $VERSION = '0.01';

__PACKAGE__->config(
    name => 'TestApp',
    'Model::LDAP' => {
        host             => 'ldap.ufl.edu',
        base             => 'ou=People,dc=ufl,dc=edu',
        connection_class => 'TestApp::LDAP::Connection',
        entry_class      => 'TestApp::LDAP::Entry',
    },
);

__PACKAGE__->setup;

sub filter {
    my ($self, $params) = @_;

    my @parts = map { $_ . '=' . $params->{$_} } keys %$params;
    my $filter = '(' . join('&', @parts) . ')';

    return $filter;
}

sub search : Local {
    my ($self, $c) = @_;

    my $filter = $self->filter($c->request->params);
    my $mesg = $c->model('LDAP')->search($filter);

    $c->stash(entries => [ $mesg->entries ]);
    $c->forward('results');
}

sub blarg : Local {
    my ($self, $c) = @_;

    my $filter = $self->filter($c->request->params);
    my $mesg = $c->model('LDAP')->blarg($filter);

    $c->stash(entries => [ $mesg->entries ]);
    $c->forward('results');
}

sub is_cool : Local {
    my ($self, $c) = @_;

    my $uid = $c->request->params->{uid};
    my $mesg = $c->model('LDAP')->search("(uid=$uid)");

    $c->response->content_type('text/plain');
    $c->response->body($mesg->entry(0)->is_cool);
}

sub results : Local {
    my ($self, $c) = @_;

    $c->response->content_type('text/plain');
    $c->response->body(Dumper $c->stash);
}

sub end : Private {
    my ($self, $c) = @_;

    return 1 if $c->response->status =~ /^3\d\d$/;
    return 1 if $c->response->body;

    $c->res->body('Default body from end');
}

1;
