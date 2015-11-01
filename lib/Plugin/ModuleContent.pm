package ModuleContent;
=head1
    Get module common-used content: Package, etc.

    my $module_data = new ModuleContent('app');
    my $pack = $module_data->pack;
    print $pack;

    Output
    $ com.jfeat.apps.sample

=cut

use lib qw(lib);
use strict;
use warnings;

use Android::Module;
use Android::Manifest;

sub new{
    my $class = shift;
    my $self = {
        _module => shift
    };
    bless $self, $class;
    return $self;
}

sub module{
   my ($this, $mod) = @_;
   if($mod){
       $this->{_module} = $mod;
   }
   return $this->{_module};
}

#####################
## get root package #
#####################
sub pack{
    my ($this) = @_;

    my $mod = $this->{_module};

    my $module = new Module($mod);
    my $manifest_path = $module->manifest;
    my $manifest = new Manifest($manifest_path);
    my $target_pack = $manifest->pack;

    return $target_pack;
}

#####################
## get app package #
#####################
sub pack_to_app{
    my ($this) = @_;

    my $pack = $this->pack;
    return "$pack.app";
}

#####################
## get gen package #
#####################
sub pack_to_gen{
    my ($this) = @_;

    my $pack = $this->pack;
    return "$pack.gen";
}

#####################
## get test package #
#####################
sub pack_to_test{
    my ($this) = @_;

    my $pack = $this->pack;
    return "$pack.test";
}

#####################
## get path to the package #
#####################
sub path_to_pack{
    my ($this) = @_;
    my $mod = $this->{_module};

    my $gr = new GradleRoot();
    my $mod_root = $gr->module_root($mod);
    my $gradle = new Gradle($mod_root);

    my $src = $gradle->src;
    my $src_path = "$mod_root/$src";

    my $path  = $this->pack;
    $path =~ tr/\./\//;

    $path = "$src_path/$path";

    return $path;
}

#####################
## get path to the app package #
#####################
sub path_to_app{
    my ($this) = @_;
    my $path = $this->path_to_pack;

    return "$path/app";
}

#####################
## convert package to path #
#####################
sub pack_to_path{
    my ($this, $pack) = @_;
    my $mod = $this->{_module};

    my $gr = new GradleRoot();
    my $mod_root = $gr->module_root($mod);
    my $gradle = new Gradle($mod_root);

    my $src = $gradle->src;
    my $src_path = "$mod_root/$src";

    my $path  = $pack;
    $path =~ tr/\./\//;

    $path = "$src_path/$path";

    return $path;
}


#######################
## locate fragment package
######################
sub locate{
    my ($this, $frag) = @_;

    my $mod = $this->{_module};

    my $pack_path = $this->path_to_pack;
    my $app_path = $this->path_to_app;
    my $manifest_pack = $this->pack;
    my $app_pack = $this->pack_to_app;

    if(-f "$pack_path/$frag.java"){
        return "$manifest_pack.$frag";
    }elsif(-f "$app_path/$frag.java"){
        return "$app_pack.$frag";
    }

    print STDERR "ModuleContent: fail to locate $frag\n";

    return undef;
}


return 1;
