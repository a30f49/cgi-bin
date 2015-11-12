package PluginActionFlow;
use lib qw(lib);
use strict;
use warnings;

use Plugin::JavaContent;
our @ISA = qw(JavaContent);

use Plugin::Matches;

sub new{
    my $class = shift;
    my $self = $class->SUPER::new( @_ );

    bless $self, $class;
    return $self;
}

sub action_init_line{
    my ($this) = @_;

    my @list = $this->list;

    foreach(@list){
        if(/actionFlow\.init\(/){
            return $_;
        }
    }
}

sub registerActivity{
    my ($this, $action, $class) = @_;
    if($class =~ /^\w+$/){
        die "fetal: $class is not a full package class\n";
    }

    ## get action id
    if($action =~ /([A-Z][a-z]+)([A-Z][a-z]+)*/){
        $action = Matches::match_which_to_action_id($action);
    }
    $action =~ s/R\.id\.//;
    $action =~ tr/[A-Z]/[a-z]/;
    $action = 'R.id.'.$action;

    # parse $class
    my $pack = $class;
    $class =~ /\.(\w+)$/;
    $class = $1;
    $class = $class.'.class';
    #print "(action,class)=>($action,$class)\n";

    ## append action flow
    $this->append_action($action, $class);

    ## append to import
    $this->append_import_line($pack);
}


sub append_action{
    my ($this, $action, $class) = @_;

    my $space_line = $this->action_init_line;
    $space_line =~ /^(\s+)/;
    my $space = $1;

    ## register activity
    my $action_line = $space."actionFlow.registerActivity($action, $class);";
    my ($head,$tail,$actions) = $this->split_with(qr/^\s* actionFlow.registerActivity/);

    push(@{$actions}, $action_line);

    ## create new content
    my @lines;

    if(@{$tail}>0){
        push(@lines, @{$head});
        push(@lines, @{$actions});
        push(@lines, @{$tail});
    }else{
        my ($head2,$tail2,$init) = $this->split_with(qr/^\s* actionFlow.init/);
        push(@lines, @{$head2});
        push(@lines, @{$actions});
        push(@lines, @{$init});
        push(@lines, @{$tail2});
    }

    $this->{_list} = \@lines;
    $this->{_content} = join("\n", @lines);
}