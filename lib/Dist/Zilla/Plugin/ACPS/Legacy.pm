package Dist::Zilla::Plugin::ACPS::Legacy;

use Moose;
use v5.10;
use autodie;
use JSON qw( from_json );

# ABSTRACT: Dist::Zilla plugin for ACPS CIs that are pre-Dist::Zilla
our $VERSION = '0.17'; # VERSION

with qw(
  Dist::Zilla::Role::VersionProvider
  Dist::Zilla::Role::BuildPL
  Dist::Zilla::Role::PrereqSource
);

use namespace::autoclean;

sub provide_version
{
  my($self) = @_;

  my $version;

  foreach my $line (split /\n/, $self->zilla->main_module->content)
  {
    $version = $1 if $line =~ /\$VERSION\s+=\s+["']?(.*?)["']?;/;
  }

  return $version;
}

sub setup_installer
{
  # Build.PL is gathered from a static file.
}

sub register_prereqs
{
  my $self = shift;
  
  my $meta = eval { from_json($self->zilla->root->file('META.json')->slurp) };
  die "unable to load META.json, run ./Build distmeta to generate it: $@" if $@ or !defined $meta;

  foreach my $phase (qw( configure build runtime ))
  {
    if(exists $meta->{prereqs}->{$phase})
    {
      $self->zilla->log("using $phase prereqs from META.json");
      $self->zilla->register_prereqs({ phase => $phase }, %{ $meta->{prereqs}->{$phase}->{requires} });
    }
    else
    {
      $self->zilla->log("WARNING: can't find $phase prereqs from META.json");
    }
  }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Dist::Zilla::Plugin::ACPS::Legacy - Dist::Zilla plugin for ACPS CIs that are pre-Dist::Zilla

=head1 VERSION

version 0.17

=head1 DESCRIPTION

Don't use this direectly, instead use L<@ACPS::Legacy|Dist::Zilla::PluginBundle::ACPS::Legacy>.
This plugin does this:

=over 4

=item *

Determines the version from MainModule::VERSION instead of getting it from the dist.ini.

=back

=head1 AUTHOR

Graham Ollis <gollis@sesda3.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by NASA GSFC.  No
license is granted to other entities.

=cut
