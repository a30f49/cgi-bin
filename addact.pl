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

use Android;

use Plugin::ActivityGenerator;
use Plugin::ModuleContent;

#check android area
my $android = new Android();
if(! Android::is_android_one){
    print STDERR "fatal: Not an android module repository.\n";
    exit(0);
}
if(@ARGV==0){
    &usage();
    exit(0);
}

sub usage{
    print "Usage:\n";
    print "  addact <fragment> <target> <pack>  -- add activity at local module\n";
    print "     params:\n";
    print "        fragment       -- the fragment to be add\n";
    print "        target         -- the target module to add to\n";
    print "        pack           -- the short pack to add to \n";
}

my ($param_frag, $param_target, $param_short_pack) = @ARGV;
my $local = (!$param_target);

if($param_frag !~ /Fragment/){
    print "fatal: not an Fragment to add.\n";
    exit(0);
}
## target not specific, gen at local module
if($local){
    $param_target =  new Path()->basename;
}

## get fragment package
my $mc = new ModuleContent(new Path()->basename);
my $path = $mc->locate_both($param_frag);
if(!$path){
    print STDERR "fetal: $path not exists\n";
    exit(0);
}
my $fragment_pack = $mc->pack_from_path($path);
if($local){
    $param_short_pack = $mc->pack_cut($fragment_pack);
}

## support
my $act = new ActivityGenerator($param_target, $param_short_pack);
#print $param_target.",".$param_short_pack."\n";
if( $act->gen_act($fragment_pack)){
    my $new_act = $act->new_activity;
    print "Done...$param_frag=>$new_act\n";
}else{
    print "Pass...$param_frag\n";
}

