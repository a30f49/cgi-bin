package Module;
use lib qw(lib);
use File::Dir;

use Android::GradleRoot;
use Android::Gradle;

sub new{
    my $class = shift;
    my $self = {
        _module => shift
    };

    bless $self, $class;
    return $self;
}

sub manifest{
    my ($this) = @_;

    my $module_name = $this->{_module};

    my $gr = new GradleRoot();
    my $module_root = $gr->module_root($module_name);
    my $gradle = new Gradle($module_root);
    my $manifest_relative = $gradle->manifest;

    my $xml_path = new Path($module_root)->with($manifest_relative)->path;
}

sub xml{
    my ($this, $xml) = @_;
    my $module_name = $this->{_module};

    my $gr = new GradleRoot();
    my $module_root = $gr->module_root($module_name);
    my $gradle = new Gradle($module_root);

    my $xml_relative = $gradle->xml($xml);
    my $xml_path = new Path($module_root)->with($xml_relative)->path;
    return $xml_path;
}

sub src{
    my ($this, $package, $class) = @_;
    my $module_name = $this->{_module};

    ## package(.) to path(/)
    $package =~ tr/\./\//;
    if(!$class){
        $package =~ s/\.java$//;
        $package = $package.".java";
    }else{
        $class =~ s/\.java$//;
        $class = $class.".java";
    }
    #print "(package,class)=>($package,$class)\n";

    my $gr = new GradleRoot();
    my $module_root = $gr->module_root($module_name);
    my $gradle = new Gradle($module_root);

    my $src = $gradle->src;

    my $xml_path = new Path($module_root)->with($src)->with($package)->with($class)->path;
    return $xml_path;
}

sub xml_all{
    my ($this) = @_;

    my $module_name = $this->{_module};

    my $gr = new GradleRoot();
    my $module_root = $gr->module_root($module_name);
    my $gradle = new Gradle($module_root);
    my $layout = $gradle->layout;
    my $layout_root = "$module_root/$layout_root";

    my $dir = new Dir($layout_root);

    return $dir->files;
}

return 1;
