package Parser;
use lib qw(lib);
use File::Spec;

sub new{
    my $class = shift;
    my $self = {
    };
    bless $self, $class;
    return $self;
}

sub parse_package{
    my ($this, $pack) = @_;
    return $pack;
}



return 1;