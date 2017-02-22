#!/usr/bin/perl
BEGIN {
    my $cwd = $0;
    $cwd =~ s/\/[\w-\.]+$//;
    push( @INC, "$cwd/lib");
}
use strict;
use warnings;
use JSON;
use File::Spec;
use Data::Dumper;
use Path;

use File::Writer;

use Android;
use Android::Module;

use Plugin::TemplateProvider;
use Plugin::Binding;
use Plugin::FlowLayout;
use Plugin::FlowStack;

#check android area
my $android = new Android();
if(! Android::is_android_one){
    print STDERR "fatal: Not an android module.\n";
    exit(0);
}

sub usage{
    print "Usage:\n";
    print "  addrow <model> <field,field2...> <type>\n";
    print "    params\n";
    print "      model   -- the model name. e.g. user\n";
    print "      field   -- the field of the model. e.g. name\n";
    print "      type    -- specific the input type of the field\n";
    print "         --input    -- single input type\n";
    print "         --next     -- next to select the value\n";
    print "         --option   -- select option in below bar\n";
}

if(@ARGV < 2){
my $c= @ARGV;
    usage();
    exit(0);
}
my $basename = new Path()->basename;
my $domain = $basename;
$domain =~ /\w+-(\w+)/;
$domain = $1;

my ($model, $field, $type) = @ARGV;
my @fields = split(/,/, $field);
if(!$type){
    $type = "input";
}
$type =~ s/^--//;

my $fragment = &build_fragment_new_layout($model, $domain);

my $module = new Module($basename);
my $fragment_path = $module->xml($fragment);
$fragment_path =~ s/\.xml//;
$fragment_path = "$fragment_path"."_smart.xml";

if(!(-f $fragment_path)){
    &create_fragment_new_layout($fragment_path);
}

## add fields
##
my $layout = new FlowLayout($basename, $fragment_path);
my $container = $layout->container;

my $template_xml = 'template_form_item_'.$type.".xml";
my $template_origin = new TemplateProvider()->template_root($template_xml);

my $stack = new FlowStack($container);

foreach(@fields){
    my $field = $_;
    my $template = $template_origin->copy;

    ## binding
    my $item = &build_new_hash($domain,$model,$field);

    my $binding = new Binding();
    my $item_root = $binding->bind_input_item($item, $template);

    #print Dumper(new Tree($item_root)->tree);
    $stack->add_one($item_root);
}

## save back
my $w = new Writer($fragment_path);
$w->write_new($stack->data);

#my $mc = new ModuleContent($basename);
print $fragment. "\n";

#print "Done\n";


##
## sub func
##
sub create_fragment_new_layout{
    my ($target) = @_;

    my $tp = new TemplateProvider();
    my $layout = $tp->template_root('template_form_new_container.xml');

    my $w= new Writer($target);
    $w->write_new($layout->data);

}

sub build_fragment_new_layout{
    my ($model, $domain) = @_;

    my $fragment;
    if($domain){
        $fragment = "fragment_".$domain."_new_"."$model.xml";
    }else{
        $fragment = "fragment_new_"."$model.xml";
    }

    return $fragment;
}

sub build_new_hash{
    my ($domain, $model, $field) = @_;

    my $hash = {};
    $hash->{title} = '@string/R.string.'.$domain.'_'.$model.'_'.$field.'_title';
    $hash->{hint} = '@string/R.string.'.$domain.'_'.$model.'_'.$field.'_hint';
    $hash->{id} = '@+id/'.$model.'_'.$field;

    return $hash;
}










