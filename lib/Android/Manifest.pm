package Manifest;
use lib qw(lib);
use Path;
use XML::Smart;

sub new{
    my $class = shift;
    my $self = {
        _path => shift,
        _the_obj => undef
    };

    bless $self, $class;
    return $self;
}

sub pack{
    my ($this) = @_;

    my $xml_obj = $this->_the_obj;
    my $pack = $xml_obj->{'package'};

    return $pack;
}

sub activities{
    my ($this) = @_;

    my $xml_obj = $this->_the_obj;

    my @list;

    my @acts = @{$xml_obj->{application}->{activity}};
    foreach(@acts){
        my $act = $_;
        push(@list, $act->{'android:name'});
    }

    return @list;
}

sub activity_exists{
    my ($this, $act_name) = @_;
    my @acts = $this->activities;

    foreach(@acts){
        my $name = $act->{'android:name'};
        if($act_name eq $name){
            return 1;
        }
    }
    return 0;
}

sub append_activity_with_name{
    my ($this, $act_name) = @_;

    my $xml_obj = $this->_the_obj;
    my $app = $xml_obj->{application};

    ## find act with name
    my $the_act = $app->{activity}('android:name','eq',$act_name);

    if($the_act){
        $the_act->{'android:name'} = $act_name;
    }else{
        my $act = {
            'android:name' => $act_name
        };
        push(@{$app->{activity}}, $act);
    }
}

sub save{
    my ($this, $manifest_path) = @_;

    if(!$manifest_path){
        $manifest_path = $this->{_path};
    }

    $this->_the_obj->save($manifest_path);
}


####################
## dump     #
#####################
sub dump_activities{
    my ($this) = @_;
    my @acts = $this->activities;
    foreach(@acts){
        print;
        print "\n";
    }
}

####################
## private sub   #
#####################
sub _the_obj{
    my ($this) = @_;

    my $xml_obj = $this->{_the_obj};
    if(!$xml_obj){
        my $path = $this->{_path};
        $xml_obj = XML::Smart->new($path);
        $xml_obj = $xml_obj->cut_root;

        $this->{_the_obj} = $xml_obj;
    }

    return $this->{_the_obj};
}

return 1;
