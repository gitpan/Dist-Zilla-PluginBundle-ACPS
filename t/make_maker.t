use strict;
use warnings;
use Test::More tests => 2;
use Dist::Zilla::PluginBundle::ACPS;
use Dist::Zilla::PluginBundle::ACPS::MakeMaker;

my @list = Dist::Zilla::PluginBundle::ACPS::MakeMaker->plugin_list;

ok  scalar(grep /^MakeMaker/, @list),   'includes MakeMaker';
ok !scalar(grep /^ModuleBuild/, @list), 'does not include ModuleBuild';
