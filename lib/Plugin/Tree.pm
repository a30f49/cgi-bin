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

sub root_tree{
    my ($this, $root) = @_;
    if(!$root){
        $root = $this->{_root};
    }

    $root = $root->base;
    $root = $root->cut_root;

    if(exists $root->{'xmlns:android'}){
        delete $root->{'xmlns:android'};
    }
    my $root_key = $root->key;
    return $root->tree->{$root_key};
}

sub tree{
    my ($this) = @_;

    my $child_item = $this->{_root};

    my $root = $child_item->base;
    $root = $root->cut_root;

}

sub find_tree{
    my ($root, $child_item) = @_;

    return $child_item->tree;
}

return 1;
