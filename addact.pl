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
if(! Android::is_android_one){
    print STDERR "fatal: Not an android module repository.\n";
    exit(0);
}

sub usage{
    print "Usage:\n";
    print "  addact <fragment>    -- add activity at local module\n";
}

my ($param_frag);

if(@ARGV==0){
    usage();
    exit(0);
}elsif(@ARGV==1){
    $param_frag = shift @ARGV;

    if($param_frag !~ /Fragment/){
        print "fatal: not an Fragment to add.\n";
        exit(0);
    }
}

if($param_frag){
    &gen_act;
}else{
    &copy_act;
}

sub gen_act{

    my $target_mod = new Path()->basename;
    my $target_pack = 'gen';

    my $mc = new ModuleContent($target_mod);
    my $fragment_pack = $mc->locate($param_frag);
    #print $fragment_pack."\n";
    return;

    ## support
    my $act = new ActivityGenerator($target_mod, 'gen');
    if( $act->gen_act($fragment_pack)){
        my $new_act = $act->new_activity;
        print "Done...$param_frag=>$new_act\n";
    }else{
        print "Pass...$param_frag\n";
    }
}

