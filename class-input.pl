#!/usr/bin/perl
BEGIN {
    my $cwd = $0;
    $cwd =~ s/\/\w+$//;
    push( @INC, "$cwd/lib");
}
use lib qw(lib);
use strict;
use warnings;

use JSON;

use Plugin::InputFlow;

my $ARGC = @ARGV;
if($ARGC==0){
    usage();
    exit(0);
}

my $json_in = shift;
if( !(-f $json_in) ){
    $json_in = "json/$json_in";
}
if( !(-f $json_in)){
    usage();
    exit(0);
}

sub usage{
    print "Usage:\n";
    print "  input <json>  \n";
    print "     Options: json       ## provide the input param\n";
}

my $data;
{
  local $/; #Enable 'slurp' mode
  open my $fh, "<", "$json_in";
  $data = <$fh>;
  close $fh;
}
#print $data;

my $PARAM = decode_json($data);
my $class = $PARAM->{class};
my $input = $PARAM->{container}->{input};

my $module = $input->{module};
my $target = $input->{target};
my $container = $input->{container};
my $template = $input->{template};
#print "(module,target,container,template)=>($module,$target,$container,$template)\n";

my $flow = new InputFlow();
$flow->container_template("aaaa.xml");
