package ActivityGenerator;
use lib qw(lib);
use File::chdir;
use Cwd;
use strict;
use warnings;
use XML::Smart;
use Path;
use JSON;
use utf8;
use Data::Dumper;

use File::Reader;
use File::Writer;

use Android::Template;
use Android::Module;
use Android::Manifest;

use Plugin::Flow;
use Plugin::SmartWrapper;


sub new{
    my $class = shift;
    my $self = {
        _target_module  => shift,
        _target_package => shift,
    };
    bless $self, $class;

    return $self;
}

sub target_module{
   my ($this, $mod) = @_;

   if($mod){
       $this->{_target_module} = $mod;
   }

   return $this->{_target_module};
}

sub target_package{
    my ($this, $pack) = @_;

    if($pack){
        $this->{_target_package} = $pack;
    }
    return $this->{_target_package};
}

sub manifest_package{
    my ($this) = @_;

    my $target_module = $this->target_module;
    my $module = new Module($target_module);
    my $manifest_path = $module->manifest;

    my $manifest = new Manifest($manifest_path);
    my $manifest_pack = $manifest->pack;

    return $manifest_pack;
}

sub gen_test_with_fragment{
    my ($this, $fragment) = @_;

    $fragment =~ /([\w\.]+)\.(\w+)$/;
    my $pack = $1;
    my $frag = $2;
    my $frag_prefix = $frag;
    $frag_prefix =~ s/Fragment$//;
    #print "(pack,fragment, prefix)=>($pack, $frag, $frag_prefix)\n";
    my $act_pack = $this->target_package;
    my $act_target = $frag_prefix."ActivityForTest";
    my $act_class = $act_pack."\.".$act_target;

    my $target_module = $this->target_module;
    my $module = new Module($target_module);
    my $manifest_path = $module->manifest;

    my $manifest = new Manifest($manifest_path);
    my $manifest_pack = $manifest->pack;


    ## get src
    my $template = new Template();

    my $act_src_path = $template->get_src("TemplateActivityForTest");

    ## init data
    my $data;
    {
        $data = new Reader($act_src_path)->data;
        #print $act_src_path;

        ## to target package
        my $target_pack = $this->target_package;
        my $pack_line0 = "package com.jfeat.plugin.template";
        my $pack_line = "package $target_pack";
        $data =~ s/$pack_line0/$pack_line/;

        ## to new Fragment
        my $new_line0 = "new TemplateFragment";
        my $new_line = "new $frag";
        $data =~ s/$new_line0/$new_line/;

        ## to target import
        my $import_line0 = "import com.jfeat.plugin.template.TemplateFragment";
        my $import_line = "import $pack.$frag";
        $data =~ s/$import_line0/$import_line/;

        # import R
        my $import_line_r0 = "import com.jfeat.plugin.template.R";
        my $import_line_r = "import $manifest_pack.R";
        $data =~ s/$import_line_r0/$import_line_r/;
        $data =~ s/TemplateFragment/$frag/;

        ## to target class
        my $class_line0 = "class TemplateActivityForTest";
        my $class_line = "class $act_target";
        $data =~ s/$class_line0/$class_line/;
    }
    #print $data;

    ## write to target
    my $target_package = $this->target_package;
    my $target_path = $module->src($this->target_package, $act_target);
    #print "(target_module, target_package)=>($target_module, $target_package)\n";

    my $writer = new Writer();
    $writer->write_new($target_path, $data);
    #print "(target_path, data)=>($target_path,\n $data)\n";


    ## add activity to manifest
    my $activity_pack_relative = $act_class;
    #print "(act_pack,manifest_pack)=>($act_class,$manifest_pack)\n";
    $activity_pack_relative =~ s/$manifest_pack//;
    #print "activity_pack_relative:$activity_pack_relative\n";
    $manifest->append_activity_with_name($activity_pack_relative);
    $manifest->save();
}




return 1;
