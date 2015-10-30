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

sub gradle{
    my ($this) = @_;
    my $module_name = $this->{_module};
    my $gr = new GradleRoot();
    my $module_root = $gr->module_root($module_name);

    return "$module_root/build.gradle";
}

sub manifest{
    my ($this) = @_;

    my $module_name = $this->{_module};

    my $gr = new GradleRoot();
    my $module_root = $gr->module_root($module_name);
    my $gradle = new Gradle($module_root);
    my $manifest_relative = $gradle->manifest;

    my $xml_path = new Path($module_root)->with($manifest_relative)->path;
    return $xml_path;
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

sub get_xml{
    my ($this, $xml) = @_;
    return $this->xml($xml);
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

my $_fragments;
sub src_fragments{
    my ($this) = @_;
    my $module_name = $this->{_module};

    my $gr = new GradleRoot();
    my $module_root = $gr->module_root($module_name);
    my $gradle = new Gradle($module_root);

    my $src_relative = $gradle->src;
    my $src_path = new Path($module_root)->with($src_relative)->path;

    $_fragments = undef;
    File::Find::find(\&find_all, $src_path);

    my @list;
    my @fragments = @{$_fragments};

    for(@fragments){
        my $full = $_;

        $full =~ s/^$module_root\///;
        $full =~ s/^$src_relative\///;
        $full =~ tr/\//\./;

        push(@list, $full);
    }

    return @list;
}

sub find_all{
    if(/Fragment\.java$/){
        if(/DialogFragment\.java$/){
            next; #skip dialog fragment
        }

        if(-f $_){
            push(@{$_fragments}, File::Spec->rel2abs($_));
        }
    }
}


return 1;
