#!/usr/bin/perl
#BEGIN {
#    my $cwd = $0;
#    $cwd =~ s/\/\w+$//;
#    push( @INC, "$cwd/lib");
#}
use lib qw(lib);
use File::chdir;
use Cwd;
use strict;
use warnings;
use JSON;
use utf8;
use Data::Dumper;
use JSON;

use Plugin::Flow;

use Android::Module;

my $data;
{
  local $/; #Enable 'slurp' mode
  open my $fh, "<", "json/desk.json";
  $data = <$fh>;
  close $fh;
}

my $PARAM = decode_json($data);
my $class = $PARAM->{class};
my $fields = $PARAM->{fields};
my $container_item = $PARAM->{container}->{item};
#print "(class,fields)=>($class,$fields)\n";
my $target_module = $container_item->{module};
my $target_xml = $container_item->{target};
if($target_xml !~ /\.xml$/){
  $target_xml = $target_xml.".java";
}

### gen flow layout
my $flow = new Flow($target_module);
$flow->container_template("template_unittest_container.xml");
$flow->container_item_template("template_unittest_item.xml");
$flow->divider_template("template_divider.xml");
$flow->divider_group_template("template_divider_group.xml");

#$flow->gen($groups);
#$flow->save($target_xml);

