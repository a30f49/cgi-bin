package TemplateProvider;
use lib qw(lib);
use File::chdir;
use Cwd;
use strict;
use warnings;
use JSON;
use utf8;
use Data::Dumper;

use XML::Smart;

use Android::Template;

sub new{
    my $class = shift;
    my $self = {
        _divider           =>undef,
        _divider_group     =>undef,
    };
    bless $self, $class;

    return $self;
}

####################
## get the smart object
####################
sub get_root{
    my ($this, $xml) = @_;

    if( !(-f $xml)){
        $xml = new Template()->get_xml($xml);
    }
    if( !(-f $xml)){
        print STDERR "xml $xml not exists.\n";
        return undef;
    }
    my $xml_obj = XML::Smart->new($xml);
    $xml_obj = $xml_obj->cut_root;

    return $xml_obj;
}

sub divider_root{
    my ($this) = @_;

    my $divider_xml = 'template_divider';
    return $this->get_root($divider_xml);
}

sub divider_group_root{
    my ($this) = @_;
    my $divider_group_xml = 'template_divider_group';
    return $this->get_root($divider_group_xml);
}


####################
## get the tree of smart object
####################
sub get_tree{
    my ($this, $xml) = @_;

    my $xml_obj;

    my $r = ref $xml;
    if( !($r eq "XML::Smart") ){
        $xml_obj = $this->get_root($xml);
        if(!$xml_obj){
            return undef;
        }
    }

    $xml_obj = $xml_obj->base;
    $xml_obj = $xml_obj->cut_root;
    delete $xml_obj->{'xmlns:android'};
    my $root_key = $xml_obj->key;
    return $xml_obj->tree->{$root_key};
}

return 1;
