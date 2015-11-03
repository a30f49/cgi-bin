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
## path to src #
#######################
sub src{
    my ($this) = @_;

    my $module_root = $this->root;
    my $gradle = new Gradle($module_root);

    my $src_relative = $gradle->src;
    my $path = new Path($module_root)->with($src_relative)->path;
    return $path;
}

######################
## path to res #
#######################
sub res{
    my ($this) = @_;

    my $module_root = $this->root;
    my $gradle = new Gradle($module_root);

    my $res_relative = $gradle->res;
    my $path = new Path($module_root)->with($res_relative)->path;
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

return 1;
