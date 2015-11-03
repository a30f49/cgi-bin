package JavaContent;
use lib qw(lib);
use strict;
use warnings;

sub new{
    my $class = shift;
    my $self = {
        _content => shift,
        _package => undef,
        _R => undef
    };
    bless $self, $class;
    return $self;
}

sub package_line{
    my ($this) = @_;

    if(!$this->{_package}){
        $this->_parse;
    }

    return $this->{_package};
}

sub R_line{
    my ($this) = @_;

    if(!$this->{_R}){
        $this->_parse;
    }

    return $this->{_R};
}


sub _parse{
    my ($this) = @_;

    my $data = $this->{_content};

    my @list = split(/\n/, $data);

    my $package_symbol = 'package ';
    my $R_symbol = 'import ';

    foreach(@list){

        if(/$package_symbol/){
            $this->{_package} = $_;
        }elsif(/$R_symbol/){
            if(/\.R/){
                $this->{_R} = $_;
            }
        }
    }
}

return 1;
