#!/usr/bin/perl
BEGIN {
    my $cwd = $0;
    $cwd =~ s/\/\w+$//;
    push( @INC, "$cwd/lib");
}
use strict;
use warnings;

use Path;

use Android::Gradle;
use Android::Module;

my $mod = shift;
my $opt_a;

my $ARGC = @ARGV;
if($ARGC==0){
    usage();
    exit(0);
}

while (@ARGV) {
    local $_ = shift @ARGV;
    if ($_ eq '-h' || $_ eq '--help') {
        usage();
        exit(0);

    }elsif($_ eq '-f'){
        &list_fragment;

        exit(0);
    }elsif (/^-./) {
        print STDERR "Unknown option: $_\n";
        usage();
        exit(0);
    }
}

sub usage{
    print "Usage:\n";
    print "  mod <module> -f \n";
    print "    options: module         #the module to list\n";
    print "             -f             #list all fragments in module\n";
}

sub list_fragment{
    my $module = new Module($mod);
    my @fragments = $module->src_fragments;

    foreach(@fragments){
        print;
        print "\n";
        #my $frag = $_;
        #$frag = "\"$frag\"";
        #print "$frag,\n";
    }
}
