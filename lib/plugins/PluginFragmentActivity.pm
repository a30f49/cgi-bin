package PluginFragmentActivity;
=head1
    get fragment/activity layout from java content

    my $data = new Reader($which_path)->data;
    my $layout = new PluginFragmentActivity($data)->layout;

=cut
use lib qw(lib);
use strict;
use warnings;

use Plugin::JavaContent;
our @ISA = qw(JavaContent);

use Plugin::Matches;

sub new{
    my $class = shift;
    my $self = $class->SUPER::new( @_ );

    bless $self, $class;
    return $self;
}

sub layout{
    my ($this) = @_;

    my $layout;

    my @list = $this->list;

    my $class_name = $this->class_name;

    if($class_name =~ /Fragment$/){
        my $meet_override = 0;
        my $meet_onCreateView  =0;
        my $override_symbol = '@Override';
        my $onCreateView_symbol = 'onCreateView';

        foreach(@list){
            if($layout){next};

            if(/$override_symbol/){
                $meet_override = 1;
            }elsif(/$onCreateView_symbol/){
                $onCreateView_symbol = 1;
            }

            if($meet_override && $onCreateView_symbol){
                if(/inflater.inflate/){
                    $layout = $_;
                    $layout =~ /R.layout.([\w_]+)/;
                    $layout = $1;
                }
            }
        }
    }elsif($class_name =~ /Activity$/){
        print STDERR 'fetal: not implemented.'
    }

    return $layout;
}