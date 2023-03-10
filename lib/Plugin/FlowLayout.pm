package FlowLayout;
=head1 USAGE
    A wrapper of XML::Smart to get xml data within
    a specific module.

    #Sample 1, read layout data within module 'app'
    my $layout = new FlowLayout('app', 'fragment_new_user.xml');
    my $container = $layout->get_container;

    #Sample 2, get root, or container
    my $layout = new FlowLayout('app');
    my $root = $layout->get_root('fragment_new_user.xml');
    my $container = $layout->get_container('fragment_new_user.xml');

=cut

use lib qw(lib);
use File::chdir;
use Cwd;
use strict;
use warnings;
use JSON;
use utf8;
use Data::Dumper;

use Android::Module;

use Plugin::Tree;
use Plugin::TemplateProvider;

use XML::Smart;

sub new{
    my $class = shift;
    my $self = {
        _module => shift,
        _layout => shift,
        _container => undef
    };
    bless $self, $class;

    return $self;
}

sub module{
    my ($this) = @_;
    return $this->{_module};
}

sub layout{
    my ($this) = @_;
    return $this->{_layout};
}

sub container{
    my ($this, $in) = @_;
    if($in){
        $this->{_container} = $in;
    }else{
        if(!$this->{_container}){
            $this->get_container;
        }
    }

    return $this->{_container};
}

sub clone_first_child{
    my ($this) = @_;
    my $first = $this->first_child;
    if(!$first){
        return undef;
    }

    return $first->copy;
}

sub first_child{
    my ($this) = @_;
    my @children = $this->first_node_array;
    my $count = @children;

    if($count == 0){
        return undef;
    }

    my $first = $children[0];
}

sub first_node_array{
    my ($this) = @_;
    if(!($this->container)){
        $this->get_container;
    }

    my @children = $this->container->first_node_array;
    return @children;
}

#######################
## get container of XML::Smart #
#########################
sub get_container{
    my ($this, $xml) = @_;
    my $root = $this->get_root($xml);
    if(!$root){
        die "fetal: fail to get root from $xml\n";
    }

    my $container = $root->find_child('android:id', 'eq', '@id/container');
    if(!$container){
        print STDERR "fetal: specific the container before getting data\n";
        return undef;
    }

    if (!($this->{_container})){
        $this->container($container);
    }

    return $container;
}

#######################
## get root of XML::Smart #
#########################
sub get_root{
    my ($this, $xml) = @_;
    if(!$xml){
        $xml = $this->layout;
    }
    if($xml !~ /\.xml$/){
        $xml = "$xml.xml";
    }

    ## check exist
    my $xml_path;
    if($xml =~ /^[\w\.]+$/){
        my $mod = $this->{_module};
        my $module = new Module($mod);

        $xml_path = $module->xml($xml);

        if( !(-f $xml_path) ){
            die "fetal: $xml not exists\n";
        }
    }

    my $root = XML::Smart->new($xml_path);
    $root = $root->cut_root;

    return $root;
}


##############################
## add children from children_root into container #
###############################
sub add_children{
    my ($this, $container, $children_root) = @_;
    if(!$container){
        die "fetal: no params\n";
    }
    if(!$children_root){
        $children_root = $container;
        $container = $this->container;
    }
    if(!$container or !$children_root){
        die "fetal: unknown error.\n"
    }

    my @nodes = $children_root->nodes_keys;
    if(@nodes==0){
        die "fetal: no child\n"
    }

    my %node_hash;
    foreach(@nodes){
        my $key = $_;
        $node_hash{$key} = $children_root->{$key};
    }

    #$container->{'/nodes'} = {TextView=>1,View=>1};
    my $tree = new Tree($children_root)->tree;
    my $container_tree = new Tree($container)->tree;

    ####
    my @orders = @{$tree->{'/order'}};
    foreach(@orders){
        my $key = $_;

        if(exists $node_hash{$key}){
            my @children = @{$node_hash{$key}};
            #print "key: $key\n";

            my $child= shift @children;

            push(@{$container_tree->{$key}}, new Tree($child)->tree);
            push(@{$container_tree->{'/order'}}, $key);

            $node_hash{$key} = \@children;
        }
    }
}

##############################
## add child item to container #
###############################
sub add_child{
    my ($this, $child_item) = @_;
    if(!$child_item){
        die "fetal: no params\n";
    }
    if(exists $child_item->{'xmlns:android'}){
        delete $child_item->{'xmlns:android'};
    }

    my $container = $this->container;
    my $key = $child_item->key;

    #$container->{'/nodes'} = {TextView=>1,View=>1};
    #my $container_tree = new Tree($container)->tree;

    push(@{$container->{$key}}, new Tree($child_item)->tree);
    push(@{$container->{'/order'}}, $key);
}

sub add_line{
    my ($this, $height) = @_;

    my $tp = new TemplateProvider();
    my $line = $tp->line_root($height);

    $this->add_child($line);
}


return 1;
