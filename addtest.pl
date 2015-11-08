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
use Data::Dumper;

use Android;
use Android::Module;

use Plugin::ActivityGenerator;
use Plugin::ModuleContent;
use Plugin::FlowRaw;
use Plugin::FlowLayout;
use Plugin::FlowStack;
use Plugin::Binding;
use Plugin::ModuleTarget;
use Plugin::TemplateProvider;

#check android area
my $android = new Android();
if(! Android::is_android_one){
    print STDERR "fatal: Not an android module.\n";
    exit(0);
}

sub usage{
    print "Usage:\n";
    print "  addtest <fragment|activity> [target]\n";
    print "     target     -- target module, default to 'app' \n";
}

if(@ARGV == 0){
    usage();
    exit(0);
}

my $overwrite = 0;

my ($param_which, $param_target, $param_pack) = @ARGV;
if(!$param_target){
    $param_target = 'app';
}
if(!$param_pack){
    $param_pack = 'test';
}

if(!$param_which){
    usage;
    exit(0);
}

&gen_test;

sub gen_test{
    my $test = 1;

    ## get module pack
    my $mod = new Path()->basename;
    my $mc_which = new ModuleContent($mod);

    ## from fragment package
    my $which_path = $mc_which->locate_auto($param_which);
    if(!(-f $which_path)){
        print STDERR "fatal: $which_path not exists.\n";
        return 0;
    }
    #print "$which_path\n";

    ## check activity_unit_test exists
    my $module  = new Module($param_target);
    my $activity_test_path = $module->xml('activity_unit_test');
    if(!(-f $activity_test_path)){
        my $aut = new ModuleTarget($param_target);
        $aut->copy_from_layout('plugin-template', 'activity_unit_test');
    }

    ## check fragment_unit_test exists
    my $fragment_unit_test_tag = 'fragment_unit_test';
    my $fragment_unit_test = $module->xml($fragment_unit_test_tag);
    if(!(-f $fragment_unit_test)){
        my $tp = new TemplateProvider();
        my $root = $tp->template_root('template_test_container');

        my $aut = new ModuleTarget($param_target, $fragment_unit_test_tag);
        $aut->save($root->data);
    }

    ## check UnitTestActivity exists
    my $mc_target = new ModuleContent($param_target);
    my $activity_test_java_path = $mc_target->locate('UnitTestActivity');
    if(!(-f $activity_test_java_path)){
        print STDERR "fetal: UnitTestActivity.java not exists, please provide before continue\n";
        return 0;
    }

    if($param_which=~/Fragment$/){
        &gen_test_for_fragment($param_target, $param_which);
    }else{
        &gen_test_for_activity($param_target, $param_which);
    }
}

sub gen_test_for_activity{
    my ($which_path) = @_;

    ## add to layout unit test
    ##

}


sub gen_test_for_fragment{
    my ($which_path, $target, $overwrite)= @_;
    my $test = 1;

## gen activity java class
    my $act = new ActivityGenerator($target, $which_path);
    if( !$act->gen_act($which_path, $test, $overwrite)){
        print STDERR "fetal: fail to gen activity\n";
        return;
    }

    ## append to xml
    my $layout = new FlowLayout('app', 'fragment_unit_test.xml');
    my $template = $layout->clone_first_child;
    if(!$template){
        my $tp = new TemplateProvider();
        $template = $tp->template_root('template_test_item.xml');
    }

    ## binding
    my $binding = new Binding();   my $item = $act->gen_raw;
    my $item_root = $binding->bind_test_item($item, $template);

    #print Dumper(new Tree($item_root)->tree);
    my $stack = new FlowStack($layout->container);
    $stack->add_one($item_root);

    #print "------------------------------------------------------\n";
    #print $stack->data;

    my $mt = new ModuleTarget('app', 'fragment_unit_test.xml');
    $mt->save($stack->data);

    ### print result
    my $new_act = $act->new_activity;
    print " =>override $new_act\n";
    print "Done...$param_which => $new_act\n";
}
