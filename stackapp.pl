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
    print "  stackapp <which> <template|LINE|DIVIDER|GROUP> \n";
}

my ($which, $which_template, $height) = @ARGV;
if(!$which){
    usage;
    exit(0);
}

my $which_path;
{
    #check exists
    my $mod = new Path()->basename;
    my $mc = new ModuleContent($mod);
    $which_path = $mc->locate_auto($which);
    if(!$which_path){
        print STDERR "fetal: $which not exists\n";
        exit(0);
    }

    if(!(-f $which_path)){
        print STDERR "fetal: $which not exists\n";
        exit(0);
    }
}

if(!$which_template){
    &show_templates_of_item;
    exit(0);
}


## get app layout
my $data = new Reader($which_path)->data;
my $layout = new PluginFragmentActivity($data)->layout;

my $module = new Module(new Path()->basename);
my $layout_path = $module->xml($layout);
if(!(-f $layout_path)){
    print STDERR "app layout not exists:$layout_path\n";
    exit(0);
}

my $provider = new FlowLayout($module->name, $layout);
my $children_root = $provider->container;
## ensure to get its container
if(!$children_root){
    $children_root = $provider->get_root;
}


if($which_template=~/^LINE$/){
    $provider->add_line($height);

}elsif($which_template=~/^DIVIDER$/){
    ##TODO,
}elsif($which_template=~/^GROUP/){
    ##TODO,
}
else{
    ## check which template exists
    if($which_template =~ /^[0-9]+$/){
        my $template = new Template();
        my @templates = $template->templates;

        my $hash = build_template_hash(\@templates);

        my $key = "#$which_template";
        $which_template = $hash->{$key};
    }

    my $template = new Template();
    if(!$template->is_exists($which_template)){
        print STDERR "fetal: $which_template not exists\n";
        exit(0);
    }

    my $tp = new TemplateProvider();
    my $item_root = $tp->template_root($which_template);

    $provider->add_child($item_root);
}

## write to target
{
    my $w = new Writer($layout_path);
    $w->write_new($children_root->data);

    print "Done...$layout.xml\n";
}


sub show_templates_of_item{
    ## show all container template
    my $template = new Template();
    my @templates = $template->templates;

    my $hash = build_template_hash(\@templates);
    #print Dumper($hash);

    my $i = 1;
    foreach(keys %{$hash}){
        my $key = "#$i";
        print $key."\t";
        print $hash->{$key};
        print "\n";
        $i++;
    }
}

sub build_template_hash{
    my $t = shift;
    my @list = @{$t};

    my $hash = {};

    my $index = 1;
    foreach(@list){
        if(/_item/){
            my $key = "#$index";
            $hash->{$key} = $_;

            $index++;
        }
    }

    return $hash;
}
