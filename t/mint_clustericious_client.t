use strict;
use warnings;
use Test::More;
use Test::DZil;
use Path::Class qw( file dir );
use FindBin ();

plan skip_all => 'test requires Dist::Zilla::MintingProfile::Clustericious'
  unless eval q{ use Dist::Zilla::MintingProfile::Clustericious; 1 };

plan tests => 1;

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
  [ ACPS => 'client' ],
  { name => 'Foo-Client' },
  { global_config_root => dir('corpus/global')->absolute },
);

$tzil->mint_dist;

like $tzil->slurp_file('mint/lib/Foo/Client.pm'), qr{^package Foo::Client;}, "package Foo";
