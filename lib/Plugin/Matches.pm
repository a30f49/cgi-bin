package Matches;
use lib qw(lib);
use strict;
use warnings;

sub new{
    my $class = shift;
    my $self = {
    };
    bless $self, $class;
    return $self;
}


#########################
## split package with base package and last segment package #
########################
sub split_package{
    my $pack = shift;

    ## split package with base pack and name
    my ($p, $n);

    $pack =~ /([\w\.]+)\.(\w+)$/;
    $p = $1;
    $n = $2;

    return ($p, $n);
}

#############################
## match which[Fragment|Activity] name to action id #
###########################
sub match_which_to_action_id{
    my ($which) = @_;
    $which =~ s/Fragment$//;
    $which =~ s/Activity//;

    my $action_id = 'action';
    if($which =~ /([A-Z][a-z]+)([A-Z][a-z]+)*/){
        $action_id = $action_id.'_'.$1;
        if($2){
            $action_id = $action_id.'_'.$2;
        }

        $action_id =~ tr/[A-Z]/[a-z]/;
    }

    return $action_id;
}

return 1;
