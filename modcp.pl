#!/usr/bin/perl
##
## copy xml, java between modules
##
## #################################
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
use Path;

use Android;

use Plugin::ModuleContent;
use Plugin::ModuleTarget;

#check android area
my $android = new Android();
if(! Android::is_android_one){
    print STDERR "fatal: Not an android module.\n";
    exit(0);
}

my $overwrite = 0;

sub usage{
    print "Usage:\n";
    print "  modcp <which> <where> <target> <where-to> [options]\n";
    print "     which       -- copy which java file\n";
    print "     where       -- short package where java file copy from.\n";
    print "     target      -- copy to the target module\n";
    print "     where-to    -- short package where java file copy to.\n";
    print "     options:\n";
    print "         -a      -- copy type of activity.\n";
    print "         -x      -- copy type of layout(xml).\n";
}

if(@ARGV < 4){
    usage;
    exit(0);
}

my ($which, $which_pack, $target, $target_pack, $op) = @ARGV;
#print "($which, $which_pack, $target, $target_pack, $op)\n";

if(!$op){
    &java_copy($which, $which_pack, $target, $target_pack);
}elsif($op eq '-x'){
    if($which_pack ne '.'){
        print STDERR "fetal: <where> param must be \'.\', but $which_pack\n";
        exit(0);
    }
    if($target_pack ne '.'){
            print STDERR "fetal: <where-to> param must be \'.\', but $target_pack\n";
            exit(0);
    }
    &layout_copy($which, $target);
    print "Done...$which\n";

}elsif($op eq '-a'){
    my $pass = &activity_copy($which, $which_pack, $target, $target_pack);

    if($pass){
        print "Done...$which\n";
    }else{
        print "Pass...$which\n";
    }
}



## --
## the end

sub activity_copy{
    my ($which, $which_pack, $target, $target_pack) = @_;
    #print "($which, $which_pack, $target, $target_pack)\n";

    my $which_mod = new Path()->basename;
    my $which_mc = new ModuleContent($which_mod);
    my $which_path;
    if($which_pack eq '.'){
        ## means locate auto
        $which_path = $which_mc->locate_auto($which);
    }else{
        $which_path = $which_mc->locate_verify($which, $which_pack);
    }
    if(!$which_path){
        print STDERR "fetal: $which_path not exists\n";
        return 0;
    }
    my ($p,$s) = $which_mc->pack_from_path($which_path);
    $which_pack = $s;

    ## copy to target
    my $mt = new ModuleTarget($target, $target_pack);
    my $pass = $mt->copy_from($which_mod, $which, $which_pack, $overwrite);
    if(!$pass){
        print STDERR "fetal: fail to copy $which\n";
        return 0;
    }

    ## copy activity layout within java class

}

sub layout_copy{
    my ($which_xml, $target)= @_;

    my $which_mod = new Path()->basename;

    my $mt = new ModuleTarget($target);
    $mt->copy_from_layout($which_mod, $which_xml, $overwrite) or die "Copy failed: $!";
}

sub java_copy{
    my $mod = new Path()->basename;
    my $mc_from = new ModuleContent($mod);
    my $from_path = $mc_from->locate_verify($which, $which_pack);
    if(!$from_path){
        print  STDERR "fetal: $from_path not exists\n";
        return 0;
    }
}
