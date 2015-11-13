package Gradle;
use lib qw(lib);
use Path;

sub new{
    my $class = shift;
    my $self = {
        _module_root   => shift,
        _plugin   => undef,
        _manifest => undef,
        _res      => undef,
        _src      => undef,
        _assets   => undef
    };

    bless $self, $class;
    return $self;
}

######################
## root path
#######################
sub module_root{
    my $this = shift;
    return $this->{_module_root};
}

sub is_android{
    my ($this) = @_;

    my $plugin = $this->plugin();
    if($plugin =~ /android/){
        return 1;
    }
    return 0;
}

sub plugin{
    my $this = shift;
    if($this->{_plugin}){
        return $this->{_plugin};
    }

    my $module_root = $this->{_module_root};
    $this->_parse($module_root);

    return $this->{_plugin};
}


#get relative path
sub manifest{
    my ($this) = @_;
    if($this->{_manifest}){
        return $this->{_manifest};
    }

    my $module_root = $this->{_module_root};
    $this->_parse($module_root);

    if($this->{_manifest}){
        return $this->{_manifest};
    }

    return $this->{_manifest} = "src/main/AndroidManifest.xml";
}

sub res{
    my ($this) = @_;
    if($this->{_res}){
        return $this->{_res};
    }

    my $module_root = $this->{_module_root};
    $this->_parse($module_root);

    if($this->{_res}){
        return $this->{_res};
    }

    return $this->{_res} = "src/main/res";
}

sub layout{
    my ($this) = @_;
    my $res = $this->res;
    return new Path($res)->with("layout")->path;
}

sub src{
    my ($this) = @_;
    if($this->{_src}){
        return $this->{_src};
    }

    my $module_root = $this->{_module_root};
    $this->_parse($module_root);

    if($this->{_src}){
        return $this->{_src};
    }

    return $this->{_src} = "src/main/java";
}

sub assets{
    my ($this) = @_;
    if($this->{_assets}){
        return $this->{_assets};
    }

    my $module_root = $this->{_module_root};
    $this->_parse($module_root);

    if($this->{_assets}){
        return $this->{_assets};
    }

    return $this->{_assets} = "src/main/assets";
}

################
## private sub
####################
sub _parse{
    my ($this, $module_root) = @_;

    my $data;
    {
      local $/; #Enable 'slurp' mode
      open my $fh, "<", "$module_root/build.gradle";
      $data = <$fh>;
      close $fh;
    }

    $data =~ tr/\r\n/ /;

    ## match plugin
    if($data =~ /apply\s+plugin:\s+'([\w\.]+)'/){
       my $plugin = $1;
       $this->{_plugin} = $plugin;
    }

    ## match manifest
    if($data =~ /manifest.srcFile\s+'([\w\.]+)'/){
       my $manifest = $1;
       $this->{_manifest} = $manifest;
    }

    ## match res
    if($data =~ /res.srcDir[s=\[\s]+'([\w\.\/]+)'[\]]*/){
       my $res = $1;
       if($res !~ /test/){
            $this->{_res} = $res;
       }
    }

    ## match src
    if($data =~ /java.srcDir[s=\[\s]+'([\w\.\/]+)'[\]]*/){
       my $src = $1;
       if($src !~ /test/){
            $this->{_src} = $src;
       }
    }

    ## match assets
    if($data =~ /assets.srcDir[s=\[\s]+'([\w\.\/]+)'[\]]*/){
       my $assets = $1;
       if($assets !~ /test/){
            $this->{_assets} = $assets;
       }
    }

    #print $data;
}



return 1;
