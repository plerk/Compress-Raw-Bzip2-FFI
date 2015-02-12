package Compress::Raw::Bzip2::FFI;

use strict;
use warnings;
use FFI::Platypus 0.22 ();

# ABSTRACT: Low-Level Interface to bzip2 compression library
# VERSION

my $ffi = Compress::Raw::Bzip2::FFI::Platypus->new;
$ffi->find_lib( lib => 'bz2' );

=head1 FUNCTIONS

=head2 bzlibVersion

 my $version = Compress::Raw::Bzip2::FFI::bzlibVersion();

Returns a string representation of of the bzip2 library version.

=head2 bzlibversion

 my $version = Compress::Raw::Bzip2::FFI::bzlibversion();

Same as L</bzlibVersion>, retained for compatibility with 
L<Compress::Raw::Bzip2>.

=cut

$ffi->attach( bzlibVersion => [] => 'string' => '' );
*bzlibversion = \&bzlibVersion;

package
  Compress::Raw::Bzip2::FFI::Platypus;

use base qw( FFI::Platypus );

sub find_symbol
{
 my($self, $symbol) = @_;
 $self->SUPER::find_symbol("BZ2_$symbol") || $self->SUPER::find_symbol($symbol);
}

1;
