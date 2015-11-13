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
use Android::Template;

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
    print "  template <action>\n";
    print "     action --list  <options> -- list the templates\n";
    print "            --show  <which>   -- show which template\n";
    print "            --apply <which> <target>  -- apply container to target: fragment|activity\n\n";
    print "     options c        -- of container templates\n";
    print "             i        -- of item templates\n";
}

my $action = shift @ARGV;
if(!$action || $action eq '-h'){
    usage;
    exit(0);
}

if($action eq '--list'){
    my $op = shift @ARGV;
    if(!$op){
        &list_all_layouts;
    }elsif($op eq 'c'){
        &list_all_containers;
    }elsif($op eq 'i'){
        &list_all_items;
    }else{
        usage;
        exit(0);
    }
}elsif($action eq '--show'){
    my $xml = shift @ARGV;
    if(!$xml){
        usage;
        exit(0);
    }
    ## check which exists
    my $t = new Template();
    if(!$t->is_exists($xml)){
        print STDERR "fetal: $xml not exists\n";
        exit(0);
    }

    &show_template($xml);

}elsif($action eq '--apply'){
    if(! Android::is_android_one){
        print STDERR "fatal: Not an android module.\n";
        exit(0);
    }

    my ($which, $app) = @ARGV;

    if(!$which){
        usage;
        exit(0);
    }

    ## check which exists
    my $t = new Template();
    if(!$t->is_exists($which)){
        print STDERR "fetal: $which not exists\n";
        exit(0);
    }
    if(!$app){
        usage;
        exit(0);
    }

    ## check target app exists
    my $target = new Path()->basename;
    my $mc = new ModuleContent($target);
    my $app_path = $mc->locate_auto($app);
    if(!(-f $app_path)){
         print STDERR "fetal: $app not exists\n";
         exit(0);
    }

    &apply_template($which, $target, $app)
}else{
    usage;
    exit(0);
}

sub apply_template{
    my ($which, $target, $app) = @_;
    #print "(which, target, app)=>($which, $target, $app)\n";
}

sub list_all_layouts{
    my @list = new Template()->templates;
    foreach(@list){
        print;
        print "\n";
    }
}

sub list_all_containers{
    my @list = new Template()->templates;
    foreach(@list){
        if(/_container/){
            s/\.xml//;
            print;
            print "\n";
        }
    }
}

sub list_all_items{
    my @list = new Template()->templates;
    foreach(@list){
        if(/_item/){
            s/\.xml//;
            print;
            print "\n";
        }
    }
}


sub show_template{
    my $xml = shift;

    my $template = new Template();
    my $path = $template->xml($xml);
    my $data = new Reader($path)->data;

    print $data;
    print "\n";
}
