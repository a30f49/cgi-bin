#!/usr/bin/perl
##
## copy xml, java between modules
##
## #################################
BEGIN {
    my $cwd = $0;
    $cwd =~ s/\/[\w-\.]+$//;
    push( @INC, "$cwd/lib");
}
use strict;
use warnings;
use JSON;
use File::Spec;
use File::Copy;

use Android;

use Plugin::ActivityGenerator;
use Plugin::ModuleContent;
use Plugin::ModuleTarget;

#check android area
my $android = new Android();
if(! Android::is_android_root){
    print STDERR "fatal: Not an android repository.\n";
    exit(0);
}

if(! Android::is_android_one){
    print STDERR "fatal: Not an android module.\n";
    exit(0);
}

sub usage{
    print "Usage:\n";
    print "  modcp <options> [which] [target] [-f]\n";
    print "     options -f        -- list fragments\n";
    print "             -a        -- list activities\n";
    print "             -x        -- list xml layouts\n";
    print "     which        -- copy which xml\n";
    print "     target       -- copy to target module\n";
    print "     -f           -- force overwrite if exists at target side.\n";
}

my $op = shift @ARGV;

my ($which, $target, $overwrite);
$which = shift @ARGV;
$target =  shift @ARGV;
$overwrite = shift @ARGV;

if(!$op){
    usage;
    exit(0);
}
if($op eq '-h'){
    usage;
    exit(0);
}

if($op eq '-f'){
    &list_all_fragments;

}elsif($op eq '-a'){
    if(!$which){
       &list_all_activities;
       exit(0);
    }
    if(!$target){
        usage;
        exit(0);
    }

    ## copy which java to target module
    my $mod = new Path()->basename;
    my $mc = new ModuleContent($mod);
    my $java_path = $mc->locate($which);
    if(!(-f $java_path)){
        $java_path = $mc->locate($which, 'app');
    }
    if(!(-f $java_path)){
        print STDERR "$which not exist\n";
        exit(0);
    }

    my $java_pack = $mc->pack_from_path($java_path);

    my $short_pack = $mc->pack_cut($java_pack);
    $short_pack =~ s/\.$which//;

    my $mt = new ModuleTarget($target, $short_pack);
    if($mt->copy_from($mod, $which, $short_pack, $overwrite)){
        print "Done...$which\n";
    }else{
        print "Pass...$which\n";
    }
}
elsif($op eq '-x'){
    if(!$which){
        &list_all_layouts;
        exit(0);
    }
    if(!$target){
        usage;
        exit(0);
    }

    ## copy which xml to target module
    my $mod = new Path()->basename;
    my $mt = new ModuleTarget($target);
    $mt->copy_layout($mod, $which, $overwrite) or die "Copy failed: $!";

    print "Done...$which\n";

}else{
    usage;
    exit(0);
}

sub list_all_layouts{
    my $mod = new Path()->basename;

    my $layout = new Module($mod)->layout;

    my $dir= new Dir($layout);
    my @list = $dir->files;

     foreach(@list){
        print;
        print "\n";
     }
}

sub list_all_fragments{
    &list_all_fragments_and_activities;
}

sub list_all_activities{
    &list_all_fragments_and_activities;
}

sub list_all_fragments_and_activities{
    my $mod = new Path()->basename;

    my $mc = new ModuleContent($mod);

    my $app_pack = $mc->pack_with('app');
    my $app_path = $mc->path_to_pack($app_pack);
    my $pack_path = $mc->path_to_pack;
    #print "(app_path,pack_path)=>($app_path,$pack_path)\n";
    if(!(-e $pack_path)){
        print STDERR "path to src package not exists\n";
        return;
    }

    if( (-d $app_path) ){
        dump_dir($app_path, 'app');
    }
    if( (-d $pack_path) ){
        dump_dir($pack_path);
    }
}

sub dump_dir{
    my ($path, $short_path) = @_;

    my $dir= new Dir($path);
    my @list = $dir->files;

    foreach(@list){
        s/\.java$//;

        my $match = 0;

        if($op eq '-a' && /Activity$/){
            $match = 1;
        }elsif($op eq '-f' and /Fragment$/){
            $match = 1;
        }

        if($match){
            ## append short path: 'app' etc.
           if($short_path){
               print $short_path;
               print "/";
           }

           print;
           print "\n";
        }
    }
}