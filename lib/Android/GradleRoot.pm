package GradleRoot;
use lib qw(lib);
use Path;

sub new{
    my $class = shift;
    my $self = {
        _root => undef
    };

    $self->{_root} = new Path()->path;
    if($self->{_root} =~ /cgi-bin$/){
        $self->{_root} = new Path()->parent;
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

    ## get content from file
    my $data;
    {
      local $/; #Enable 'slurp' mode
      open my $fh, "<", "$root/settings.gradle";
      $data = <$fh>;
      close $fh;
    }

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
