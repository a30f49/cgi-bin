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

use Android;
use Android::Template;
use Android::Module;

use Plugin::ModuleContent;
use Plugin::ModuleTarget;
use Plugin::FlowLayout;
use Plugin::Tree;

use Plugins::PluginFragmentActivity;

#check android area
if(! Android::is_android_one){
    print STDERR "fatal: Not an android module.\n";
    exit(0);
}

sub usage{
    print "Usage:\n";
    print "  wrapapp <which> <template>\n";
}

my ($which, $which_template) = @ARGV;
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
        print STDERR "fetal: $which not exists";
        exit(0);
    }

    if(!(-f $which_path)){
        print STDERR "fetal: $which not exists";
        exit(0);
    }
}

if(!$which_template){
    ## show all container template
    my $template = new Template();
    my @templates = $template->templates;
    foreach(@templates){
        if(/_container/){
            print ' -> ';
            print;
            print "\n";
        }
    }

    exit(0);
}else{
    ## check exists
    my $template = new Template();
    if(!$template->is_exists($which_template)){
        print STDERR "fetal: $which_template not exists";
        exit(0);
    }
}


## get app layout
my $data = new Reader($which_path)->data;
my $layout = new PluginFragmentActivity($data)->layout;

my $module = new Module(new Path()->basename);
my $layout_path = $module->xml($layout);

if(!(-f $layout_path)){
    ## just copy template layout
    $layout =~ s/\.xml//;
    $layout = $layout.'.xml';

    my $mod = new Path()->basename;
    my $mt = new ModuleTarget($mod, $layout);
    $mt->copy_from_layout(new Template()->name, $which_template);
    print "Done...$layout\n";

    exit(0);
}

## if layout already exists, replace container from template
print "Pass...$layout.xml already exists\n";
{
    my $fl = new FlowLayout($module->name, $layout);
    #print Dumper(new Tree($fl->container)->tree);


}