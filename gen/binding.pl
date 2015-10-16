#!/usr/bin/perl
use lib qw(lib);

use Data::Dumper;

use Android::Module;

use Plugin::Binding;
use Plugin::TemplateProvider;


my $provider = new TemplateProvider();
my $item_root = $provider->get_root("template_input_item");
#print "item-root:".$item_root->key."\n";

my $class = "asset";
my $item = {
    field => 'name',
    title => '编号',
    hint  => '餐桌编号'
};

my $binding = new Binding('asset');
$item_root = $binding->bind_input_item($item, $item_root);

## save
my $module = new Module('module-admin');
my $target = $module->get_xml('new_asset_item');
$item_root->save($target);