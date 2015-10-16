#!/usr/bin/perl
BEGIN {
    my $cwd = $0;
    $cwd =~ s/\/\w+$//;
    push( @INC, "$cwd/lib");
}
use strict;
use warnings;

my $ARGC = @ARGV;
if($ARGC==0){
    usage();
    exit(0);
}

sub usage{
    print "Usage:\n";
    print "  item <json>  \n";
    print "     Options: json       ## provide the input param\n";
}

my $json_in = shift;
if( !(-f $json_in) ){
    $json_in = "json/$json_in";
}

if( !(-f $json_in)){
    usage;
    exit(0);
}

my $data;
{
  local $/; #Enable 'slurp' mode
  open my $fh, "<", "$json_in";
  $data = <$fh>;
  close $fh;
}

#print $data;