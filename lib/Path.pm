package Path;
use lib qw(lib);
use File::Spec;

sub new{
    my $class = shift;
    my $self = {
        _root    => shift,
    };

    if(!$self->{_root}){
        my $path = File::Spec->rel2abs(".");
        $self->{_root} = $path;
    }

    bless $self, $class;
    return $self;
}

sub root{
    my $this = shift;
    return $this->{_root};
}

sub path{
    my $this = shift;
    return $this->{_root};
}

sub last_segment{
    my $this = shift;
    my $path = $this->{_root};

    $path =~ /.+\/(.+)$/;
    return $1;
}

sub parent{
    my ($this) = @_;

    my $root = $this->{_root};
    my $parent = pop_path($root);
    return $parent;
}

sub pop{
    my ($this) = @_;
    my $path = $this->{_root};

    my $parent = pop_path($path);
    $this->{_root} = $parent;

    return $this;
}

sub with{
    my ($this, $path) = @_;

    my $root = $this->{_root};
    my $new_path = make_path($root, $path);

    $this->{_root} = $new_path;

    return $this;
}


##  static methods
##
sub make_path{
   my ($root, $path) = @_;

   chomp($path);

   if($path=~/^\//){
     return $root.$path;
   }

   return $root."/".$path;
}

sub pop_path{
   my ($path) = shift;
   $path =~ s/\/[-\w]+$//;
   return $path;
}

return 1;
