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

if(! Android::is_android_one){
    print STDERR "fatal: Not an android module.\n";
    exit(0);
}

&list_all_fragments;

sub list_all_fragments{
    my $mod = new Path()->basename;
    my $app_path  = new ModuleData($mod)->path_to_app;

    my $dir= new Dir($app_path);
    my @list = $dir->files;

    foreach(@list){
        s/\.java$//;
        if(/Fragment$/){
            print;
            print "\n";
        }
    }
}