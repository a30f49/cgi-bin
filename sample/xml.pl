#!/usr/bin/perl
use lib qw(lib);
use strict;
use warnings;
use JSON;
use Android::XmlParser;
use Android::GradleRoot;
use Android::Gradle;
use XML::Smart;
use Data::Dumper;
use Android::Template;

my $gr = new GradleRoot();
my $root = $gr->root;
my $module_root =$gr->module_root("app");
my $gradle = new Gradle($module_root);

my $xml_relative = $gradle->xml("activity_option.xml");
my $xml_path = new Path($module_root)->with($xml_relative)->path;
my $xml = XML::Smart->new($xml_path);

## add divider
my $template = new Template();
my $divider_hash = $template->get_tree("template_divider.xml");
my $xml_divider_key = $template->get_root;
print Dumper($divider_hash);

#push (@{$xml->{FrameLayout}->{'/order'}}, $xml_divider_key);
#$xml->{FrameLayout}->{$xml_divider_key} = $divider_hash;
push (@{$xml->{FrameLayout}->{$xml_divider_key}}, $divider_hash);
#$xml->tree->{FrameLayout}->{'/nodes'}->{$xml_divider_key} = 1;


## save back
my $xml_1 = $gradle->xml("activity_option_1.xml");
my $xml_path_1 = new Path($module_root)->with($xml_1)->path;
$xml->save($xml_path_1);


my $xml_hash = $gradle->xml("activity_option_hash.json");
my $xml_path_hash = new Path($module_root)->with($xml_hash)->path;
$xml->save($xml_path_hash);
my $dump_data = Dumper($xml->tree);
  open (FILE, ">$xml_path_hash");
  print FILE $dump_data;
  close (FILE);

