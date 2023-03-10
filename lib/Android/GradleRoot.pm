package GradleRoot;
use lib qw(lib);
use Path;

use Android;

use File::Reader;

sub new{
    my $class = shift;
    my $self = {
        _root => undef
    };

    my $path = new Path();
    my $cwd = $path->path;

    if($cwd =~ /cgi-bin$/){
        $self->{_root} = $path->parent;
    }elsif(Android::is_android_one){
        $self->{_root} = $path->parent;
    }elsif(Android::is_android_pack){
        $self->{_root} = $cwd;
    }else{
        print STDERR "fatal: Not an android repository.\n";
    }

    bless $self, $class;
    return $self;
}

sub root{
    my $this = shift;
    return $this->{_root};
}

sub module_root{
    my ($this, $module_name) = @_;

    my $root = $this->{_root};
    my $path = new Path($root)->with($module_name)->path;
    return $path;
}

## get modules from settings.gradle
sub modules{
    my $this = shift;
    my $root = $this->{_root};

    my $path = "$root/settings.gradle";

    my @lines;
    my @list = new Reader($path)->list;
    foreach(@list){
        if(/^\/\//){
        }else{
            push(@lines, $_);
        }
    }

    my $data = join(' ', @lines);

    ## start to parse
    $data =~ s/include//g;
    my @modules = split(/[\s:,\'\n]/, $data);

    my @list;
    foreach(@modules){
        if($_ =~ /^\S+$/){
            push @list, $_;
        }
    }
    return @list;
}


return 1;
