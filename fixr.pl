#!/usr/bin/perl
=head1
    fix the import com.sample.app.R; line with correct package

    command line:
    $ fixr

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

use File::Reader;
use File::Writer;

use Plugin::ModuleContent;
use Plugin::JavaContent;

#check android area
my $android = new Android();
if(! Android::is_android_one){
    print STDERR "fatal: Not an android module repository.\n";
    exit(0);
}

my $mod = new Path()->basename;
my $mc = new ModuleContent($mod);
my $pack_path = $mc->path_to_pack;
my $pack = $mc->pack;
#print $pack_path .  "\n";

find(\&find_all, $pack_path);

sub find_all{
    if(-f $_){
        if(/\.java/){
            my $f = File::Spec->rel2abs($_);
            &fix_R($f, $pack, $_);
        }
    }
}

sub fix_R{
    my ($f, $pack, $name) = @_;

    my $data = new Reader($f)->data;

    my $jc = new JavaContent($data);

    if( $jc->replace_R_with_package($pack)){
        print $name . "\n";
        my $data = $jc->data;
        my $w =  new Writer($f);
        $w->write_new($data);
    }
}
