
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Basic plugins to maintain and release ACPS dists",
  "dist_author" => [
    "Graham Ollis <gollis\@sesda3.com>"
  ],
  "dist_name" => "Dist-Zilla-PluginBundle-ACPS",
  "dist_version" => "0.30",
  "license" => "perl",
  "module_name" => "Dist::Zilla::PluginBundle::ACPS",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Cwd" => 0,
    "DateTime" => 0,
    "Dist::Zilla" => 0,
    "Dist::Zilla::Plugin::MinimumPerl" => 0,
    "Dist::Zilla::Plugin::OurPkgVersion" => 0,
    "Dist::Zilla::Plugin::PodWeaver" => 0,
    "Dist::Zilla::PluginBundle::Git" => 0,
    "Dist::Zilla::Role::AfterMint" => 0,
    "Dist::Zilla::Role::AfterRelease" => 0,
    "Dist::Zilla::Role::BeforeRelease" => 0,
    "Dist::Zilla::Role::BuildPL" => 0,
    "Dist::Zilla::Role::FileGatherer" => 0,
    "Dist::Zilla::Role::Git::DirtyFiles" => 0,
    "Dist::Zilla::Role::Git::Repo" => 0,
    "Dist::Zilla::Role::MintingProfile" => 0,
    "Dist::Zilla::Role::Plugin" => 0,
    "Dist::Zilla::Role::PluginBundle::Easy" => 0,
    "Dist::Zilla::Role::PrereqSource" => 0,
    "Dist::Zilla::Role::Releaser" => 0,
    "Dist::Zilla::Role::VersionProvider" => 0,
    "File::Copy" => 0,
    "File::HomeDir" => 0,
    "File::ShareDir" => 0,
    "File::Spec" => 0,
    "File::Spec::Functions" => 0,
    "File::Temp" => 0,
    "File::chdir" => 0,
    "Git::Wrapper" => "0.021",
    "IPC::Open3" => 0,
    "IPC::System::Simple" => 0,
    "JSON" => 0,
    "List::MoreUtils" => 0,
    "Moose" => 0,
    "MooseX::AttributeShortcuts" => 0,
    "MooseX::Has::Sugar" => 0,
    "MooseX::Types::Moose" => 0,
    "MooseX::Types::Path::Class" => 0,
    "Path::Class" => 0,
    "Path::Class::Dir" => 0,
    "String::Formatter" => 0,
    "Template" => 0,
    "Try::Tiny" => 0,
    "autodie" => 0,
    "namespace::autoclean" => 0,
    "perl" => "v5.10.0",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => [],
  "share_dir" => {
    "dist" => "share"
  },
  "test_requires" => {
    "FindBin" => 0,
    "Test::DZil" => 0,
    "Test::More" => 0
  }
);


my %fallback_build_requires = (
  "FindBin" => 0,
  "Module::Build" => "0.3601",
  "Test::DZil" => 0,
  "Test::More" => 0
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  delete $module_build_args{test_requires};
  $module_build_args{build_requires} = \%fallback_build_requires;
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
