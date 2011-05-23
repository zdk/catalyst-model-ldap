package TestServer;
use Moose;
use Net::LDAP::Server::Test;
use Net::LDAP::Entry;

has 'opts' => (   is => 'rw', isa => 'HashRef',
                  default => sub { { host => 'localhost',
                                     port  => '99389',
                                     base => 'ou=boo,dc=bug'
                                     } },
               );
sub start {
    my $self = shift;
    Net::LDAP::Server::Test->new( $self->opts->{port}, auto_schema => 1 );
}

sub populate {
    my ( $self, $conn ) = @_;

    my @mydata;

    my @entries = (
      { sn => 'bar', cn => 'foo', uid => 'blackcat'},
      { sn => 'bar', cn => 'fah', uid => 'sweet'},
      { sn => 'bar', cn => 'fee', uid => 'perl'},
    );

    foreach my $e (@entries) {
        my $entry = Net::LDAP::Entry->new();
        my $dnc   = $self->{opts}->{base};
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

    $_->update($conn) foreach ( @mydata );
}

1;
