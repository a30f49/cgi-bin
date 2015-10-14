#!/usr/bin/perl
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

my $json;
{
  local $/; #Enable 'slurp' mode
  open my $fh, "<", "json/unittest.json";
  $json = <$fh>;
  close $fh;
}

my $PARAM = decode_json($json);
my $target_module = $PARAM->{module};
my $target_xml = $PARAM->{target};
my $target_span = $PARAM->{span};
my $groups = $PARAM->{groups};
#print "(target_module,target_xml)=>($target_module,$target_xml)\n";

### gen flow layout
my $flow = new Flow($target_module);
$flow->container_template("template_unittest_container.xml");
$flow->container_item_template("template_unittest_item.xml");
$flow->divider_template("template_divider.xml");
$flow->divider_group_template("template_divider_group.xml");

$flow->gen($groups);
$flow->save($target_xml);

