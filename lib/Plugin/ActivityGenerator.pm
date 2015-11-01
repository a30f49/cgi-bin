package ActivityGenerator;
=head1
    params:
        app  - target module
        test - target package with short name

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

use Plugin::Flow;
use Plugin::SmartWrapper;
use Plugin::ModuleContent;

sub new{
    my $class = shift;
    my $self = {
        _target_module  => shift,
        _target_package => shift,
        _activity => undef
    };
    bless $self, $class;

    ## reset target package

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

    ## short package, to get full package
    if($this->{_target_package} =~ /^\w+$/){
        $pack = $this->{_target_package};

        my $mc = new ModuleContent($this->target_module);

        my $manifest_pack = $mc->pack;
        $pack = "$manifest_pack.$pack";
        $this->{_target_package} = $pack;

        ## make dir of full package
        my $dir = $mc->pack_to_path($pack);
        if(-d $dir){
        }else{
            mkdir($dir);
        }

        if(-d $dir){
        }else{
            print STDERR "ActivityGenerator: fail to mkdir - $dir\n";
        }
    }

    return $this->{_target_package};
}

sub new_activity{
    my ($this) = @_;
    return $this->{_activity};
}


#####################
## Gen new activity for fragment #
## param: fragment - long fragment with full pack #
#####################
sub gen_act{
    my ($this, $fragment, $test, $overwrite) = @_;

    if(!$fragment){
        print STDERR "ActivityGenerator: no fragment param.\n";
        return;
    }


    my ($pack, $frag, $frag_prefix) = parse_fragment_pack($fragment);
    #print "(fragment, pack,frag, prefix)=>($fragment, $pack, $frag, $frag_prefix)\n";

    ## activity target package
    my $target_pack = $this->target_package;
    if(!$target_pack){
        ## of fragment package
        $target_pack = $pack;
    }
    ## activity target name
    my $target_act = $frag_prefix."Activity";
    if($test){
        $target_act = $target_act."ForTest";
    }
    my $target_act_long = $target_pack."\.".$target_act;
    #print "target activity: $target_act_long\n";

    my $mc = new ModuleContent($this->target_module);
    my $target_path = $mc->pack_to_path($target_act_long);
    my $target_manifest_pack = $mc->pack;
    my $target_path_name = "$target_path.java";
    #print "target activity: $target_path\n";

    ## get src
    my $template = new Template();
    my $act_src_path = $template->get_src("TemplateActivity");
    #print "template activity:\n$act_src_path\n";
    if(-f $act_src_path){
    }else{
        print STDERR "ActivityGenerator: template activity not exists\n";
        return;
    }

    ## init data
    my $data;
    {
        $data = new Reader($act_src_path)->data;
        #print $act_src_path;

        my $title;
        {
            my $ss = $frag_prefix;
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
            my $target_pack = $this->target_package;
            my $title_line0 = "R.string.title_activity_template";
            my $title_line = "\"$title\"";
            if($title =~ /^R\.string\./){
                $title_line = $title;
            }
            $data =~ s/$title_line0/$title_line/;
        }

        ## to target package
        my $pack_line0 = "package com.jfeat.plugin.template";
        my $pack_line = "package $target_pack";
        $data =~ s/$pack_line0/$pack_line/;

        ## to new Fragment
        my $new_line0 = "new TemplateFragment";
        my $new_line = "new $frag";
        $data =~ s/$new_line0/$new_line/;

        ## to target import
        my $import_line0 = "import com.jfeat.plugin.template.TemplateFragment;";
        my $import_line = "import $pack.$frag;";
        #print "(act_pack,pack)=>($target_pack,$pack)\n";
        if($pack eq $target_pack){
            $import_line = undef;
        }
        $data =~ s/$import_line0/$import_line/;

        # import R
        my $import_line_r0 = "import com.jfeat.plugin.template.R";
        my $import_line_r = "import $target_manifest_pack.R";
        $data =~ s/$import_line_r0/$import_line_r/;
        $data =~ s/TemplateFragment/$frag/;

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
        print STDERR "Activity \"$target_path_name\" exists, passed.\n";
        $write_new = 0;
        return undef;
    }else{
        $write_new = 1;
    }

    if($write_new){
        my $writer = new Writer();
        $writer->write_new($target_path_name, $data);
        #print "(target_path)=>($target_path)\n";
    }

    ## add activity to manifest
    my $activity_pack_relative = $target_act_long;
    #print "(act_pack,manifest_pack)=>($target_act_long,$target_manifest_pack)\n";
    $activity_pack_relative =~ s/$target_manifest_pack//;
    #print "activity_pack_relative:$activity_pack_relative\n";
    $this->{_activity} = $activity_pack_relative;

    ## manifest
    my $target_module = $this->target_module;
    my $module = new Module($target_module);
    my $manifest_path = $module->manifest;
    my $manifest = new Manifest($manifest_path);
    $manifest->append_activity_with_name($activity_pack_relative);
    $manifest->save();
}

sub parse_fragment_pack{
    my $fragment = shift;

    my ($fragment_pack, $fragment_name, $fragment_prefix);

    $fragment =~ /([\w\.]+)\.(\w+)$/;
    $fragment_pack = $1;
    $fragment_name = $2;

    $fragment_prefix = $fragment_name;
    $fragment_prefix =~ s/Fragment$//;
    #$fragment_prefix =~ tr/[A-Z]/[a-z]/;

    return ($fragment_pack, $fragment_name, $fragment_prefix);
}

return 1;
