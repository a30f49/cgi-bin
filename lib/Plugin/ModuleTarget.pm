package ModuleTarget;
use lib qw(lib);
use strict;
use warnings;

use Android::Module;

use File::Writer;

sub new{
    my $class = shift;
    my $self = {
        _module => shift,
        _target => shift
    };
    bless $self, $class;
    return $self;
}

sub target{
    my ($this)  = @_;

    my $module_name = $this->{_module};
    my $xml = $this->{_target};

    my $module = new Module($module_name);
    my $xml_path = $module->get_xml($xml);
    return $xml_path;
}

sub save{
    my ($this, $data)  = @_;

    my $target_xml = $this->target;

    my $w = new Writer();
    $w->write_new($target_xml, $data);
}



return 1;
