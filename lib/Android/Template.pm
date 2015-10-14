package Template;
use lib qw(lib);
use Android::GradleRoot;
use Android::Gradle;
use XML::Smart;

sub new{
    my $class = shift;
    my $self = {
        _module => 'plugin-template',
        _gradle_obj => undef,
    };

    bless $self, $class;

    my $module = $self->{_module};
    my $module_root = new GradleRoot()->module_root($module);

    $self->{_gradle_obj} = new Gradle($module_root);

    return $self;
}

sub get_xml{
    my ($this, $xml) = @_;
    my $gradle = $this->{_gradle_obj};

    my $xml_relative = $gradle->xml($xml);
    my $module_root = $gradle->module_root;

    return new Path($module_root)->with($xml_relative)->path;
}

sub get_src{
    my ($this, $src) = @_;
    my $gradle = $this->{_gradle_obj};

    my $module_root = $gradle->module_root;

    my $pack_path = "com/jfeat/plugin/template";
    my $src_path = $gradle->src;

    my $r = new Path($module_root)->with($src_path)->with($pack_path)->with($src)->path;
    $r  =~ s/\.java$//;
    $r = $r.".java";

    return $r;
}

return 1;