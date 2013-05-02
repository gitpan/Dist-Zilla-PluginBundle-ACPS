use strict;
use warnings;
use Test::More tests => 1;
use Dist::Zilla::PluginBundle::ACPS;
use Path::Class qw( dir );
use FindBin ();

$ENV{DIST_ZILLA_PLUGINBUNDLE_ACPS} = dir($FindBin::Bin)->parent->subdir('share')->stringify;

my $dir = Dist::Zilla::PluginBundle::ACPS->share_dir;

ok -d $dir, "dir = $dir";
