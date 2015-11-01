#!/usr/bin/perl
BEGIN {
    my $cwd = $0;
    $cwd =~ s/\/\w+$//;
    push( @INC, "$cwd/lib");
}
use lib qw(lib);
use strict;
use warnings;

use Data::Dumper;

use Plugin::Tree;
use Plugin::Binding;
use Plugin::Stack;
use Plugin::ModuleTarget;

my $items =
 [
    {
        field=>'asset_name',
        title=>'编号',
        hint=>'餐桌编号'
    },
    {
        field => "asset_alias_name",
        title => "关键字",
        hint => "搜索关键字"
    },
    {
        field =>  "asset_parent_id",
        title => "类别",
        hint => "所属类别"
    }
 ];
my @list = @{$items};

my $binding = new Binding("asset");
my $stack = new Stack('template_input_container');

foreach(@list){
    my $item = $_;
    #print Dumper($item);

    my $item_root = $binding->bind_input_item($item, 'template_input_item');
    #print Dumper($item_root->tree);
    $stack->add_one($item_root);
};


my $module = new ModuleTarget('module-admin', 'fragment_admin_new_asset_smart');
my $target = $module->save($stack->data);

