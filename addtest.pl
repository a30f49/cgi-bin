#!/usr/bin/perl
BEGIN {
    my $cwd = $0;
    $cwd =~ s/\/[\w-\.]+$//;
    push( @INC, "$cwd/lib");
    require "$cwd/unittest.pl";
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
        #my $aut = new ModuleTarget($param_target);
        #$aut->copy_from_layout('plugin-template', 'activity_unit_test');
        my $data = &activity_unit_test_data;
        my $mc = new ModuleTarget($param_target, 'activity_unit_test');
        $mc->save($data);
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
        #print STDERR "fetal: UnitTestActivity.java not exists, please provide before continue\n";

        my $data =  &unittest_activity_class;
        my $w = new Writer($activity_test_java_path);
        $w->write_new($data);
    }

    if($param_which=~/Fragment$/){
        my $which_pack = $mc_which->pack_from_path($which_path);
        &gen_test_for_fragment($which_pack, $param_target);
    }else{
        &gen_test_for_activity($which_path, $param_target);
    }

    print "$param_which\n";
}

sub gen_test_for_activity{
    my ($which_path, $target, $overwrite) = @_;

    ## add to layout unit test
    my $layout = new FlowLayout('demo', 'fragment_unit_test.xml');
    my $template = $layout->clone_first_child;
    if(!$template){
        my $tp = new TemplateProvider();
        $template = $tp->template_root('template_test_item.xml');
    }
    #print Dumper($template->data);

    ## gen test item
    my $raw_item = pack_to_test_item($param_which);

    ## binding
    my $binding = new Binding();
    my $item_root = $binding->bind_test_item($raw_item, $template);
    #print Dumper($raw_item);

    my $stack = new FlowStack($layout->container);
    $stack->add_one($item_root);
    #print Dumper($stack->data);

    my $mt = new ModuleTarget($target, 'fragment_unit_test.xml');
    $mt->save($stack->data);
}


sub gen_test_for_fragment{
    my ($pack, $target, $overwrite)= @_;
    my $test = 1;

    ## gen activity java class
    #print $pack; return;
    my $act_path = build_test_target($pack, $target);
    if(!$overwrite && !(-f $act_path)){
        my $act = new ActivityGenerator($target, 'test');
        if( !$act->gen_act($pack, $test, $overwrite)){
            print STDERR "fetal: fail to gen activity\n";
            return;
        }
    }

    ## append to xml
    my $layout = new FlowLayout($target, 'fragment_unit_test.xml');
    my $template = $layout->clone_first_child;
    if(!$template){
        my $tp = new TemplateProvider();
        $template = $tp->template_root('template_test_item.xml');
    }
    #print Dumper(new Tree($template)->tree);

    ## binding
    my $raw_item = pack_to_test_item($pack);
    my $binding = new Binding();
    my $item_root = $binding->bind_test_item($raw_item, $template);

    #print Dumper(new Tree($item_root)->tree);
    my $stack = new FlowStack($layout->container);
    $stack->add_one($item_root);

    my $mt = new ModuleTarget($target, 'fragment_unit_test.xml');
    $mt->save($stack->data);
}


######################
## build the test item hash via the package #
######################
sub pack_to_test_item{
    my ($pack) = @_;
    $pack =~ s/ForTest$//;
    $pack =~ s/Fragment$//;
    $pack =~ s/Activity$//;

    ## get name only
    $pack =~ /(\w+)$/;

    my $act = $1;
    print $act."\n";

    $act =~ /([A-Z][a-z0-9]+)([A-Z][a-z0-9]+)*/;
    #print "(act, 1,2)=>($act, $1, $2)\n";
    my $id = '@+id/action_';
    my $title = '@string/title_';

    my $id_end = $1; if($2){$id_end = $id_end.'_'.$2;}
    $id_end =~ tr/[A-Z]/[a-z]/;

    $id = "$id$id_end";
    $title = "$title$id_end";

    my $raw_item = {};
    $raw_item->{id} = $id;
    $raw_item->{title} = $title;
    #print Dumper($raw_item);

    return $raw_item;
}

##############################
## build the test target path via the package #
#############################
sub build_test_target{
    my ($pack, $target) = @_;

    if($pack !~ /^\w+$/){
        $pack =~ /(\w+)$/;
        $pack = $1;
    }

    $pack =~ s/Fragment/ActivityForTest/;

    my $mc = new ModuleContent($target);
    my $target_pack = $mc->pack_with('test');
    $target_pack = $mc->pack_with($pack, $target_pack);

    my $path = $mc->path_to_pack($target_pack);
    $path = "$path.java";
    return $path;
}

sub activity_unit_test_data{
    my @list = <DATA>;

    my $data  = join('',@list);

    print $data;

    return $data;
}


__DATA__
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
              android:layout_width="match_parent"
              android:layout_height="match_parent"
              android:orientation="vertical">
    <include layout="@layout/toolbar"/>
    <include layout="@layout/fragment_unit_test"/>
</LinearLayout>