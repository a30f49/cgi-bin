package Binding;
use lib qw(lib);
use strict;
use warnings;

use Data::Dumper;

use Plugin::TemplateProvider;

sub new{
    my $class = shift;
    my $self = {
        _class => shift
    };
    bless $self, $class;
    return $self;
}

sub class{
    my $this = shift;
    return $this->{_class};
}

sub get_root{
    my ($this, $template) = @_;

    my $item_root = $template;

    my $t = ref $template;

    if($t eq "XML::Smart"){
        $item_root = $template;
    }else{
        my $provider = new TemplateProvider();
        $item_root = $provider->get_root($template);
    }

    return $item_root;
}


sub bind_input_item{
    my ($this, $data, $template) = @_;

    my $container_item = $this->get_root($template);

    ## read data
    my $cls = $this->class;
    my $field = $data->{field}; ## desk:name;
    my $title = $data->{title};
    my $hint = $data->{hint};
    #print "(field,title,hint)=>($field,$title,$hint)\n";
    my $id = '@+id/'.$cls.'_'.$field;

    ## set data
    my $title_view = $container_item->find_child('android:id', 'eq', '@id/title');
    if(!$title_view){
        print STDERR 'fail to find the view with @id/title'."\n";
    }
    $title_view->{'android:text'} = $title;
    delete $title_view->{'android:id'};

    my $hint_view = $container_item->find_child('android:id', 'eq', '@id/value');
    if(!$hint_view){
        print STDERR 'fail to find the view with @id/value'."\n";
    }
    $hint_view->{'android:hint'} = $hint;
    $hint_view->{'android:id'} = $id;
    ## end binding

    return $container_item;
}


return 1;
