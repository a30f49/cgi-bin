package TemplateProvider;
use lib qw(lib);
use File::chdir;
use Cwd;
use strict;
use warnings;
use JSON;
use utf8;

use Plugin::Provider;
our @ISA = qw(Provider);

use Data::Dumper;

use XML::Smart;

use Android::Template;

use Plugin::FlowLayout;

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
## get the  object
####################
sub template_root{
    my ($this, $xml) = @_;
    $xml =~ s/\.xml//;
    #$xml = "$xml.xml";

    my $mod = new Template()->module;
    my $layout = new FlowLayout($mod, $xml);
    my $root = $layout->get_root;

    #if(exists $root->{'xmlns:android'}){
    #   delete $root->{'xmlns:android'};
    #}

    return $root;
}

sub template_container{
    my ($this, $xml) = @_;
    $xml =~ s/\.xml//;
    #$xml = "$xml.xml";

    my $mod = new Template()->module;
    #my $xml_path = $t->xml($xml);
    #if(!(-f $xml_path)){
    #    die "fetal: $xml not exists\n";
    #}

    my $layout = new FlowLayout($mod, $xml);
    return $layout->get_container;
}

sub divider_root{
    my ($this) = @_;

    my $divider_xml = 'template_divider';
    my $root = $this->template_root($divider_xml);

    if(exists $root->{'xmlns:android'}){
       delete $root->{'xmlns:android'};
    }

    return $root;
}

sub divider_group_root{
    my ($this) = @_;
    my $divider_group_xml = 'template_divider_group';
    my $root = $this->template_root($divider_group_xml);

    if(exists $root->{'xmlns:android'}){
       delete $root->{'xmlns:android'};
    }

    return $root;
}

sub line_root{
    my ($this, $height) = @_;
    my $divider_group_xml = 'template_line';
    my $root = $this->template_root($divider_group_xml);

    if(exists $root->{'xmlns:android'}){
       delete $root->{'xmlns:android'};
    }

    if($height){
        if($height=~/^0\.5$/){
            $height = $height.'dp';
        }
        if($height =~ /^[0-9]+$/){
            $height = $height.'dp';
        }
        $root->{'android:layout_height'} = $height;
    }

    return $root;
}


return 1;
