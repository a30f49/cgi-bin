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

sub data{
    my ($this) = @_;

    return $this->{_content};
}

sub package_value{
    my ($this) = @_;

    my $line = $this->package_line;
    $line =~ /\w+\s+([\w\.]+)/;
    $line = $1;

    return $line;
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

sub replace_R_with_package{
    my ($this, $pack) = @_;

    my $data = $this->{_content};
    $data =~ /\wmport\s+([\w\.]+)\.R;/;

    if($1){

        my $line0 = "import $1.R;";
        my $line1 = "import $pack.R;";

        if($line0 ne $line1){

            print "line0: $line0\n";
            print "line1: $line1\n";

            $data =~ s/$line0/$line1/;
            $this->{_content} = $data;

            return 1;
        }
    }

    return 0;
}

sub _parse{
    my ($this) = @_;

    my $data = $this->{_content};

    my @list = split(/\n/, $data);

    my $package_symbol = 'package ';
    my $R_symbol = 'import ';

    foreach(@list){

        if(/$package_symbol/){
            my $p = $_;
            $this->{_package} = $p;
        }elsif(/$R_symbol/){
            if(/\.R/){
                my $r = $_;
                $this->{_R} = $r;
            }
        }
    }
}

return 1;
