package ModuleTarget;
=head1
    Save data to module specific xml

    my $module_target = new ModuleTarget('app', 'fragment_new_user');

    my $xml = new XML::Smart->new('template_sample');
    my $data = $xml->data;
    $module_target->save($data);

=cut

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

sub save{
    my ($this, $data)  = @_;

    my $target_xml = $this->target;

    my $w = new Writer();
    $w->write_new($target_xml, $data);
}


#####################
## get the target
#####################
sub target{
    my ($this)  = @_;

    my $module_name = $this->{_module};
    my $xml = $this->{_target};

    my $module = new Module($module_name);
    my $xml_path = $module->get_xml($xml);
    return $xml_path;
}



return 1;
