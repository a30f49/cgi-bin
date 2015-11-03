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
## get package with a short package #
#####################
sub pack_with{
    my ($this, $short_pack) = @_;
    if(!$short_pack){
        return $this->pack;
    }

    my $pack = $this->pack;
    if($short_pack !~ /^\./){
        $short_pack = ".$short_pack";
    }
    return "$pack$short_pack";
}

#####################
## cut the root package for a given package #
## and return the short package
#####################
sub pack_cut{
    my ($this, $pack) = @_;

    my $p = $this->pack;

    $pack =~ s/$p//;
    return $pack;
}

#########################
## get package from path #
#########################
sub pack_from_path{
    my ($this, $path) = @_;

    my $mod = $this->{_module};
    my $module = new Module($mod);

    my $cut = $module->src;

    my $pack = $path;
    $pack =~ s/\.java//;  ## cut java
    $pack =~ s/$cut//;    ## cut path
    $pack =~ tr/\//\./;
    $pack =~ s/^\.//;

    return $pack;
}

#####################
## return the path to the package #
#####################
sub path_to_pack{
    my ($this, $pack) = @_;
    if(!$pack){
        $pack = $this->pack;
    }else{
        ## means short pack
        if($pack =~ /^\.*\w+$/){
            $pack = $this->pack_with($pack);
        }
    }

    ## get root path
    my $mod = $this->{_module};
    my $module  = new Module($mod);
    my $src_path = $module->src;

    ## convert pack to path
    my $path  = $pack;
    $path =~ tr/\./\//;
    $path = "$src_path/$path";

    return $path;
}

#######################
## locate fragment package
######################
sub locate{
    my ($this, $java, $short_pack) = @_;
    $java =~ s/\.java$//;
    $java = "$java.java";

    my $pack = $this->pack_with($short_pack);
    my $pack_path = $this->path_to_pack($pack);
    my $java_path = "$pack_path/$java";

    return $java_path;
}

sub locate_verify{
    my ($this, $java, $short_pack) = @_;

    my $java_path = $this->locate($java, $short_pack);

    if(!(-f $java_path)){
        print STDERR "$java_path not exists\n";
        return undef;
    }

    return $java_path;
}



return 1;
