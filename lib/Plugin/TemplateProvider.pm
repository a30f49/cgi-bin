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

    my $mod = new Template()->module;
    my $layout = new FlowLayout($mod, $xml);

    return $layout->get_root;
}

sub template_container{
    my ($this, $xml) = @_;

    my $t = new Template();
    my $template_xml = $t->get_xml($xml);
    my $mod = $t->module;

    my $layout = new FlowLayout($mod, $template_xml);
    return $layout->get_container;
}

sub divider_root{
    my ($this) = @_;

    my $divider_xml = 'template_divider';

    my $mod = new Template()->module;
    my $layout = new FlowLayout($mod, $divider_xml);

    return $layout->get_root($divider_xml);
}

sub divider_group_root{
    my ($this) = @_;
    my $divider_group_xml = 'template_divider_group';

    my $mod = new Template()->module;
    my $layout = new FlowLayout($mod, $divider_group_xml);

    return $layout->get_root($divider_group_xml);
}


return 1;
