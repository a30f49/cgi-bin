#!/usr/bin/perl
use lib qw(lib);
use File::chdir;
use Cwd;
use strict;
use warnings;
use JSON;
use utf8;
use Data::Dumper;
use Android::Activity;

my $act = new Activity("app");
$act->target_package("com.jfeat.apps.quandian.units");

#$act->gen_with_fragment("com.jfeat.apps.quandian.module.admin.app.AdminUsersFragment");
$act->gen_test_with_fragment("com.jfeat.apps.quandian.module.admin.app.AdminUsersFragment");

