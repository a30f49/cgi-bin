package FlowRaw;
=head1
    Read the flow raw data from exiting xml.

=cut

use lib qw(lib);
use File::chdir;
use Cwd;
use strict;
use warnings;
use Data::Dumper;
use JSON;
use XML::Smart;
use utf8;

use XML::Smart;

use Plugin::Tree;

use Plugin::FlowLayout;

sub new{
    my $class = shift;
    my $self = {
        _module => shift
    };
    bless $self, $class;

    return $self;
}

sub get_raw{
    my ($this, $xml) = @_;

    ## declare data as hash
    my $data = {};


    my $provider = new FlowLayout($this->{_module});
    my $container = $provider->get_container($xml);

    my $first_child = $container->first_children;
    my $first_child_key = $first_child->key;
    #print " key:".$first_child_key;print "\n";

    my @children = @{$first_child};
    foreach(@children){
        my $child = $_;
        #print $child->key;print "\n";

        my $ok_child = $child->find_child('android:id');

        my $id =  $ok_child->{'android:id'};
        $ok_child = $child->find_child('android:text');
        my $text = $ok_child->{'android:text'};
        #print "(id,text)=>($id,$text)\n";

        my $data_item = {};
        $data_item->{'title'} = "$text";
        $data_item->{'id'}   = "$id";

        push(@{$data->{items}}, $data_item);
    }

    #my $tree = new Tree($first_child)->tree;
    return $data;
}

return 1;
