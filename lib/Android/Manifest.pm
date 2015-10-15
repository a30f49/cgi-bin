package Manifest;
use lib qw(lib);
use Path;
use XML::Smart;

sub new{
    my $class = shift;
    my $self = {
        _path => shift,
        _obj  => undef
    };

    bless $self, $class;
    return $self;
}

sub the_obj{
    my ($this) = @_;

    my $path = $this->{_path};
    my $xml_obj = $this->{_obj};
    if(!$xml_obj){
        $xml_obj = XML::Smart->new($path);
        $this->{_obj} = $xml_obj;
    }

    return $xml_obj->cut_root;
}

sub pack{
    my ($this) = @_;

    my $xml_obj = $this->the_obj;
    my $pack = $xml_obj->{'package'};

    return $pack;
}

sub activities{
    my ($this) = @_;

    my $xml_obj = $this->the_obj;

    my @list;

    my @acts = @{$xml_obj->{application}->{activity}};
    foreach(@acts){
        my $act = $_;
        push(@list, $act->{'android:name'});
    }

    return @list;
}

sub dump_activities{
    my ($this) = @_;
    my @acts = $this->activities;
    foreach(@acts){
        print;
        print "\n";
    }
}

sub append_activity_with_name{
    my ($this, $act_name) = @_;

    my $xml_obj = $this->the_obj;
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

sub activity_exists{
    my ($this, $act_name) = @_;



}

sub save{
    my ($this, $manifest_path) = @_;
    if(!$manifest_path){
        $manifest_path = $this->{_path};
    }

    my $xml_obj = $this->{_obj};
    $xml_obj->save($manifest_path);
}

return 1;
