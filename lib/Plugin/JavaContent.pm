package JavaContent;
use lib qw(lib);
use strict;
use warnings;

sub new{
    my $class = shift;
    my $self = {
        _content => shift,
        _list => undef,
    };
    bless $self, $class;

    my $data = $self->{_content};
    my @list = split(/\n/, $data);
    $self->{_list} = \@list;

    return $self;
}

sub data{
    my ($this) = @_;
    return $this->{_content};
}

sub list{
    my ($this) = @_;
    my @list = @{$this->{_list}};

    return @list;
}

sub package_line{
    my ($this) = @_;
    my @list = $this->list;

    my $package_symbol = 'package ';
    foreach(@list){
        if(/$package_symbol/){
            return $_;
        }
    }
    return undef;
}

sub package_value{
    my ($this, $package_line) = @_;
    if(!$package_line){
        $package_line = $this->package_line;
    }

    my $line = $package_line;
    $line =~ /\w+\s+([\w\.]+)/;
    $line = $1;

    return $line;
}

sub append_import_line{
    my ($this, $line) = @_;
    $line =~ s/^\s*//;

    ## check 'import '
    my $import_symbol = 'import ';
    if($line !~ /$import_symbol/){
        $line = $import_symbol.$line;
    }
    ## check ;
    if($line !~ /\;$/){
        $line = $line . ';';
    }

    ##TODO,

}

sub import_lines{
    my ($this) = @_;

    my @list = $this->list;

    my @lines;

    my $import_symbol = 'import ';
    foreach(@list){
        if(/$import_symbol/){
            push(@lines, $_);
        }
    }

    return @lines;
}

sub R_line{
    my ($this) = @_;

    my @list = $this->list;

    my $R_symbol = 'import ';
    foreach(@list){
        if(/$R_symbol/){
            if(/\.R/){
                return $_;
            }
        }
    }
    return undef;
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



return 1;
