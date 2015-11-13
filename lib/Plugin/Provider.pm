package Provider;
use lib qw(lib);
use File::chdir;
use Cwd;
use strict;
use warnings;
use JSON;
use utf8;

use XML::Smart;

sub new{
    my $class = shift;
    my $self = {
        _layout => shift
    };
    bless $self, $class;
    return $self;
}

sub get_root{
    my ($this) = @_;
}

sub get_container{
    my ($this) = @_;
}


return 1;
