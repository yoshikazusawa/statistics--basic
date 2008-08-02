
package Statistics::Basic::Median;

use strict;
use warnings;
use Carp;

use Statistics::Basic;

use overload
    '""' => sub { $Statistics::Basic::fmt->format_number($_[0]->query, $ENV{IPRES}) },
    '0+' => sub { $_[0]->query },
    fallback => 1; # tries to do what it would have done if this wasn't present.

1;

# new {{{
sub new {
    my $this     = shift;
    my $vector   = shift;
    my $set_size = shift;

    warn "[new median]\n" if $ENV{DEBUG} >= 2;

    $this = bless {}, $this;

    if( ref($vector) eq "ARRAY" ) {
        $this->{v} = new Statistics::Basic::Vector( $vector, $set_size );

    } elsif( ref($vector) eq "Statistics::Basic::Vector" ) {
        $this->{v} = $vector;
        $this->{v}->set_size( $set_size ) if defined $set_size;

    } elsif( defined($vector) ) {
        croak "argument to new() too strange";

    } else {
        $this->{v} = new Statistics::Basic::Vector;
    }

    $this->recalc;

    return $this;
}
# }}}
# recalc {{{
sub recalc {
    my $this        = shift;
    my $cardinality = $this->{v}->size;

    delete $this->{median};
    return unless $cardinality > 0;

    my @v = (sort {$a <=> $b} ($this->{v}->query()));
    my $center = int($cardinality/2);
    if ($cardinality%2) {
        $this->{median} = $v[$center];

    } else {
        $this->{median} = ($v[$center] + $v[$center-1]) / 2.0;
    }

    warn "[recalc median] vector[int($cardinality/2)] = $this->{median}\n" if $ENV{DEBUG};
}
# }}}
# query {{{
sub query {
    my $this = shift;

    return $this->{median};
}
# }}}

# size {{{
sub size {
    my $this = shift;

    return $this->{v}->size;
}
# }}}
# set_size {{{
sub set_size {
    my $this = shift;
    my $size = shift;

    eval { $this->{v}->set_size($size) }; croak $@ if $@;
    $this->recalc;
}
# }}}
# set_vector {{{
sub set_vector {
    my $this = shift;

    warn "[set_vector median]\n" if $ENV{DEBUG};

    $this->{v}->set_vector(@_);
    $this->recalc;
}
# }}}
# insert {{{
sub insert {
    my $this = shift;

    warn "[insert median]\n" if $ENV{DEBUG};

    $this->{v}->insert(@_);
    $this->recalc;
}
# }}}
# ginsert {{{
sub ginsert {
    my $this = shift;

    warn "[ginsert median]\n" if $ENV{DEBUG};

    $this->{v}->ginsert(@_);
    $this->recalc;
}
# }}}
