package Tree;
use lib qw(lib);
use strict;
use warnings;

use Path;

use Data::Dumper;

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
    my $root_tree = $child_item->tree;

    my $child_path = $child_item->path;
    my $child_index = 0;
    if($child_path =~ /\[(\w+)\]/){
        $child_index = $1;

        $child_path =~ s/\[(\w+)\]$//;
    }

    my $path = new Path($child_path);

    while(1){
        my $cut = $path->shift_path;
        #print "cut: $cut\n";
        if(!$cut){
            my $ref = ref $root_tree;
            if($ref eq "ARRAY"){
                my $root_tree = @{$root_tree}[$child_index];
                #print Dumper($root_tree);
                return $root_tree;
            }

            return $root_tree;
        }

        $root_tree = $root_tree->{$cut};
    }

    return $root_tree;
}

return 1;
