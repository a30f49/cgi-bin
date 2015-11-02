package Module;
use lib qw(lib);
use File::Dir;
use File::Find;
use File::Spec;

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

######################
## path to module root #
#######################
sub root{
    my ($this) = @_;
    my $module_name = $this->{_module};
    my $gr = new GradleRoot();
    my $module_root = $gr->module_root($module_name);

    return $module_root;
}

######################
## path to build.gradle #
#######################
sub gradle{
    my ($this) = @_;

    my $module_root = $this->root;
    return "$module_root/build.gradle";
}

######################
## path to AndroidManifest.xml #
#######################
sub manifest{
    my ($this) = @_;

    my $module_root = $this->root;
    my $gradle = new Gradle($module_root);
    my $manifest_relative = $gradle->manifest;

    my $path = new Path($module_root)->with($manifest_relative)->path;
    return $path;
}


######################
## path to resource layout #
#######################
sub layout{
    my ($this) = @_;

    my $module_root = $this->root;
    my $gradle = new Gradle($module_root);

    my $layout_relative = $gradle->layout;
    my $path = new Path($module_root)->with($layout_relative)->path;
    return $path;
}

######################
## path to individual xml #
#######################
sub xml{
    my ($this, $xml) = @_;

    my $layout = $this->layout;
    my $path = new Path($layout)->with($xml)->path;
    return $path;
}


######################
## path to individual java #
#######################
sub java{
    my ($this, $package, $class) = @_;

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

    my $module_root = $this->root;
    my $gradle = new Gradle($module_root);

    my $src = $gradle->src;

    my $java_path = new Path($module_root)->with($src)->with($package)->with($class)->path;
    return $java_path;
}




return 1;
