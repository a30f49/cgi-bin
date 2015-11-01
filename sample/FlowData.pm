package FlowStack;
use lib qw(lib);
use File::chdir;
use Cwd;
use strict;
use warnings;
use Data::Dumper;
use JSON;
use XML::Smart;
use utf8;

use File::Writer;

use Android::Module;

sub new{
    my $class = shift;
    my $self = {
        _module => shift,
        _target => undef,
        _data   => undef,
    };
    bless $self, $class;

    return $self;
}

sub module{
    my ($this, $module) = @_;

    if(!$module){
        $module = $this->{_module};
    }
    return $module;
}

sub get_data{
    my ($this, $xml) = @_;
    $this->{_target} = $xml;

    ## declare data as hash
    my $data = {};

    my $module = new Module($this->module);
    my $xml_path = $module->xml($xml);
    #print "xml-path:$xml_path\n";

    my $xml_obj = XML::Smart->new($xml_path);

    my $container = $xml_obj->find_child('android:id', 'eq', '@id/container');
    if(!$container){
        print STDERR "WARN:specific the container before getting data..\n";
    }

    my $first_child = $container->first_child;
    my $key = $first_child->key;

    my @children = @{$container->{$key}};

    foreach(@children){
        my $item = $_;

        my $data_item = {};
        my $id =  $item->{'android:id'};
        my $text = $item->{'android:text'};
        #print "(id,text)=>($id,$text)\n";

        $data_item->{'title'} = "$text";
        $data_item->{'id'}   = "$id";

        push(@{$data->{items}}, $data_item);
    }

    $this->{_data} = $data;
    return $data;
}

sub json{
    my ($this) = @_;

    my $data = $this->{_data};

    my $json_data = JSON->new->encode($data);
    return $json_data;
}

sub json_ready{
    my ($this) = @_;

    my $module_name = $this->{_module};
    my $target = $this->{_target};
    $target =~ s/\.xml/_smart\.xml/;

    my $item_data = $this->{_data};
    my $group = {
        'name'  => undef,
        'items' => $item_data->{items}
    };

    my $data = {
        'module' => $module_name,
        'target' => $target
    };

    push( @{$data->{groups}}, $group);

    my $json_data = JSON->new->encode($data);
    return $json_data;
}

sub save{
    my ($this, $out, $json) = @_;

    my $writer = new Writer();

    if(!$json){
        $json = $writer->{_data};
    }

    $writer->write_new($out, $json);
}


return 1;
