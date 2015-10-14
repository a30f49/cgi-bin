package XmlParser;
use lib qw(lib);
use Data::Dumper;

sub new {
    my $class = shift;
    my $this = {
        _xml => shift,
        _node  => undef,
        _data  => undef
    };

    bless $this, $class;

    if($this->{_xml}){
        $this->load($this->{_xml});
    }

    return $this;
}

sub load{
    my ($this, $xml) = @_;

    my $data;
    {
      local $/; #Enable 'slurp' mode
      open my $fh, "<", $xml;
      $data = <$fh>;
      close $fh;
    }

    $this->parse($data);
}

sub node{
    my ($this) = @_;
    return $this->{_node};
}

sub parse{
    my ($this, $data) = @_;


    ## remote \r\n
    $data =~ tr/\r\n/ /;

    ## remote <?xml ?>
    if($data =~ /<\?xml.+\?>/){
        $data =~ s/<\?xml.+\?>//;
    }

    ## remove begin/end space
    $data =~ s/^\s*//;
    $data =~ s/\s*$//;

    ## get first node
    my $node = $this->read_node($data);
}

sub read_node{
    my ($this, $node_data, $parent) = @_;
    if($node_data =~ /^\s*$/){
        ## for end
        return 0;
    }

    my $has_child = has_child($node_data);
    my $node_begin = read_node_half($node_data);
    my $node = parse_node($node_begin);

    ## only once
    if(!$this->{_node}){
        $this->{_node} = $parent;
    }

    if($has_child){

        my $child_node_data = read_first_node($node_data);

        while(has_child($node_data)){

            my $child_node = $this->read_node($child_node_data);

            push(@{$node->{nodes}}, $child_node);
        }
    }

    return $node;


    my $node = parse_node($node_begin);
    $node->{closed} = 0;

    ## only once
    if(!$this->{_node}){
       $this->{_node} = $node;
       $node->{level} = 0;
    }

    ## reach end
    my $is_node_to_end = 0;
    {
        if(is_single_node($node_begin)){
           $is_node_to_end = 1;

        }elsif(is_node_end($node_data)){
            my $end_node_begin = read_node_half($node_data);
            my $node_key = get_node_key($node_begin);
            my $node_end = build_node_end($node_key);
            #print "end_node_begin:node_end($end_node_begin:$node_end)\n";

            if($end_node_begin eq $node_end){
                $is_node_to_end = 1;
                $node_data = cut_node_half($node_data);
            }else{
                ## error
                print "ERROR: invalid xml format:$node_data\n";
                $this->{_node} = undef;
                return 0;
            }
        }
    }

    if($is_node_to_end){
        print "node is close, return.";
        $node->{closed} = 1;  ## closed
        return $node;
    }

    ## node is not closed, has child
    print "node is not closed, has child\n";
    $parent = $node;    ## set current parent, continue to read node
    #print "set parent to node:\n";
    #print Dumper($node);

    ## read child
    print "begin to read child..\n";

    my $has_child=1;
    while($has_child){
        my $child_node = $this->read_node($node_data, $parent);
        print "dump child:\n";
        print Dumper($child_node);
        if($child_node){
            push(@{$parent->{nodes}}, $child_node);
        }

        print "begin cut node,,,,,,,,,,:\n$node_data\n";
        $node_data = cut_node($node_data);
        print "done cut node..........:\n$node_data\n";
        print $node_data;

        if(is_node_end($node_data, $parent->{key})){
            $has_child = 0;
            $node_data = cut_node_half($node_data);
        }

        if($node_data =~ /^\s*$/){
            $has_child = 0;
        }
    }

    print "end loop child, dump parent>>>>>>>>>>\n";
    print Dumper($parent);
    print "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n";
    print $parent->{key};

    ## to node end
    $node->{closed} = 1;
    return $node;
}

sub parse_node{
    my $node_data = shift;
    #print "node_data:$node_data\n";

    my $node = {
        key     => undef,
        attrs   => undef,
        nodes   => undef,
        closed  => 0,
        level   => undef
    };

    $node_data =~ s/^<(\w+)\s+//;
    $node->{key} = $1;

    $node_data =~ s/\/>$//;
    #print "key:$key\n";
    #print "node_data:$node_data\n";

    my %attr_hash;
    {
        my @keys;
        my @attrs = split(/\s+/, $node_data);
        foreach(@attrs){
            my $attr = $_;
            $attr =~ /(.+)=(.+)/;
            #print $1;print $2;
            my $key = $1;
            my $val = $2;
            $attr_hash{$key} = $val;

            push (@keys, $key);
        }

        $attr_hash{'/orders'} = \@keys;
    }
    $node->{attrs} = \%attr_hash;

    #my @keys = keys (%{$node->{attrs}});
    #foreach(@keys){
    #print;print "\n";
    #}
    #print Dumper($node);

    return $node;
}

sub has_child{
    my $node_data = shift;

    my $node_half = read_node_half($node_data);
    if(is_single_node($node_half)){
        return 0;
    }

    my $next_half = read_next_half($node_data);
    if(is_node_end($next_half)){
        return 0;
    }

    return 1;
}

