package ActivityGenerator;
=head1
    params:
        app  - target module
        test - target short pack

    my $act = new ActivityGenerator("app", "test");  ## test - short package
    $act->gen_act("com.jfeat.modules.dummy.DummyFragment");

=cut

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

use Plugin::ModuleContent;
use Plugin::Matches;

sub new{
    my $class = shift;
    my $self = {
        _target_module  => shift,
        _target_package => shift,
        _new_activity => undef,
    };
    bless $self, $class;

    ## reset target package
    return $self;
}

sub new_activity{
    my ($this) = @_;
    return $this->{_new_activity};
}

sub target_module{
   my ($this, $mod) = @_;
   if($mod){
       $this->{_target_module} = $mod;
   }
   return $this->{_target_module};
}

#########################
## the short package  #
#######################
sub target_package{
    my ($this, $pack) = @_;
    if($pack){
        $this->{_target_package} = $pack;
    }
    return $this->{_target_package};
}

#####################
## Gen new activity for fragment #
## param: fragment - long fragment with full pack #
#####################
sub gen_act{
    my ($this, $which_pack, $test, $overwrite) = @_;
    if(!$which_pack){
        die "fetal: no fragment to be added.\n";
    }

    ## split fragment package
    my ($which_pack_only, $which, $which_prefix);
    ($which_pack_only , $which) = Matches::split_package($which_pack);
    $which_prefix = $which;
    $which_prefix =~ s/Fragment$//;
    #print "(pack,frag, prefix)=>($pack, $which, $which_prefix)\n";

    ## activity target package
    my $target_pack_only = $this->build_target_package;
    #print "$target_pack_only: $target_pack_only\n";

    ## activity target name
    my $target_act = $which_prefix."Activity";
    if($test){
        $target_act = $target_act."ForTest";
    }
    my $target_pack = $target_pack_only.'.'.$target_act;
    #print "target pack: $target_pack\n";
    $this->{_new_activity} = $target_pack;

    my $mc = new ModuleContent($this->target_module);
    my $target_path = $mc->path_to_pack($target_pack);
    my $target_manifest_pack = $mc->pack;
    my $target_path_name = "$target_path.java";
    #print "target activity: $target_path_name\n";

    ## get src
    my $template = new Template();
    my $act_src_path = $template->get_src("TemplateActivity");
    #print "template activity:\n$act_src_path\n";
    if(-f $act_src_path){
    }else{
        die "fetal: TemplateActivity.java not exists\n";
    }

    ## init data
    my $data;
    {
        $data = new Reader($act_src_path)->data;
        #print $act_src_path;

        my $title;
        {
            my $ss = $which_prefix;
            $ss =~ /([A-Z][a-z0-9]+)([A-Z][a-z0-9]+)*$/;
            my $a1 = $1; my $a2 = $2;
            #print "(ss:a1:a2)=>($ss,$a1,$a2)\n";
            $a1 =~ tr/[A-Z]/[a-z]/;$a2 =~ tr/[A-Z]/[a-z]/;
            $title = "R.string.title_activity_".$a1;
            if($a2){
                $title = $title."_".$a2
            }
            #print "new_title:$ss <> $title\n";
        }

        ## to title
        if($title){
            my $title_line0 = "R.string.title_activity_template";
            my $title_line = "\"$title\"";
            if($title =~ /^R\.string\./){
                $title_line = $title;
            }
            $data =~ s/$title_line0/$title_line/;
        }

        ## to target package
        my $pack_line0 = "package com.jfeat.plugin.template";
        my $pack_line = "package $target_pack_only";
        $data =~ s/$pack_line0/$pack_line/;

        ## to new Fragment
        my $new_line0 = "new TemplateFragment";
        my $new_line = "new $which";
        $data =~ s/$new_line0/$new_line/;

        ## to target import
        my $import_line0 = "import com.jfeat.plugin.template.TemplateFragment;";
        my $import_line = "import $which_pack_only.$which;";
        #print "(act_pack,pack)=>($target_pack_only,$pack)\n";
        if($which_pack_only eq $target_pack_only){
            $import_line = undef;
        }
        $data =~ s/$import_line0/$import_line/;

        # import R
        my $import_line_r0 = "import com.jfeat.plugin.template.R";
        my $import_line_r = "import $target_manifest_pack.R";
        $data =~ s/$import_line_r0/$import_line_r/;
        $data =~ s/TemplateFragment/$which/;

        ## to target class
        my $class_line0 = "class TemplateActivity";
        my $class_line = "class $target_act";
        $data =~ s/$class_line0/$class_line/;
    }
    #print $data;print "\n";


    my $write_new = 0;
    if($overwrite){
        $write_new = 1;
    }elsif(-f $target_path_name){
        print STDERR "$target_path_name exists";
        $write_new = 0;
    }else{
        $write_new = 1;
    }

    if($write_new){
        my $writer = new Writer($target_path_name);
        $writer->write_new($data);
        #print "(target_path)=>($target_path)\n";
    }

    ## manifest
    if($write_new){
        my $activity_pack_relative = $target_pack;
        #print "(act_pack,manifest_pack)=>(target_pack,$target_manifest_pack)\n";

        $activity_pack_relative =~ s/$target_manifest_pack//;
        #print "activity_pack_relative:$activity_pack_relative\n";

        my $target_module = $this->target_module;
        my $module = new Module($target_module);
        my $manifest_path = $module->manifest;
        my $manifest = new Manifest($manifest_path);
        $manifest->append_activity_with_name($activity_pack_relative);
        $manifest->save();
    }
}

sub build_target_package{
    my ($this) = @_;

    my $target = $this->target_module;
    my $short_pack = $this->target_package;

    my $mc = new ModuleContent($target);
    my $pack = $mc->pack_with($short_pack);

    ## make dir of full package
    my $dir = $mc->path_to_pack($pack);
    if(-d $dir){
    }else{
       mkdir($dir);
    }

    if(-d $dir){
    }else{
        die "fetal: fail to mkdir - $dir\n";
    }

    return $pack;
}

return 1;
