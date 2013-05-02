use strict;
use warnings;
use Test::More tests => 1;
use Test::DZil;
use Path::Class qw( file dir );
use FindBin ();

$ENV{DIST_ZILLA_PLUGINBUNDLE_ACPS} = dir($FindBin::Bin)->parent->subdir('share')->stringify;

eval {
  package Git::Wrapper;
  use Test::More;
  $INC{'Git/Wrapper.pm'} = __PACKAGE__;
  sub new { bless { }, 'Git::Wrapper' }
  foreach my $method (qw( init config add commit remote ))
  {
    eval qq{ sub $method { shift; note("\\\$git->$method(\@_)") } };
    die $@ if $@;
  }
};
die $@ if $@;

my $tzil = Minter->_new_from_profile(
  [ ACPS => 'mbd_app' ],
  { name => 'Foo' },
  { global_config_root => dir('corpus/global')->absolute },
);

$tzil->mint_dist;

like $tzil->slurp_file('mint/lib/Foo.pm'), qr{^package Foo;}, "package Foo";
