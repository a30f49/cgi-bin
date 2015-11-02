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

if(! Android::is_android_one){
    print STDERR "fatal: Not an android module.\n";
    exit(0);
}

sub usage{
    print "Usage:\n";
    print "  listapp [options]\n";
    print "     options -h   - for help\n";
    print "             -a   - list activities\n";
    print "             -f   - list fragments\n";
    print "             -x [which] [target] [-f] -list xml layouts\n";
    print "                [which]      - copy which xml\n";
    print "                [target]     - copy to target module\n";
    print "                [-f]         - force overwrite if exists at target side.\n";
}

my $op = shift @ARGV;

if(!$op){
    usage;
    exit(0);
}
if($op && $op eq '-h'){
    usage;
    exit(0);
}

if($op and ($op eq '-f' or $op eq '-a')){
    &list_all_fragments_and_activities;
}elsif($op and $op eq '-x'){
    my $which = shift @ARGV;
    my $target =  shift @ARGV;
    my $overwrite = shift @ARGV;

    if(!$which){
        &list_all_layouts;
    }else{
        if(!$target){
            usage;
            exit(0);
        }

        ## copy which xml to target module
        my $mod = new Path()->basename;
        my $xml_path = new Module($mod)->xml($which);
        my $xml_target = new Module($target)->xml($which);
        #print "(xml_path,xml_target)=>($xml_path,$xml_target)\n";

        if(!(-f $xml_path)){
            print STDERR "$xml_path not exists\n";
            exit(0);
        }

        if(!($overwrite)){
           if(-f $xml_target){
               print STDERR "$xml_target exists\n";
               exit(0);
           }
        }

        use File::Copy;
        copy( $xml_path, $xml_target ) or die "Copy failed: $!";
    }
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

sub list_all_fragments_and_activities{
    my $mod = new Path()->basename;

    my $mc = new ModuleContent($mod);

    my $app_path  = $mc->path_to_app;
    my $pack_path = $mc->path_to_pack;
    #print "(app_path,pack_path)=>($app_path,$pack_path)\n";
    if(!(-e $pack_path)){
        print STDERR "path to src package not exists\n";
        return;
    }

    print $pack_path;print "\n";

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

        if($op && $op eq '-a' && /Activity$/){
            $match = 1;
        }elsif(/Fragment$/){
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