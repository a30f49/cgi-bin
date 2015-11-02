#!/usr/bin/perl
BEGIN {
    my $cwd = $0;
    $cwd =~ s/\/[\w-\.]+$//;
    push( @INC, "$cwd/lib");
}
use strict;
use warnings;
use JSON;
use File::Spec;

use Android;

use Plugin::ActivityGenerator;
use Plugin::ModuleContent;

#check android area
my $android = new Android();
if(! Android::is_android_root){
    print STDERR "fatal: Not an android repository.\n";
    exit(0);
}

sub usage{
    print "Usage:\n";
    print "  addact <fragment>           -- add activity at local\n";
    print "  addact <activity> <target>  -- add activity to target module\n";
}

my ($param_mod, $param_frag, $param_act, $param_target);
$param_mod = new Path()->basename;

if(@ARGV==0){
    usage();
    exit(0);
}elsif(@ARGV==1){
    $param_frag = shift @ARGV;

    if($param_frag !~ /Fragment/){
        usage;
        exit(0);
    }

}elsif(@ARGV==2){
    $param_act = shift @ARGV;
    $param_target = shift @ARGV;

    if(!$param_target){
        usage;
        exit(0);
    }
}

if($param_frag){
    &gen_act;
}else{
    &copy_act;
}

sub copy_act{
    ## TODO,
}

sub gen_act{
    ## get module pack

    my $moduleData = new ModuleContent($param_mod);
    my $target_pack = $moduleData->pack_to_gen;
    #print "target-pack:$target_pack\n";

    my $fragment_pack = $moduleData->locate($param_frag);

    ## support
    my $act = new ActivityGenerator($param_mod, $target_pack);
    if( $act->gen_act($fragment_pack)){
        my $new_act = $act->new_activity;
        print "Done...$param_frag=>$new_act\n";
    }else{
        print "Pass...$param_frag\n";
    }
}

