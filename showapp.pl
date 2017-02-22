#!/usr/bin/perl
BEGIN {
    my $cwd = $0;
    $cwd =~ s/\/[\w-\.]+$//;
    push( @INC, "$cwd/lib");
}
use strict;
use warnings;
use JSON;

use Data::Dumper;
use File::Writer;

use Android;
use Android::Template;
use Android::Module;

use Plugin::ModuleContent;
use Plugin::ModuleTarget;
use Plugin::FlowLayout;
use Plugin::TemplateProvider;
use Plugin::Tree;

use Plugins::PluginFragmentActivity;

#check android area
if(! Android::is_android_one){
    print STDERR "fatal: Not an android module.\n";
    exit(0);
}

sub usage{
    print "Usage:\n";
    print "  showapp <which> [d]\n";
    print "       d      -- details, show layout content\n";
}

my ($which, $d) = @ARGV;
my $which_path;

if(!$which){
    usage;
    exit(0);
}else{
    #check exists
    my $mod = new Path()->basename;
    my $mc = new ModuleContent($mod);
    $which_path = $mc->locate_auto($which);
    if(!$which_path){
        die "fetal: $which not exists\n";
    }

    if(!(-f $which_path)){
        die "fetal: $which not exists\n";
    }
}

## get app layout
my $data = new Reader($which_path)->data;
my $layout = new PluginFragmentActivity($data)->layout;

my $module = new Module(new Path()->basename);
my $layout_path = $module->xml($layout);
if(!(-f $layout_path)){
    die "fetal: $layout_path not exists\n";
}

if($d){
    my $reader = new Reader($layout_path);
    print $reader->data;
}else{
    print $layout.'.xml';
}


print "\n";