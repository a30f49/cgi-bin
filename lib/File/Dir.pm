#!/usr/bin/perl
package Dir;
use warnings;

sub new {
    my $class = shift;
    my $this = {
        _path => shift
    };

    bless $this, $class;
    return $this;
}

sub files{
    my ($this) = @_;
    my $path = $this->{_path};

    my @list;

    opendir(DIR, $path ) || die "Error in opening dir\n";
    while (my $file = readdir(DIR)) {
        # Use a regular expression to ignore files beginning with a period
        next if ($file =~ m/^\./);
        #print "$file\n";

        push @list, $file;
    }
    closedir(DIR);

    return @list;
}

return 1;
