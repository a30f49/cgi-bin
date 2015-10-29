package FlowTemplate;
use lib qw(lib);
use File::chdir;
use Cwd;
use strict;
use warnings;
use XML::Smart;
use Path;
use JSON;
use utf8;
use Data::Dumper;

use Android::Template;
use Android::Module;

use Plugin::Flow;
use Plugin::SmartWrapper;

sub new{
    my $class = shift;
    my $self = {
        _target_module => shift,
        _container_template         => undef,
        _container_item_template    => undef,
        _divider_template           =>undef,
        _divider_group_template     =>undef,
        _xml_obj => undef
    };
    bless $self, $class;

    return $self;
}

sub container_template{
    my ($this, $xml) = @_;
    if($xml){
        $this->{_container_template} = $xml;
    }
    return $this->{_container_template};
}
sub container_item_template{
    my ($this, $xml) = @_;
    if($xml){
        $this->{_container_item_template} = $xml;
    }
    return $this->{_container_item_template};
}
sub divider_template{
    my ($this, $xml) = @_;
    if($xml){
        $this->{_divider_template} = $xml;
    }
    return $this->{_divider_template};
}
sub divider_group_template{
    my ($this, $xml) = @_;
    if($xml){
        $this->{_divider_group_template} = $xml;
    }
    return $this->{_divider_group_template};
}

return 1;