sub cut_node_half{
    my $node = shift;

    my $pos = index($node, ">", 0);

    $node = substr($node, $pos+1, length($node));
    $node =~ s/^\s*//;

    return $node;
}

sub cut_node{
    my $data = shift;
    if($data !~ /^</){
        return $data;
    }

    my $begin = read_node_half($data);
    if(is_single_node($begin)){
        $data = cut_node_half($data);
        return $data;
    }

    ## read next node half
    my $pos = index($data, "<", 1);
    my $pos1 = index($data, ">", $pos);
    my $next = substr($data, $pos, $pos1-$pos+1);
    if($next=~/<\//){
        $data = cut_node_half($data);
        $data = cut_node_half($data);
        return  $data;
    }

    ## directly cut node half
    $data = cut_node_half($data);   #begin
    $data = cut_node($data);        #child node
    $data = cut_node_half($data);   #end

    return $data;
}

sub is_single_node{
    my $node_data = shift;


    my $end_symbol_index = rindex($node_data, "/");
    my $expected_index = length($node_data) - 2;

    return ($end_symbol_index == $expected_index);
}

sub read_node_half{
    my $data = shift;
    if(!$data){
        return undef;
    }

    if($data !~ /^</){
        return undef;
    }

    my $pos = index($data, ">", 0);
    my $node = substr($data, 0, $pos+1);
    chomp($node);

    $node =~ s/^\s*//;
    $node =~ s/\s*$//;

    return $node;
}

sub read_next_half{
    my $node_data = shift;

    my $pos = index($node_data, "<", 1);
    my $pos_next = index($node_data, ">", $pos);

    my $next = substr($node_data, $pos, $pos_next-$pos+1);
    return $next;
}

sub is_node_end{
    my ($node_data, $parent_key) = @_;
    $node_data =~ s/^\s*//; # remove space

    my $node_end = build_node_end($parent_key);
    my $node_half = read_node_half($node_data);
    if($node_end eq $node_half){
        return 1;
    }else{
        return 0;
    }

    if($node_data =~ /^<\//){
        return 1;
    }
    return 0;
}

sub build_node_end{
    my $node_key = shift;
    return "</$node_key>";
}

sub get_node_key{
    my $node = shift;
    $node =~ /^<(\w+)/;
    return $1;
}


sub read_node_legacy{
    my ($this, $node_data, $parent) = @_;
    if($node_data =~ /^\s*$/){
        ## for end
        return 0;
    }
    #if($level>2){
    #    return;
    #}
    #$level++;

    my $node_begin = read_node_half($node_data);
    if($node_begin =~ /^\s*$/){
        return 0;
    }
    $node_data = cut_node_half($node_data);
    if($node_data =~ /^\s*$/){
        return 0;
    }
    print "node_begin=================:\n$node_begin\n";
    print "node_data--------------------:\n$node_data\n";


    my $node = parse_node($node_begin);
    $node->{closed} = 0;

    ## only once
    if(!$this->{_node}){
       $this->{_node} = $node;
       $node->{level} = 0;
    }

    ## reach end
    my $is_node_to_end = 0;
    {
        if(is_single_node($node_begin)){
           $is_node_to_end = 1;

        }elsif(is_node_end($node_data)){
            my $end_node_begin = read_node_half($node_data);
            my $node_key = get_node_key($node_begin);
            my $node_end = build_node_end($node_key);
            #print "end_node_begin:node_end($end_node_begin:$node_end)\n";

            if($end_node_begin eq $node_end){
                $is_node_to_end = 1;
                $node_data = cut_node_half($node_data);
            }else{
                ## error
                print "ERROR: invalid xml format:$node_data\n";
                $this->{_node} = undef;
                return 0;
            }
        }
    }

    if($is_node_to_end){
        print "node is close, return.";
        $node->{closed} = 1;  ## closed
        return $node;
    }

    ## node is not closed, has child
    print "node is not closed, has child\n";
    $parent = $node;    ## set current parent, continue to read node
    #print "set parent to node:\n";
    #print Dumper($node);

    ## read child
    print "begin to read child..\n";

    my $has_child=1;
    while($has_child){
        my $child_node = $this->read_node($node_data, $parent);
        print "dump child:\n";
        print Dumper($child_node);
        if($child_node){
            push(@{$parent->{nodes}}, $child_node);
        }

        print "begin cut node,,,,,,,,,,:\n$node_data\n";
        $node_data = cut_node($node_data);
        print "done cut node..........:\n$node_data\n";
        print $node_data;

        if(is_node_end($node_data, $parent->{key})){
            $has_child = 0;
            $node_data = cut_node_half($node_data);
        }

        if($node_data =~ /^\s*$/){
            $has_child = 0;
        }
    }

    print "end loop child, dump parent>>>>>>>>>>\n";
    print Dumper($parent);
    print "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n";
    print $parent->{key};

    ## to node end
    $node->{closed} = 1;
    return $node;
}


return 1;
