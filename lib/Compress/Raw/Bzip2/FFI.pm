package Compress::Raw::Bzip2::FFI;

use strict;
use warnings;
use 5.008001;
use FFI::Platypus 0.22 ();
use Scalar::Util qw( dualvar );
use base qw( Exporter );

# ABSTRACT: Low-Level Interface to bzip2 compression library
# VERSION

our @EXPORT;

my %error_message;

do {

  my @status = (
    [ BZ_STREAM_END       => "End of Stream"      =>  4 ],
    [ BZ_FINISH_OK        => "Finish OK"          =>  3 ],
    [ BZ_FLUSH_OK         => "Flush OK"           =>  2 ],
    [ BZ_RUN_OK           => "Run OK"             =>  1 ],
    [ BZ_OK               => ""                   =>  0 ],
    [ BZ_SEQUENCE_ERROR   => "Sequence Error"     => -1 ],
    [ BZ_PARAM_ERROR      => "Param Error"        => -2 ],
    [ BZ_MEM_ERROR        => "Memory Error"       => -3 ],
    [ BZ_DATA_ERROR       => "Data Error"         => -4 ],
    [ BZ_DATA_ERROR_MAGIC => "Magic Error"        => -5 ],
    [ BZ_IO_ERROR         => "IO Error"           => -6 ],
    [ BZ_UNEXPECTED_EOF   => "Unexpected EOF"     => -7 ],
    [ BZ_OUTBUFF_FULL     => "Output Buffer Full" => -8 ],
  );

  foreach my $status (@status)
  {
    my $name = $status->[0];
    push @EXPORT, $name;
    $error_message{$status->[2]} = $status->[1];
    no strict 'refs';
    *{$name} = sub () { $status->[2] };
  }
};

=head1 SYNOPSIS

 use Compress::Raw::Bzip2::FFI;
 
 my($bz, $status) = Compress::Raw::Bzip2::FFI->new
   or die "Cannot create bzip2 object: $status\n";
 
 my $status = $bz->bzdeflate($input, $output);
 $status = $bz->bzflush($output);
 $status = $bz->bzclose($output);

 ($bz, $status) = Compress::Raw::Bunzip2::FFI->new
   or die "Cannot create bunzip2 object: $status\n";
 
 $status = $bz->bzinflate($input, $output);
 
 my $version = Compress::Faw::Bzip::FFI::bzlibversion();

=head1 DESCRIPTION

L<Compress::Raw::Bzip2::FFI> provides an interface to the in-memory 
compression/decompression functions from the bzip2 library.

It attempts to be a drop in replacement for L<Compress::Raw::Bzip2> 
implemented using FFI instead of XS.

For the decompression interface see L<Compress::Raw::Bunzip2::FFI>

=head1 CONSTRUCTOR

=head2 new

 my($z, $status) = Compress::Raw::Bzip2->new($append, $block_size, $work_factor);
 my $z = Compress::Raw::Bzip2->new($append, $block_size, $work_factor);

Creates a new compression object.

If successful, it will return the initalized compression object, C<$z> 
and a C<$status> of C<BZ_OK> in list context.  In scalar context it 
returns the deflation object C<$z> only.

If not successful, the returned compression object, C<$z> will be 
C<undef> and C<$status> will hold the bzip2 error code.

=over 4

=item $append

Controls whether the compressed data is appended to the output buffer 
in the C<bzdaflate>, C<bzflush> and C<bzclose> methods.

Defaults to 1.

=item $block_size

To quote the bzip2 documentation

 blockSize100k specifies the block size to be used for compression. It
 should be a value between 1 and 9 inclusive, and the actual block size
 used is 100000 x this figure. 9 gives the best compression but takes
 most memory.

Defaults to 1.

=item $work_factor

