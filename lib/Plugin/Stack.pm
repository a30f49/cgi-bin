package Stack;
use lib qw(lib);
use strict;
use warnings;

sub new{
    my $class = shift;
    my $self = {
        _container => shift,
        _class => shift
    };
    bless $self, $class;
    return $self;
}

sub add_one{
}

sub add_all{
}



return 1;
