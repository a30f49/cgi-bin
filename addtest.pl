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
use Plugin::ModuleData;

#check android area
my $android = new Android();
if(! Android::is_android_root){
    print STDERR "fatal: Not an android repository.\n";
    exit(0);
}

sub usage_out{
    print "Usage:\n";
    print "  addtest <module> <fragment>\n";
}
sub usage_in{
    print "Usage:\n";
    print "  addtest <fragment>\n";
}

sub usage{
    if(Android::is_android_pack){
        usage_out;
    }elsif(Android::is_android_one){
        usage_in;
    }
}

if(@ARGV == 0){
my $c= @ARGV;
    usage();
    exit(0);
}

my ($param_mod, $param_frag);

## if is android pack
if(Android::is_android_pack){
    ($param_mod, $param_frag) = @ARGV;

    if(!$param_mod || !$param_frag){
        usage_out;
        exit(0);
    }

}elsif(Android::is_android_one){
    ($param_frag) = @ARGV;
    $param_mod = 'app';

    if(!$param_frag){
        usage_in;
        exit(0);
    }
}

&gen_test;

sub gen_test{
    ## get module pack
    my $moduleData = new ModuleData($param_mod);
    my $target_pack = $moduleData->pack_to_test;
    #print "target-pack:$target_pack\n";

    my $mod = new Path()->basename;
    my $mdata = new ModuleData($mod);
    my $fragment_pack = $mdata->locate($param_frag);

    my $act = new ActivityGenerator($param_mod, $target_pack);
    if( $act->gen_test_with_fragment($fragment_pack)){
        my $new_act = $act->new_activity;
        print "Done...$param_frag=>$new_act\n";
    }else{
        print "Pass...$param_frag\n";
    }
}

