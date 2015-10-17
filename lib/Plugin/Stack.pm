package Stack;
use lib qw(lib);
use strict;
use warnings;

use Data::Dumper;

use Plugin::Tree;

use Plugin::TemplateProvider;

sub new{
    my $class = shift;
    my $self = {
        _container => shift,
        _divider => undef,
        _divider_group => undef
    };
    bless $self, $class;

    my $container_xml = $self->{_container};

    my $provider = new TemplateProvider();
    $self->{_container} = $provider->get_root($container_xml);
    $self->{_container} = $self->{_container}->find_child('android:id','eq','@id/container');
    if(!($self->{_container})){
        print STDERR 'Stack::Fail to find the child with @id/container';
    }

    $self->{_divider} = $provider->divider_root;
    $self->{_divider_group} = $provider->divider_group_root;

    return $self;
}

sub container_root{
    my ($this) = @_;

    my $root = $this->{_container};
    return $root;
}

sub divider_root{
    my ($this) = @_;

    my $root = $this->{_divider};
    return $root;
}

sub divider_key{
    my ($this) = @_;
    my $root = $this->{_divider};
    return $root->key;
}

sub divider_group_root{
    my ($this) = @_;

    my $root = $this->{_divider_group};
    return $root;
}

sub divider_group_key{
    my ($this) = @_;
    my $root = $this->{_divider_group};
    return $root->key;
}

sub container_tree{
    my ($this) = @_;

    my $container_root = $this->{_container};
    my $tree = new Tree($container_root)->root_tree;
    return $tree;
}

sub divider_tree{
    my ($this) = @_;

    my $root = $this->{_divider};
    my $tree = new Tree($root)->root_tree;
    return $tree;
}

sub divider_group_tree{
    my ($this) = @_;

    my $root = $this->{_divider_group};
    my $tree = new Tree($root)->root_tree;
    return $tree;
}

sub add_one{
    my ($this, $item_root, $group_start) = @_;
    #print Dumper($item_root);

    my $item_tree = new Tree($item_root)->root_tree;
    my $item_key = $item_root->key;

    my $container_tree = $this->container_tree;
    #print Dumper($container_tree);

    my $divider_tree = $this->divider_tree;
    my $divider_key = $this->divider_key;
    my $divider_group_tree = $this->divider_group_tree;
    my $divider_group_key = $this->divider_group_key;

    if($group_start){
        push (@{$container_tree->{$divider_group_key}}, $divider_group_tree);
        push (@{$container_tree->{'/order'}}, $divider_group_key);
    }else{
        push (@{$container_tree->{$divider_key}}, $divider_tree);
        push (@{$container_tree->{'/order'}}, $divider_key);
    }
    push(@{$container_tree->{$item_key}}, $item_tree);
    push (@{$container_tree->{'/order'}}, $item_key);
}

sub data{
    my ($this) = @_;

    return $this->container_root->data;
}


return 1;
