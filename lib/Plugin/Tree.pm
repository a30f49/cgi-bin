package Tree;
use lib qw(lib);
use strict;
use warnings;

sub new{
    my $class = shift;
    my $self = {
        _root => shift
    };
    bless $self, $class;
    return $self;
}

sub tree{
    my ($this,$root) = @_;
    if(!$root){
        $root = $this->{_root};
    }

    $root = $root->base;
    $root = $root->cut_root;
    delete $root->{'xmlns:android'};
    my $root_key = $root->key;
    return $root->tree->{$root_key};
}

return 1;
