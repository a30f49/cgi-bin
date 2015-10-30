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
use Plugin::ModuleData;

#check android area
my $android = new Android();
if(! Android::is_android_root){
    print STDERR "fatal: Not an android repository.\n";
    exit(0);
}

if(! Android::is_android_one){
    print STDERR "fatal: Not an android module.\n";
    exit(0);
}

my $op;

while(@ARGV){
   $op = shift @ARGV;
   #print "$op\n";
   
   if($op eq '-t'){
       my $title = shift @ARGV;
       &change_app_title($title);
   }

}


sub change_app_title{
   my $title = shift;
     
     
}


