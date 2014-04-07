package Dist::Zilla::Plugin::ACPS::Release;

# ABSTRACT: release plugin for ACPS
our $VERSION = '0.28'; # VERSION

use Moose;
use v5.10;
use Git::Wrapper;

with 'Dist::Zilla::Role::BeforeRelease';
with 'Dist::Zilla::Role::Releaser';
with 'Dist::Zilla::Role::AfterRelease';

use namespace::autoclean;

has legacy => (
  is      => 'ro',
  isa     => 'Bool',
  default => 0,
);

sub before_release
{
  my $self = shift;

  my $git = Git::Wrapper->new($self->zilla->root);
  
  if($self->legacy)
  { $self->log("legacy release") }
  else
  { $self->log("new-fangled release") }
  
  my $version = $self->zilla->version;
  foreach my $tag ($version, "dist-$version")
  {
    $self->log_fatal("tag $tag already exists")
      if $git->tag('-l', $tag );
  }
}

sub release
{
  my($self, $archive) = @_;

  my $version = $self->zilla->version;
  my $git = Git::Wrapper->new($self->zilla->root);

  if(!$self->legacy)
  {
    $self->log("tag $version");
    $git->tag("-m", "version $version", $version, 'release');
    $self->log("tag dist-$version");
    $git->tag("-m", "version $version", "dist-$version", 'master');
  }
  else
  {
    $self->log("tag $version");
    $git->tag('-m', "version $version", $version, 'master');
  }
}

sub after_release
{
  my($self) = @_;
  
  my $git = Git::Wrapper->new($self->zilla->root);
  
  my $repo = $ENV{ACPS_RELEASE_MAIN_REPO} // 'public';
  
  if(!$self->legacy)
  {
    $self->log("update Changes");
    if(-r 'README.pod')
    {
      $git->commit({ message => "update Changes + README.pod" }, 'Changes', 'README.pod');
    }
    else
    {
      $git->commit({ message => "update Changes" }, 'Changes');
    }
    $self->log("push");
    $git->push($repo);
    $git->push($repo, "release");
    $self->log("push tags");
    $git->push($repo, "--tags");
    $git->push($repo, "--tags", "release");
  }
  else
  {
    $self->log("push");
    $git->push($repo);
    $self->log("push tags");
    $git->push($repo, "--tags");
  }
}

__PACKAGE__->meta->make_immutable;
1;



=pod

=head1 NAME

Dist::Zilla::Plugin::ACPS::Release - release plugin for ACPS

=head1 VERSION

version 0.28

=head1 DESCRIPTION

Plugin for Dist::Zilla release hooks for ACPS.  For now this
only checks to ensure that the current version does not
already have a tag.  If you get an error like this:

 there is already a tag for this version: 0.1

then bump the version in dist.ini and run dzil release again.

=head1 AUTHOR

Graham Ollis <gollis@sesda3.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by NASA GSFC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

