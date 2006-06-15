package Imager::Filter::RoundedCorner;
use strict;
use warnings;

use Imager;
use Imager::Fill;

our $VERSION = '0.01';

Imager->register_filter(
    type     => 'rounded_corner',
    defaults => { radius => '5', bg => '#ffffff', aa => 0 },
    callseq  => [qw/imager radius bg aa/],
    callsub  => \&round_corner,
);

sub round_corner {
    my %args = @_;
    my ($imager, $radius, $aa, $bg ) = @args{qw/imager radius aa bg/};

    my $corner = Imager->new(
        xsize    => $radius,
        ysize    => $radius,
        channels => 4,
    );
    $corner->box( filled => 1, color => Imager::Color->new( $bg ) );

    $corner->circle(
        color  => Imager::Color->new( 0, 0, 0, 0 ),
        r      => $radius,
        x      => $radius,
        y      => $radius,
        aa     => $aa,
        filled => 1
    );

    my $mask = Imager->new(
        xsize    => $imager->getwidth,
        ysize    => $imager->getheight,
        channels => 4,
    );
    $mask->box( filled => 1, color => Imager::Color->new( 0, 0, 0, 0 ) );

    # left top
    $mask->paste( src => $corner );

    # left bottom
    $corner->flip( dir => 'v' );
    $mask->paste( src => $corner, top => $imager->getheight - $radius );

    # right bottom
    $corner->flip( dir => 'h' );
    $mask->paste(
        src  => $corner,
        top  => $imager->getheight - $radius,
        left => $imager->getwidth - $radius
    );

    # right top
    $corner->flip( dir => 'v' );
    $mask->paste( src => $corner, left => $imager->getwidth - $radius );

    $imager->box(
        fill => Imager::Fill->new( image => $mask, combine => 'normal' ) );
}

=head1 NAME

Imager::Filter::RoundedCorner - Make nifty images with Imager

=head1 SYNOPSIS

    use Imager;
    use Imager::Filter::RoundedCorner;
    
    my $image = Imager->new;
    $image->read( file => 'source.jpg' );
    
    $image->filter(
        type   => 'rounded_corner',
        radius => 10,
        bg     => '#ffffff'
    );
    
    $image->write( file => 'dest.jpg' );

=head1 DESCRIPTION

This filter fill image's corner with 'bg' color as rounded corner.

Filter parameters are:

=over

=item radius

corner's radius

=item bg

background color

=back

=head1 SUBROUTINES

=head2 round_corner

=head1 AUTHOR

Daisuke Murase <typester@cpan.org>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;
