package Flow;
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
use Plugin::SmartWrapper;

sub new{
    my $class = shift;
    my $self = {
        _target_module => shift,
        _xml_obj => undef,
        _container_template         => undef,
        _container_item_template    => undef,
        _divider_template           => undef,
        _divider_group_template     => undef
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


## gen the xml
sub gen{
    my ($this, $groups) = @_;

    my $container_template = $this->container_template;
    my $container_item_template = $this->container_item_template;
    my $divider_template = $this->divider_template;
    my $divider_group_template = $this->divider_group_template;

    my $template = new Template();
    my $wrapper = new SmartWrapper();
    ## never change
    my $container_xml = $template->get_xml($container_template);
    my $container = $wrapper->from_xml($container_xml)->cut_root;
    #my $container = get_root($container_xml);
    my $container_tree = $container->last_child_of_tree;
    $container = $container->last_child;

    #my $container_root_key = $container->root;
    #my $container_last_key = $container->key;
    #print "container(root,last)=>($container_root_key, $container_last_key)\n";
    #print Dumper($container_tree);


    ## never change
    my $divider_xml = $template->get_xml($divider_template);
    my $divider = $wrapper->from_xml($divider_xml);
    my $divider_tree = $wrapper->get_tree();
    #my $divider = get_root($divider_xml);
    #my $divider_tree = get_tree($divider);
    my $divider_key = $divider->key;
    ## group
    my $divider_group_xml = $template->get_xml($divider_group_template);
    my $divider_group = $wrapper->from_xml($divider_group_xml)->cut_root;
    my $divider_group_tree = $wrapper->get_tree();
    #my $divider_group = get_root($divider_group_xml);
    #my $divider_group_tree = get_tree($divider_group);
    my $divider_group_key = $divider_group->key;
    #print "divider_key,divider_group_key($divider_key,$divider_group_key)\n";
    #print Dumper($divider_tree);

    ## foreach groups
    my @groups = @{$groups};
    my $group_start;
    my $container_item_key;
    foreach(@groups){
      my $group = $_;
      $group_start = 1;

      my @items = @{$group->{items}};

      foreach(@items){

        my $item = $_;
        my $title = $item->{title};
        my $id = $item->{id};
        $id =~ s/R\.id\.//;
        if($id !~ /^@\+id\//){
            $id = "@\+id/$id";
        }
        #print "title,id($title,$id)\n";

        my $container_item_xml = $template->get_xml($container_item_template);
        my $container_item = $wrapper->from_xml($container_item_xml);
        my $container_item_tree = $wrapper->get_tree();
        #my $container_item = get_root($container_item_xml);
        #my $container_item_tree = get_tree($container_item);
        $container_item_key = $container_item->key;

        ## set values
        {
            ## init id
            $container_item->{'android:id'} = $id;

            ## init image
            #my $imageview = $container_item->{ImageView};
            #if($imageview){
            #    delete $imageview->{'android:id'};
            #}

            ## init title
            my $title_view = $container_item->find_child('android:id', 'eq', '@id/title');
            if(!$title_view){
                print STDERR "ERROR:fail to find title with id=\@id/title\n";
            }
            delete $title_view->{'android:hint'};
            $title_view->{'android:text'} = $title;
            if($container_item->has_child){
                delete $title_view->{'android:id'};
            }
        }

        if($group_start){
            push (@{$container_tree->{$divider_key}}, $divider_group_tree);
            push (@{$container_tree->{'/order'}}, $divider_key);
        }else{
            push (@{$container_tree->{$divider_key}}, $divider_tree);
            push (@{$container_tree->{'/order'}}, $divider_key);
        }
        push(@{$container_tree->{$container_item_key}}, $container_item_tree);
        push (@{$container_tree->{'/order'}}, $container_item_key);

        $group_start = 0;
      }
    }

    ## save $XML
    $this->{_xml_obj} = $container;

    my $xmldata = $container->data ;
    return $xmldata;
}

sub dump_tree{
    my ($this) = @_;
    return $this->{_xml_obj} -> dump_tree;
}

sub save{
    my ($this, $xml) = @_;
    my $XML = $this->{_xml_obj};
    my $target_module = $this->{_target_module};

    my $module = new Module($target_module);
    my $xml_path = $module->xml($xml);
    $XML->save($xml_path);
}



return 1;
