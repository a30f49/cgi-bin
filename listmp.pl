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
use Android::Module;

use File::Reader;

use Plugin::ModuleContent;

#check android area
my $android = new Android();
if(! Android::is_android_root){
    print STDERR "fatal: Not an android repository.\n";
    exit(0);
}

sub usage{
    print "Usage:\n";
    print "  listmp <options>\n";
    print "     options -c        -- list container templates\n";
    print "             -i        -- list item template to the container\n";
    print "             -a        -- list all templates\n";
    print "             --show <which>  -- show which content\n";
}

my $op = shift @ARGV;
if(!$op){
    usage;
    exit(0);
}
if($op eq '-h'){
    usage;
    exit(0);
}

my $target = 'plugin-template';

if($op eq '-c'){
    &list_all_containers;
}elsif($op eq '-i'){
    &list_all_items;
}elsif($op eq '-a'){
    &list_all_layouts;
}elsif($op eq '--show'){
    my $xml = shift;
    &show_template($xml);
}else{
    usage;
    exit(0);
}

sub show_template{
    my $xml = shift;
    my $module = new Module($target);
    my $path = $module->xml($xml);
    if(!(-f $path)){
        print STDERR 'warn: $path not exists\n';
        return;
    }

    my $data = new Reader($path)->data;

    print $data;
    print "\n";
}

sub list_all_layouts{
    my @list = &read_all_layouts($target);

    foreach(@list){
        print;
        print "\n";
    }
}

sub list_all_containers{
    my @list = &read_all_layouts($target);
    foreach(@list){
        if(/_container/){
            print;
            print "\n";
        }
    }
}

sub list_all_items{
    my @list = &read_all_layouts($target);
    foreach(@list){
        if(/_item/){
            print;
            print "\n";
        }
    }
}

sub read_all_layouts{
    my $target = shift;

    my $module = new Module($target);
    my $layout = $module->layout;

    my $dir= new Dir($layout);
    my @list = $dir->files;
    return @list;
}
