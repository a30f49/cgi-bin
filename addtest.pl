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

use Plugin::ActivityGenerator;
use Plugin::ModuleContent;
use Plugin::FlowRaw;
use Plugin::FlowLayout;
use Plugin::Binding;
use Plugin::ModuleTarget;

#check android area
my $android = new Android();
if(! Android::is_android_one){
    print STDERR "fatal: Not an android module.\n";
    exit(0);
}

sub usage{
    print "Usage:\n";
    print "  addtest <fragment> -f\n";
    print "  -f   ,force overwrite\n";
}

if(@ARGV == 0){
my $c= @ARGV;
    usage();
    exit(0);
}

my ($param_frag, $overwrite);

if(Android::is_android_one){
    ($param_frag, $overwrite) = @ARGV;

    if($overwrite){
        if($overwrite ne '-f'){
            $overwrite = undef;
        }
    }

    if(!$param_frag){
        usage;
        exit(0);
    }
}

&gen_test;

sub gen_test{
    my $target_mod = 'app';
    my $target_pack = 'test';
    my $test = 1;

    my $done = 0;


    ## get module pack
    my $mc = new ModuleContent();
    my $mod = new Path()->basename;
    $mc->module($mod);

    ## from
    my $fragment_pack = $mc->locate($param_frag);
    print "$fragment_pack\n";

    ## gen class
    my $act = new ActivityGenerator($target_mod, $target_pack);
    if( $act->gen_act($fragment_pack, $test, $overwrite)){
        $done = 1;
    }else{
        $done = 0;
    }


    ## append to xml
    #my $raw = new FlowRaw('app');
    #my $data = $raw->get_raw("fragment_unit_test.xml");
    #print Dumper($data);
    my $layout = new FlowLayout('app', 'fragment_unit_test.xml');
    my $template = $layout->first_child;
    ## TODO, clone hash
    ##
    if(!$template){
        my $tp = new TemplateProvider();
        $template = $tp->template_root('template_test_item.xml');
    }

    my $binding = new Binding();
    my $item = $act->gen_raw;
    my $item_root = $binding->bind_test_item($item, $template);

    my $stack = new FlowStack($layout->container);
    $stack->add_one($item_root);

    my $mt = new ModuleTarget('app', 'fragment_unit_test.xml');
    $stack->save($mt->target);


    ### print result
    if($done){
        my $new_act = $act->new_activity;
        print "=>$new_act\n";
    }else{
        print "Pass...$param_frag\n";
    }
}
