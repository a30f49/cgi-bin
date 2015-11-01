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

sub bind_test_item{
    my ($this, $item, $template) = @_;

    my $id = $item->{id};
    my $title = $item->{title};

    my $child_id = $template->find_child('android:id');
    $child_id->{'android:id'} = $id;

    my $child_id = $template->find_child('android:id');
    $child_id->{'android:text'} = $title;

    return $template;
}

#########################
### param: cls - class name for field prefix
#########################
sub bind_input_item{
    my ($this, $item, $template) = @_;

    ## read data
    my $cls = $this->class;
    my $field = $item->{field}; ## desk:name;
    my $title = $item->{title};
    my $hint = $item->{hint};
    #print "(field,title,hint)=>($field,$title,$hint)\n";
    my $id = '@+id/'.$field;

    ## set data
    my $title_view = $template->find_child('android:text');
    if(!$title_view){
        print STDERR 'fail to find the view with \'android:text\''."\n";
    }
    $title_view->{'android:text'} = $title;

    my $hint_view = $template->find_child('android:hint');
    if(!$hint_view){
        print STDERR 'fail to find the view with \'android:hint\''."\n";
    }
    $hint_view->{'android:hint'} = $hint;
    $hint_view->{'android:id'} = $id;
    ## end binding

    return $template;
}


return 1;
