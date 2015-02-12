package My::ModuleBuild;

use strict;
use warnings;
use FFI::CheckLib;
use base qw( Module::Build );

sub new
{
  my($class, %args) = @_;
  
  check_lib_or_exit( lib => 'bz2' );
  
  my $self = $class->SUPER::new(%args);
  $self;
}

1;
