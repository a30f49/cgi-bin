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

use File::Reader;
use File::Writer;

use Android;
use Android::Module;

#check android area
my $android = new Android();
if(! Android::is_android_root){
    print STDERR "fatal: Not an android repository.\n";
    exit(0);
}

sub usage{
    print "Usage:\n";
    print "  modapp -t <appname>\n";
    print "     option: -t       #update app name\n";
}

if(@ARGV==0){
    usage;
    exit(0);
}

my $op;

while(@ARGV){
   $op = shift @ARGV;
   #print "$op\n";
   
   if($op eq '-t'){
       my $title = shift @ARGV;
       if($title){
           &change_app_title($title);
       }else{
          usage;
       }
   }else{
      usage;
   }
}


sub change_app_title{
   my $title = shift;
   my $module = new Module('app');
   my $manifest_path = $module->manifest;
   my $gradle_path = $module->gradle;
   #print "$gradle_path\n";

   ## change app name in manifest
   &change_manifest_title($manifest_path, $title);

   ## change app name in build.gradle
   &change_gradle_title($gradle_path, $title);


}

sub change_gradle_title{
    my ($gradle_path, $appname) = @_;
    my $reader = new Reader($gradle_path);
    my $data = $reader->data;

    $data =~ /applicationId\s+\"([\w\.]+)\"/;
    my $base = $1;
    $base =~ s/(\w+)$//;
    my $tt = $1;

    my $title_nw = "applicationId \"$base$appname\"";
    $data =~ s/applicationId\s+\"[\w\.]+\"/$title_nw/;
    #print $data;

    ## write back
    my $w =  new Writer();
    $w->write_new($gradle_path, $data);
}

sub change_manifest_title{
    my ($manifest_path, $appname) = @_;
    my $reader = new Reader($manifest_path);
    my $data = $reader->data;

    $data =~ /package\s*=\s*\"([\w\.]+)\"/;
    my $base = $1;
    $base =~ s/(\w+)$//;
    my $tt = $1;

    my $title_nw = "package=\"$base$appname\"";
    $data =~ s/package\s*=\s*\"[\w\.]+\"/$title_nw/;

    ## write back
    my $w =  new Writer();
    $w->write_new($manifest_path, $data);
}
