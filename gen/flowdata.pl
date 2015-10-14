#!/usr/bin/perl
use lib qw(lib);
use File::chdir;
use Cwd;
use strict;
use warnings;
use JSON;

use Data::Dumper;

use Plugin::FlowData;

my $flow_data = new FlowData("app");

my $data = $flow_data->get_data("fragment_unit_test.xml");
#print Dumper($data);
my $json = $flow_data->json_ready;
$flow_data->save("json/unittest.json", $json);

