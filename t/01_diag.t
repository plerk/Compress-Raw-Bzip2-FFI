use strict;
use warnings;
use Test::More tests => 1;
use Compress::Raw::Bzip2::FFI;

diag '';
diag '';
diag '';

diag "bzlibVersion = " . Compress::Raw::Bzip2::FFI::bzlibVersion();

diag '';
diag '';

# check the compat function name
is Compress::Raw::Bzip2::FFI::bzlibVersion(),
   Compress::Raw::Bzip2::FFI::bzlibversion();
