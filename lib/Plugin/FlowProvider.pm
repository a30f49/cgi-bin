package FlowProvider;
use lib qw(lib);
use File::chdir;
use Cwd;
use strict;
use warnings;
use JSON;
use utf8;
use Data::Dumper;

use Android::Module;

use XML::Smart;

sub new{
    my $class = shift;
    my $self = {
        _module => shift
    };
    bless $self, $class;

    return $self;
}

sub get_container{
    my ($this, $xml) = @_;

    my $module = new Module($this->{_module});
    my $xml_path = $module->xml($xml);

    my $xml_obj = XML::Smart->new($xml_path);
    $xml_obj = $xml_obj->cut_root;

    my $container = $xml_obj->find_child('android:id', 'eq', '@id/container');
    if(!$container){
        print STDERR "WARN:specific the container before getting data..\n";
    }

    return $container;
}


return 1;