To quote the bzip2 documentation

 This parameter controls how the compression phase behaves when
 presented with worst case, highly repetitive, input data. If
 compression runs into difficulties caused by repetitive data, the
 library switches from the standard sorting algorithm to a fallback
 algorithm. The fallback is slower than the standard algorithm by
 perhaps a factor of three, but always behaves reasonably, no matter how
 bad the input.
 
 Lower values of workFactor reduce the amount of effort the standard
 algorithm will expend before resorting to the fallback. You should set
 this parameter carefully; too low, and many inputs will be handled by
 the fallback algorithm and so compress rather slowly, too high, and
 your average-to-worst case compression times can become very large. The
 default value of 30 gives reasonable behaviour over a wide range of
 circumstances.

 Allowable values range from 0 to 250 inclusive. 0 is a special case,
 equivalent to using the default value of 30.

Defaults to 0.

=back

=cut

sub new
{
  my($class, $append, $block_size, $work_factor, $verbosity) = @_;
  $append = 1 unless defined $append;
  $block_size = 1 unless defined $block_size;
  $work_factor = 0 unless defined $work_factor;
  $verbosity = 0 unless defined $verbosity; # not documented but present in 
                                            # the original
  
  my $stream = Compress::Raw::Bzip2::FFI::bz_stream->new;
  my $status = _bzCompressInit(
    $stream, $block_size, $verbosity, $work_factor,
  );
  
  if($status != 0) # BZ_OK
  {
    return
      wantarray 
      ? (undef, dualvar($status, $error_message{$status}))
      : ();
  }
  
  my $self = bless {
    stream => $stream,
    append => 1,
  }, $class;
  
  return
    wantarray
    ? ($self, dualvar(0, $error_message{0}))
    : $self;
}

#sub bzdeflate
#{
#  my $self = shift;
#  # $_[0] = buf
#  # $_[1] = output
#  my $stream = $self->{stream};
#  # TODO: original will deref buf if it is a ref
#  $stream->next_in(unpack('L!', pack('P', $_[0])));
#  $stream->avail_in(do { use bytes; length $_[0] });
#  
#}

=head1 FUNCTIONS

=head2 bzlibversion

 my $version = Compress::Raw::Bzip2::FFI::bzlibversion();

Returns a string representation of of the bzip2 library version.

=cut

my $ffi = Compress::Raw::Bzip2::FFI::Platypus->new;
$ffi->find_lib( lib => 'bz2' );

do {
  package
    Compress::Raw::Bzip2::FFI::bz_stream;

  use FFI::Platypus::Record;

  record_layout($ffi, qw(

    opaque next_in
    uint avail_in
    uint total_in_lo32
    uint total_in_hi32
  
    opaque next_out
    uint avail_out
    uint total_out_lo32
    uint total_out_hi32
  
    opaque state
  
    opaque bzalloc
    opaque bzfree
    opaque opaque
  ));
};

$ffi->type( 'record(Compress::Raw::Bzip2::FFI::bz_stream)' => 'bz_stream' );

$ffi->attach( _bzlibVersion => [] => 'string' => '' );
*bzlibversion = \&_bzlibVersion;

$ffi->attach( 
  _bzCompressInit => [ 'bz_stream', 'int', 'int', 'int' ] => 'int' => '$$$$' );
$ffi->attach(
  _bzCompress => [ 'bz_stream', 'int' ] => 'int' => '$$' );
$ffi->attach(
  _bzDecompressInit => [ 'bz_stream', 'int', 'int' ] => 'int' => '$$$' );
$ffi->attach(
  _bzDecompress => [ 'bz_stream' ] => 'int' => '$' );
$ffi->attach(
  _bzDecompressEnd => [ 'bz_stream' ] => 'int' => '$' );

package
  Compress::Raw::Bzip2::FFI::Platypus;

use base qw( FFI::Platypus );

sub find_symbol
{
 my($self, $symbol) = @_;
 $self->SUPER::find_symbol("BZ2$symbol") || $self->SUPER::find_symbol($symbol);
}

1;
