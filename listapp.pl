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

&list_all_fragments;

sub list_all_fragments{
    my $mod = new Path()->basename;

    my $mc = new ModuleContent($mod);

    my $app_path  = $mc->path_to_app;
    my $pack_path = $mc->path_to_pack;
    #print "(app_path,pack_path)=>($app_path,$pack_path)\n";
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
        if(/Fragment$/){
            if($short_path){
                print $short_path;
                print "/";
            }
            print;
            print "\n";
        }
    }
}