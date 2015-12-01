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
use Plugin::Matches;

use Plugins::PluginActionFlow;

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

my ($param_which, $param_target, $param_target_pack) = @ARGV;
if(!$param_target){
    $param_target = 'app';
}
if(!$param_target_pack){
    $param_target_pack = 'test';
}

if(!$param_which){
    usage;
    exit(0);
}

## ensure no .java append
$param_which =~ s/\.java//;

&gen_test($param_which, 1);


sub gen_test{
    my ($which, $test) = @_;

    ## get which fragment|activity
    my ($which_pack);
    {
        my $mod = new Path()->basename;
        my $mc = new ModuleContent($mod);

        my $which_path = $mc->locate_auto($param_which);
        if(!(-f $which_path)){
            die "fatal: $which_path not exists.\n";
        }
        $which_pack = $mc->pack_from_path($which_path);
    } #print "(which_pack)=>($which_pack)\n";


    ## check activity_unit_test exists
    {
        my $module  = new Module($param_target);
        my $activity_test_path = $module->xml('activity_unit_test');
        if(!(-f $activity_test_path)){
            my $data = &data_activity_unit_test;
            my $mc = new ModuleTarget($param_target, 'activity_unit_test');
            $mc->save($data);
        }
    }

    ## check fragment_unit_test exists
    {
        my $module  = new Module($param_target);
        my $fragment_unit_test_tag = 'fragment_unit_test';
        my $fragment_unit_test = $module->xml($fragment_unit_test_tag);
        if(!(-f $fragment_unit_test)){
            my $tp = new TemplateProvider();
            my $root = $tp->template_root('template_test_container');

            my $aut = new ModuleTarget($param_target, $fragment_unit_test_tag);
            $aut->save($root->data);
        }
    }

    ## check UnitTestActivity exists
    {
        my $mc = new ModuleContent($param_target);
        my $activity_test_java_path = $mc->locate('UnitTestActivity');
        if(!(-f $activity_test_java_path)){
            my $data =  &unittest_activity_class;
            my $w = new Writer($activity_test_java_path);
            $w->write_new($data);
        }
    }

    ## gen activity for test for fragment
    if($param_which=~/Fragment/){
        my $act = new ActivityGenerator($param_target, $param_target_pack);
        if(!$act->gen_act($which_pack, $test, $overwrite)){
            print STDERR "...Passed\n";
        }

        ## which pack to target
        $which_pack = $act->new_activity;
        $which_pack =~ /\.(\w+)$/;
        $which = $1;
    }


    ## append activity to layout
    my $ok=&append_to_layout($which, $param_target, $overwrite);
    if($ok){
        print "Done with adding layout item.\n";
    }


    ## append action to java UnitTestActivity
    &append_action_flow_to_java($which_pack, $param_target);
    print "$param_which\n";
}

sub append_action_flow_to_java{
    my ($which_pack, $target, $overwrite) = @_;

    ### add action to UnitTestActivity
    my $action_id = Matches::match_which_to_action_id($param_which);

    my $mc = new ModuleContent($target);
    my $path = $mc->locate('UnitTestActivity');
    my $data = new Reader($path)->data;
    my $af = new PluginActionFlow($data);
    $af->registerActivity($param_which, $which_pack);
    $data = $af->data;

    my $w = new Writer($path);
    $w->write_new($data);
}

sub append_to_layout{
    my ($which_pack, $target, $overwrite) = @_;

    ## add to layout unit test
    my $layout = new FlowLayout($target, 'fragment_unit_test.xml');
    my $template = $layout->clone_first_child;
    if(!$template){
        my $tp = new TemplateProvider();
        $template = $tp->template_root('template_test_item.xml');
    }
    delete $template->{'xmlns:android'};
    #print Dumper($template->data);


    ## gen test item
    my $raw_item = pack_to_test_item($which_pack);
    my $binding = new Binding();
    my $item_root = $binding->bind_test_item($raw_item, $template);
    #print Dumper($raw_item);

    my $stack = new FlowStack($layout->container);
    $stack->add_one($item_root);
    #print Dumper($stack->data);

    my $mt = new ModuleTarget($target, 'fragment_unit_test.xml');
    $mt->save($stack->data);

    return 1;
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



sub data_activity_unit_test{
    my @list = <DATA>;
    my $data  = join('', @list);
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