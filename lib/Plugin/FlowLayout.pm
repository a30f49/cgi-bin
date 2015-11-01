package FlowLayout;
use lib qw(lib);
use File::chdir;
use Cwd;
use strict;
use warnings;
use JSON;
use utf8;
use Data::Dumper;

use Android::Module;

use  Plugin::Tree;

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

sub layout{
    my ($this) = @_;
    return $this->{_layout};
}
sub module{
    my ($this) = @_;
    return $this->{_module};
}

sub container{
    my ($this, $in) = @_;
    if($in){
        $this->{_container} = $in;
    }
    return $this->{_container};
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

sub get_root{
    my ($this, $xml) = @_;

    if(!$xml){
        $xml = $this->layout;
    }

    my $module = new Module($this->{_module});
    my $xml_path = $module->xml($xml);

    my $root = XML::Smart->new($xml_path);
    $root = $root->cut_root;

    return $root;
}

sub get_container{
    my ($this, $xml) = @_;
    my $xml_path = $module->xml($xml);

    my $xml_obj = XML::Smart->new($xml_path);
    $xml_obj = $xml_obj->cut_root;

    my $root = $this->get_root($xml);

    my $container = $xml_obj->find_child('android:id', 'eq', '@id/container');
    if(!$container){
        print STDERR "WARN:specific the container before getting data..\n";
    }

    if (!($this->container)){
        $this->container($container);
    }

    return $container;
}


return 1;
