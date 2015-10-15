package Reader;
use warnings;

sub new {
    my $class = shift;
    my $this = {
        _in => shift
    };

    bless $this, $class;
    return $this;
}

sub data{
  my ($this, $in) = @_;
  if(!$in){
    $in = $this->{_in};
  }

  my $data;
  local $/; #Enable 'slurp' mode
  open my $fh, "<", "$in";
  $data = <$fh>;
  close $fh;

  return $data;
}

sub list{
  my ($this, $in) = @_;
  if(!$in){
    $in = $this->{_in};
  }

  my @list;
  #local $/; #Enable 'slurp' mode
  open my $fh, "<", "$in";
  @list = <$fh>;
  close $fh;

  my @newlist;
  foreach(@list){
    my $line = $_;
    chomp($line);
    push(@newlist, $line);
  }

  return @newlist;
}


return 1;