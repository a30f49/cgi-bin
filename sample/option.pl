#!/usr/bin/perl
use lib qw(lib);
use File::chdir;
use Cwd;
use strict;
use warnings;
use JSON;
use utf8;
use Data::Dumper;
use Plugin::Flow;
use Android::Module;

my $json;
{
  local $/; #Enable 'slurp' mode
  open my $fh, "<", "json/option.json";
  $json = <$fh>;
  close $fh;
}

my $PARAM = decode_json($json);
my $target_module = $PARAM->{module};
my $target_xml = $PARAM->{target};
my $target_span = $PARAM->{span};
my $groups = $PARAM->{groups};


### gen flow layout
my $flow = new Flow($target_module);
$flow->container_template("template_option_container.xml");
$flow->container_item_template("template_option_item.xml");
$flow->divider_template("template_divider.xml");
$flow->divider_group_template("template_divider_group.xml");

$flow->gen($groups);
$flow->save($target_xml);
