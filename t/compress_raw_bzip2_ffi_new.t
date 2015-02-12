use strict;
use warnings;
use Test::More tests => 2;
use Compress::Raw::Bzip2::FFI;

subtest 'scalar context' => sub {
  plan tests => 2;

  subtest 'good' => sub {
    plan tests => 1;
    my $bz = Compress::Raw::Bzip2::FFI->new;
    isa_ok $bz, 'Compress::Raw::Bzip2::FFI';
  };
  
  subtest 'bad' => sub {
    plan tests => 1;
    my $bz = Compress::Raw::Bzip2::FFI->new(0, 100, 500);
    is $bz, undef;
  };
  
};

subtest 'array context' => sub {
  plan tests => 2;

  subtest 'good' => sub {
    plan tests => 3;
    my($bz, $status) = Compress::Raw::Bzip2::FFI->new;
    isa_ok $bz, 'Compress::Raw::Bzip2::FFI';
    is int $status, 0, "int status = 0";
    is "$status", "", "status = $status";
  };
  
  subtest 'bad' => sub {
    plan tests => 2;
    my($bz, $status) = Compress::Raw::Bzip2::FFI->new(0, 100, 500);
    is $bz, undef;
    isnt $status, 0, "status = $status";
  };

};
