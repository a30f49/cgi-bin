package ModuleTarget;
use lib qw(lib);
use strict;
use warnings;

use Android::Module;

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

return 1;
