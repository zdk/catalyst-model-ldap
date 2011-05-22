package TestServer;
use Moose;
use Net::LDAP::Server::Test;
use Net::LDAP::Entry;

has 'opts' => ( is => 'rw', isa => 'HashRef',
              default => sub { { host => 'localhost',
                                 port  => '99389',
                                 base => 'ou=boo,dc=bug'
                                 } } );
has 'entries' => (
     is        => 'rw',
     isa       => 'ArrayRef',
     lazy      => 1,
     builder   => '_build_entries',
);

sub _build_entries {
    my $self = shift;
    my @mydata;

    my @entries = (
      { sn => 'bar',  cn => 'foo', uid => 'blackcat'},
      { sn => 'blah', cn => 'fah', uid => 'sweet'},
      { sn => 'boom', cn => 'fee', uid => 'perl'},
    );

    foreach my $e (@entries) {
        my $entry = Net::LDAP::Entry->new;
        my $dnc   = 'ou=boo,dc=bug';
        $entry->dn("uid=".$e->{uid}.",$dnc");
        $entry->add(
            dn  => "uid=".$e->{uid}.",$dnc",
            sn  => $e->{sn},
            cn  => $e->{cn},
            uid => $e->{uid},
            password => 'secret',
        );
        push @mydata, $entry;
    }
    return \@mydata;
}

sub start {
    my $self = shift;
    Net::LDAP::Server::Test->new( $self->opts->{port}, data => $self->entries );
}

1;
