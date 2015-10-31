#!/usr/bin/perl
use lib qw(lib);
use File::chdir;
use Cwd;
use strict;
use warnings;
use JSON;

use Data::Dumper;

use Plugin::FlowRaw;

my $raw = new FlowRaw("app");

## get the hash
my $data = $raw->get_raw("fragment_unit_test.xml");
print Dumper($data);


