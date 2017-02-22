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
use File::Copy;

use Android;

use Plugin::ModuleContent;

use Plugins::PluginFragmentActivity;

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
    print "  listapp <options> d\n";
    print "     options -f        -- list fragments\n";
    print "             -a        -- list activities\n";
    print "             -x        -- list xml layouts\n";
    print "              d        -- show details, its layout\n";
}

my $op = shift @ARGV;
my $d = shift @ARGV;  ## means details

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
    &list_all_activities;
}elsif($op eq '-x'){
    &list_all_layouts;
}else{
    usage;
    exit(0);
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

    my $path_app;
    {
        my $pack_app = $mc->pack_with('app');
        $path_app = $mc->path_to_pack($pack_app);
    }
    my $path_gen;
    {
        my $pack_gen = $mc->pack_with('gen');
        $path_gen = $mc->path_to_pack($pack_gen);
    }
    my $path_root;
    {
        $path_root = $mc->path_to_pack;
    }
    if(!(-e $path_root)){
        print STDERR "path to src package not exists\n";
        return;
    }

    if( (-d $path_app) ){
        dump_dir($path_app, 'app');
    }
    if( (-d $path_gen) ){
        dump_dir($path_gen, 'gen');
    }
    if( (-d $path_root) ){
        dump_dir($path_root);
    }
}

sub dump_dir{
    my ($path, $short_path) = @_;

    my $dir= new Dir($path);
    my @list = $dir->files;

    foreach(@list){
        my $file_path  = "$path/$_";

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

           if($d){
              print "\t";
              print get_app_layout($file_path);
           }

           print "\n";
        }
    }
}

sub get_app_layout{
    my $path  = shift;
    my $data = new Reader($path)->data;
    my $layout = new PluginFragmentActivity($data)->layout;
    return $layout;
}


####################
## list all layouts  #
######################
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
