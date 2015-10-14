#!/usr/bin/perl
use lib qw(lib);
use File::chdir;
use Cwd;
use strict;
use JSON;

my %rec_hash = ('a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5);
my $json = encode_json \%rec_hash;
print "$json\n";

