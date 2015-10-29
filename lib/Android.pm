package Android;
use lib qw(lib);
use Path;

sub new{
    my $class = shift;
    my $self = {
    };

    bless $self, $class;
    return $self;
}

sub is_android_root{
    my ($this) = @_;
    return &is_android_pack || &is_android_one;
}

sub is_android_one{
    my ($this) = @_;

    if(-f 'settings.gradle'){
        return 0;
    }

    if(-f 'build.gradle'){
        return 1;
    }

    return 0;
}

sub is_android_pack{
    my ($this) = @_;

    if(-f 'settings.gradle'){
        return 1;
    }

    return 0;
}

return 1;
