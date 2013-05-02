use strict;
use warnings;
use Test::More tests => 10;

use_ok 'Dist::Zilla::PluginBundle::ACPS';
use_ok 'Dist::Zilla::PluginBundle::ACPS::Legacy';
use_ok 'Dist::Zilla::PluginBundle::ACPS::MakeMaker';
use_ok 'Dist::Zilla::Plugin::ACPS::Mint';
use_ok 'Dist::Zilla::Plugin::ACPS::Git::Commit';
use_ok 'Dist::Zilla::Plugin::ACPS::Git::CommitBuild';
use_ok 'Dist::Zilla::Plugin::ACPS::Legacy';
use_ok 'Dist::Zilla::Plugin::ACPS::Release';
use_ok 'Dist::Zilla::Plugin::ACPS::RPM';
use_ok 'Dist::Zilla::MintingProfile::ACPS';
