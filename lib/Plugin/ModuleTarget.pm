package ModuleTarget;
=head1 USAGE
    Save data to module specific xml

    #Sample 1, save xml data to target layout
    my $mt = new ModuleTarget('app', 'fragment_new_user');
    my $from = new XML::Smart->new('template_sample');
    my $from = $xml->data;
    $mt->save($data);

    #Sample 2, copy layout to target module
    my $mt = new ModuleTarget('app');
    $mt->copy_from_layout('template-app', 'activity_options.xml');

    #Sample 3, copy class to target module, param: gen -- short package
    my $mt = new ModuleTarget('app', 'gen');
    $mt->copy_from('template-app', 'OptionsActivity');

=cut

use lib qw(lib);
use strict;
use warnings;
use File::Copy;
use File::Reader;
use File::Writer;

use Android::Module;
use Android::Manifest;

use Plugin::ModuleContent;
use Plugin::JavaContent;

use File::Writer;

sub new{
    my $class = shift;
    my $self = {
        _module => shift,
        _target => shift
    };
    bless $self, $class;
    return $self;
}

sub save{
    my ($this, $data)  = @_;

    my $target_xml = $this->{_target};
    my $module = new Module($this->{_module});
    $target_xml = $module->xml($target_xml);

    my $w = new Writer();
    return $w->write_new($target_xml, $data);
}

###########################
## copy to target module #
######################
sub copy_from_layout{
    my ($this, $mod, $from, $overwrite) = @_;
    $from =~ s/\.xml$//;
    $from = "$from.xml";

    ## to xml
    my $to_mod = new Module($this->{_module});
    my $to_xml = $to_mod->xml($from);

    ## from xml
    my $from_mod = new Module($mod);
    my $from_xml = $from_mod->xml($from);

    if(!(-f $from_xml)){
        print STDERR "$from_xml not exists\n";
        return;
    }

    if(!($overwrite)){
       if(-f $to_xml){
           print STDERR "$to_xml exists\n";
           return;
       }
    }

    return File::Copy::copy( $from_xml, $to_xml );
}


###########################
## copy class to target module #
## param: from -- java class name #
## param: short_pack -- short package to java class #
######################
sub copy_from{
    my ($this, $mod, $from, $short_pack, $overwrite)  = @_;

    ## to
    my $to_mc = new ModuleContent($this->{_module});
    my $to_short_pack = $this->{_target};
    my $to_path = $to_mc->path_to_pack($to_short_pack);
    if(!(-e $to_path)){
        mkdir $to_path;
    }
    my $to_java = $to_mc->locate($from, $to_short_pack);
    #print "(from,to_short_pack,to_java)=> ($from,$to_short_pack,$to_java)\n";

    ## from
    my $from_mc = new ModuleContent($mod);
    my $from_java = $from_mc->locate($from, $short_pack);
    #print "from_java: $from_java\n";

    if(!(-f $from_java)){
        print STDERR "$from_java not exists\n";
        return 0;
    }

    if(!($overwrite)){
       if(-f $to_java){
           print STDERR "$to_java exists\n";
           return 0;
       }
    }

    if(! File::Copy::copy( $from_java, $to_java ) ){
        return 0;
    }

    ## try to modify the package of the target class
    my $java_pack = $to_mc->pack_from_path($to_java);
    if(!$this->_correct_package($java_pack)){
        return 0;
    }

    ## add to manifest
    if($from =~ /Activity$/){
        my $module = new Module($this->{_module});
        my $manifest_path = $module->manifest;
        my $manifest = new Manifest($manifest_path);
        $manifest->append_activity_with_name($from);
        $manifest->save();
    }
}



############################
## correct the package in the class file #
## param: target  -- target class file
##########################
sub _correct_package{
    my ($this, $target) = @_;
    my $java_pack = $target;

    my $mod = $this->{_module};
    my $mc = new ModuleContent($mod);
    my $java_path = $mc->path_to_pack($java_pack);
    $java_path = "$java_path.java";
    if(!(-f $java_path)){
        print STDERR "$java_path not exists\n";
        return 0;
    }

    ## correct package
    my $pack = $java_pack;
    $pack =~ s/\.\w+$//;

    my @list = new Reader($java_path)->list;
    my $data = join("\n", @list);
    my $jc = new JavaContent($data);
    my $package_line = $jc->package_line;
    my $R_line = $jc->R_line;

    my @lines;
    my $line;
    foreach(@list){
         $line = $_;

        if(/$package_line/){
            $line = "package $pack;";
        }elsif(/$R_line/){
            $line = "import $pack.R;";
        }

        push(@lines, $line);
    }

    my $w = new Writer($java_path);

    $data = join("\n", @lines);
    $w->write_new($data);

    return 1;
}

return 1;
