package SmartWrapper;
use lib qw(lib);
use File::chdir;
use Cwd;
use strict;
use warnings;
use XML::Smart;

sub new{
    my $class = shift;
    my $self = {
        _obj => shift
    };
    bless $self, $class;

    return $self;
}

sub from_xml{
    my ($this, $xml) = @_;

    my $xml_obj = XML::Smart->new($xml);
    $xml_obj = $xml_obj->cut_root;

    $this->{_obj} = $xml_obj;

    return $xml_obj;
}

sub get_tree{
    my ($this) = @_;

    my $xml_obj = $this->{_obj};

    $xml_obj = $xml_obj->base;
    $xml_obj = $xml_obj->cut_root;

    delete $xml_obj->{'xmlns:android'};

    my $root_key = $xml_obj->key;

    return $xml_obj->tree->{$root_key};
}

sub dump_tree{
    my ($this) = @_;
    return $this->{_obj} -> dump_tree;
}

sub save{
    my ($this, $xml) = @_;
    my $xml_obj = $this->{_obj};
    $xml_obj->save($xml);
}


return 1;
