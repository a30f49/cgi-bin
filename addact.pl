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

my ($param_which, $param_target, $param_pack) = @ARGV;
my $local = (!$param_target);

if($param_which !~ /Fragment/){
    print "fatal: not an Fragment to add.\n";
    exit(0);
}
## target not specific, gen at local module
if($local){
    $param_target =  new Path()->basename;
}

## get fragment package
my $mc = new ModuleContent($param_target);
my $path = $mc->locate_auto($param_which);
if(!$path){
    print STDERR "fetal: $path not exists\n";
    exit(0);
}
my $fragment_pack = $mc->pack_from_path($path);
if($local){
    $param_pack = $mc->pack_cut($fragment_pack);
    $param_pack =~ s/\.\w+$//;
}

## support
my $act = new ActivityGenerator($param_target, $param_pack);
#print $param_target.",".$param_pack."\n";
if( $act->gen_act($fragment_pack)){
    print "Done...$param_which\n";
}else{
    print "Pass...$param_which\n";
}

