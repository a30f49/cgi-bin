package Template;
use lib qw(lib);
use Android::GradleRoot;
use Android::Gradle;

use Android::Module;
our @ISA = qw(Module);

use File::Dir;

sub new{
    my $class = shift;
    my $self = $class->SUPER::new( @_ );

    bless $self, $class;
    return $self;
}

sub new{
    my $class = shift;

    my $self = $class->SUPER::new( 'plugin-template' );
    bless $self, $class;

    return $self;
}

sub module{
    my $this = shift;
    return 'plugin-template';
}

sub templates{
    my ($this) = @_;

    my $layout = $this->layout;
    my $dir= new Dir($layout);
    my @list = $dir->files;

    return @list;
}

sub get_src{
    my ($this, $which) = @_;

    my $module_root = $this->root;
    my $src_path = $this->src;
    my $pack_path = "com/jfeat/plugin/template";

    my $r = new Path($src_path)->with($pack_path)->with($which)->path;
    $r  =~ s/\.java$//;
    $r = $r.".java";

    return $r;
}

#######################
## check layout or src exists #
#########################
sub is_exists{
    my ($this, $which) = @_;

    if($which =~ /\.java/){
        my $path = $this->src($which);
        if(-f $path){
            return 1;
        }

    }else{
        my $path = $this->xml($which);
        if(-f $path){
            return 1;
        }
    }

    return 0;
}

return 1;