package Binding;
use lib qw(lib);
use strict;
use warnings;

use Data::Dumper;

sub new{
    my $class = shift;
    my $self = {
    };
    bless $self, $class;
    return $self;
}

#########################
## bind test item for single page test #
#########################
sub bind_test_item{
    my ($this, $item, $template) = @_;

    my $id = $item->{id};
    my $title = $item->{title};

    my $child_id = $template->find_child('android:id');
    $child_id->{'android:id'} = $id;

    my $child_title = $template->find_child('android:text');
    $child_title->{'android:text'} = $title;

    return $template;
}

#########################
## bind input item for form #
#########################
sub bind_input_item{
    my ($this, $item, $template) = @_;

    ## read data
    my $id = $item->{id}; ## desk:name;
    my $title = $item->{title};
    my $hint = $item->{hint};
    #print "(id,title,hint)=>($id,$title,$hint)\n";

    ## set data
    my $title_view = $template->find_child('android:id','eq', '@id/title');
    if(!$title_view){
        print STDERR 'fail to find the view with \'@id/title\''."\n";
    }
    $title_view->{'android:text'} = $title;
    delete $title_view->{'android:id'};

    my $field_view = $template->find_child('android:id', 'eq', '@id/value');
    if(!$field_view){
        print STDERR 'fail to find the view with \'@id/value\''."\n";
    }
    $field_view->{'android:hint'} = $hint;
    $field_view->{'android:id'} = $id;
    ## end binding

    return $template;
}


return 1;
