package ModuleContent;
=head1
    Get module common-used content, Package, etc.

    my $module_data = new ModuleData('app');
    my $pack = $module_data->pack;

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

sub pack{
    my ($this) = @_;

    my $mod = $this->{_module};

    my $module = new Module($mod);
    my $manifest_path = $module->manifest;
    my $manifest = new Manifest($manifest_path);
    my $target_pack = $manifest->pack;

    return $target_pack;
}

sub pack_to_app{
    my ($this) = @_;

    my $pack = $this->pack;
    return "$pack.app";
}

sub pack_to_gen{
    my ($this) = @_;

    my $pack = $this->pack;
    return "$pack.gen";
}

sub pack_to_test{
    my ($this) = @_;

    my $pack = $this->pack;
    return "$pack.test";
}


sub path_to_app{
    my ($this) = @_;
    my $mod = $this->{_module};

    my $gr = new GradleRoot();
    my $mod_root = $gr->module_root($mod);
    my $gradle = new Gradle($mod_root);

    my $src = $gradle->src;
    my $src_path = "$mod_root/$src";

    my $app_path  = $this->pack_to_app;
    $app_path =~ tr/\./\//;

    $app_path = "$src_path/$app_path";

    return $app_path;
}

#######################
## get fragment package
######################
sub locate{
    my ($this, $frag) = @_;

    my $mod = $this->{_module};

    my $manifest_pack = $this->pack_to_app;

    my $fragment_pack = "$manifest_pack.$frag";

    return $fragment_pack;
}


return 1;
