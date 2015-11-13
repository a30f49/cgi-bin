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

sub class_name{
    my ($this) = @_;

    my @list = $this->list;

    foreach(@list){
        if(/class /){
            my $line = $_;
            $line =~ /class\s+(\w+)/;
            $line = $1;
            return $line;
        }
    }
    return undef;
}

sub package_line{
    my ($this) = @_;
    my @list = $this->list;

    foreach(@list){
        if(qr/^package /){
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

sub import_lines{
    my ($this) = @_;

    my @list = $this->list;

    my @lines;

    foreach(@list){
        if(qr/^import /){
            push(@lines, $_);
        }
    }

    return @lines;
}

sub import_line_R{
    my ($this) = @_;

    my @list = $this->list;

    foreach(@list){
        if(qr/^import /){
            if(/\.R;/){
                return $_;
            }
        }
    }
    return undef;
}

sub append_import_line{
    my ($this, $line) = @_;
    if(!$line){return 0;}

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

    my $pattern = qr/^import /;
    my ($head, $tail, $imports) = $this->split_with($pattern);

    push(@{$imports}, $line);

    ## create new content
    my @lines;
    push(@lines, @{$head});
    push(@lines, @{$imports});
    push(@lines, @{$tail});

    $this->{_list} = \@lines;
    $this->{_content} = join("\n", @lines);
}

sub remove_import_line_R{
    my ($this) = @_;

    ## append import lines
    my (@head,@tail,@imports) = $this->split_with(qr/^import /);

    my @lines;
    foreach(@imports){
        if(/\.R/){
            ## just ignore
        }else{
            push(@lines,$_);
        }
    }

    my @list;
    ## create new content
    push(@list, @head);
    push(@list, @lines);
    push(@list, @tail);

    $this->{_list} = \@lines;
    $this->{_content} = join("\n", @lines);
}

sub split_with{
    my ($this, $pattern) = @_;

    my (@head,@tail,@lines);

    my @list = $this->list;
    my $pattern_flag =0;

    foreach(@list){
        if(/$pattern/){
            $pattern_flag = 1;
            push(@lines, $_);
        }else{
            if($pattern_flag){
                push(@tail, $_);
            }else{
                push(@head, $_);
            }
        }
    }

    return (\@head,\@tail,\@lines);
}


#####################
## deprecated #
#########################
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
