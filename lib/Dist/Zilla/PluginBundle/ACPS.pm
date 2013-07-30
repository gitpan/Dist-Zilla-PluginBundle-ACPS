package Dist::Zilla::PluginBundle::ACPS;

use Moose;
use v5.10;
use Dist::Zilla;
use Dist::Zilla::Plugin::PodWeaver;
use Dist::Zilla::PluginBundle::Git;
use Dist::Zilla::Plugin::OurPkgVersion;
use Path::Class qw( file dir );
use File::ShareDir qw( dist_dir );

# ABSTRACT: the basic plugins to maintain and release ACPS dists
our $VERSION = '0.27'; # VERSION

with 'Dist::Zilla::Role::PluginBundle::Easy';

use namespace::autoclean;

sub plugin_list {
  (qw(
    GatherDir ),
    [ PruneCruft => { except => '.travis.yml' } ],
   qw(ManifestSkip
    MetaYAML
    MetaJSON
    License
    Readme
    ExecDir
    ModuleBuild
    Manifest
    TestRelease
    ConfirmRelease

    PodWeaver
    NextRelease
    AutoPrereqs
    OurPkgVersion
  ))
}

sub allow_dirty { [ 'Changes', 'dist.ini', 'README.pod' ] };

sub mvp_multivalue_args { qw( allow_dirty ) }

sub is_legacy { 0 }

sub configure {
  my($self) = @_;

  $self->add_plugins($self->plugin_list);

  my $allow_dirty = $self->allow_dirty;
  if(defined $self->payload->{allow_dirty})
  {
    push @{ $allow_dirty }, @{ $self->payload->{allow_dirty} };
  }

  $self->add_plugins(
    ['Git::Check', { allow_dirty => $allow_dirty } ], 
    'ACPS::Git::Commit',
    ($self->is_legacy ? () : ('ACPS::Git::CommitBuild')),
    ['ACPS::Release', { legacy => $self->is_legacy } ],
  );
}

sub share_dir
{
  my($class) = @_;
  
  state $dir;
  
  unless(defined $dir)
  {
    if(defined $ENV{DIST_ZILLA_PLUGINBUNDLE_ACPS})
    { $dir = dir( $ENV{DIST_ZILLA_PLUGINBUNDLE_ACPS} ) }
    elsif(defined $Dist::Zilla::PluginBundle::ACPS::VERSION)
    { $dir = dir(dist_dir('Dist-Zilla-PluginBundle-ACPS')) }
    else
    { 
      $dir = file(__FILE__)
        ->absolute
        ->dir
        ->parent
        ->parent
        ->parent
        ->parent
        ->subdir('share');
    }
  }
  
  return $dir;
}

__PACKAGE__->meta->make_immutable;

1;



=pod

=head1 NAME

Dist::Zilla::PluginBundle::ACPS - the basic plugins to maintain and release ACPS dists

=head1 VERSION

version 0.27

=head1 DESCRIPTION

Plugin bundle for creating and maintaining Perl distributions for ACPS.
It is equivalent to this:

 [GatherDir]
 [PruneCruft]
 [ManifestSkip]
 [MetaYAML]
 [MetaJSON]
 [License]
 [Readme]
 [ExecDir]
 [ModuleBuild]
 [Manifest]
 [TestRelease]
 [ConfirmRelease]
 
 [PodWeaver]
 [NextRelease]
 [AutoPrereqs]
 [OurPkgVersion]
 
 [Git::Check]
 [ACPS::Git::Commit]
 [ACPS::Release]

=head1 AUTHOR

Graham Ollis <gollis@sesda3.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by NASA GSFC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

