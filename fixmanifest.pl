#!/usr/bin/perl
=head1
    fix AndroidManifest.xml to ensure all activity is added in.

    command line:
    $ fixmanifest

=cut
BEGIN {
    my $cwd = $0;
    $cwd =~ s/\/[\w-\.]+$//;
    push( @INC, "$cwd/lib");
}
use strict;
use warnings;
use JSON;
use File::Find;
use File::Spec;
use Path;

use Android;
use Android::Manifest;
use Android::Module;

use File::Reader;
use File::Writer;

use Plugin::JavaContent;

#check android area
my $android = new Android();
if(! Android::is_android_one){
    print STDERR "fatal: Not an android module repository.\n";
    exit(0);
}

my $mod = new Path()->basename;
my $module = new Module($mod);
my $module_root = $module->src;

my $manifest_path = $module->manifest;
my $manifest = new Manifest($manifest_path);
my $manifest_pack = $manifest->pack;

find(\&find_all, $module_root);

sub find_all{
    if(-f $_){
        if(/Activity\.java/){
            my $f = File::Spec->rel2abs($_);
            &fix_manifest($f, $_);
        }elsif(/ActivityForTest\.java/){
            my $f = File::Spec->rel2abs($_);
            &fix_manifest($f, $_);
        }
    }
}

sub fix_manifest{
    my ($act_path, $act) = @_;
    #print "(act_path, act)=>($act_path, $act)\n";

    my $data = new Reader($act_path)->data;
    my $jc = new JavaContent($data);

    my $act_pack = $jc->package_value;
    $act_pack = "$act_pack.$act";

    $act_pack =~ s/$manifest_pack//;
    $act_pack =~ s/\.java$//;


    ## check if added
    my $added = 0;

    my $act_name = $act_pack;
    if(!$manifest->activity_exists($act_name)){
        $added = 1;
        print "$act_name not exists in AndroidManifest.xml, added to manifest.\n";
        $manifest->append_activity_with_name($act_name);
    }

    if($added){
        $manifest->save;
    }
}

