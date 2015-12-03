package Writer;
use warnings;

sub new {
    my $class = shift;
    my $this = {
        _out => shift
    };

    bless $this, $class;
    return $this;
}

## new=>1 create new file
## else append data to end
sub write_new{
    my ($this, $out, $in) = @_;
    #print "(in,out)=>($in, $out)\n";


    ## only one param
    if(!$in or $in=~ /^1$/){
        $in = $out;
        $out = $this->{_out};
    }

    if(length($in)>0){
        open (FILE, ">$out");
        print FILE $in;
        close (FILE);
    }else{
        print STDERR "WARN:Writer:Attend to write empty data to file.\n";
    }
}


return 1;

