package Module;
use lib qw(lib);
use File::Find;
use File::Spec;
use Path;

my $this;

sub new{
    my $class = shift;
    my $self = {
        _path        => shift,
        _path_res    => undef,
        _path_src    => undef,
        _path_assets => undef,
        _manifest    => undef,
        _gradle      => undef
    };

    bless $self, $class;
    $this = $self;

    my $full = $self->{_path};
    File::Find::find(\&find_all, $full);

    ## start to find the resource paths
    $this = $self;
    return $self;
}

sub find_all{
    if(-d $_){
        if(/\/build\//i){
            next;
        }

        if(/^res$/){
            $this->{_path_res} = File::Spec->rel2abs($_);
        }elsif(/^src$/){
            $this->{_path_src} = File::Spec->rel2abs($_);
        }elsif(/^assets$/){
            $this->{_path_assets} = File::Spec->rel2abs($_);
        }
    }

    if(-f $_){
        if(/^AndroidManifest.xml$/i){
            $this->{_manifest} = File::Spec->rel2abs($_);
        }elsif(/^build.gradle$/i){
            $this->{_gradle} = File::Spec->rel2abs($_);
        }
    }
}

sub is_android_module{
    my ($this) = @_;
    if($this->{_manifest}){
        return 1;
    }
    return 0;
}

sub name{
    my ($this) = @_;
    my $full = $this->{_path};

    $full =~ /.+\/(.+)$/;
    return $1;
}

sub path{
   my ($this) = @_;
   return $this->{_path};
}

sub path_res{
   my ($this) = @_;
   return $this->{_path_res};
}

sub path_src{
   my ($this) = @_;
   return $this->{_path_src};
}

sub path_src_main{
   my ($this) = @_;
   my $src = $this->{_path_src};
   return new Path($src)->with("main/java")->path;
}

sub path_src{
   my ($this) = @_;
   my $src_dir = $hash{src};
   return new Path($src_dir)->with("main/java")->path;
}

sub path_assets{
   my ($this) = @_;
   return $this->{_assets};
}

sub manifest{
   my ($this) = @_;
   return $this->{_manifest};
}

sub gradle{
   my ($this) = @_;
   return $this->{_gradle};
}

sub path_res_layout{
   my ($this) = @_;
   my $path_res  = $this->{_res};

   return new Path($path_res)->with("layout")->path;
}

return 1;
