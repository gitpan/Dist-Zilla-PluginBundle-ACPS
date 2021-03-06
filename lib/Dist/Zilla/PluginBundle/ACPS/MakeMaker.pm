package Dist::Zilla::PluginBundle::ACPS::MakeMaker;

use Moose;
use v5.10;

# ABSTRACT: Dist::Zilla ACPS bundle that uses MakeMaker instead of ModuleBuild
our $VERSION = '0.30'; # VERSION

extends 'Dist::Zilla::PluginBundle::ACPS';

use namespace::autoclean;

around plugin_list => sub {
  my $orig = shift;
  my $self = shift;
  
  map { (ref $_ ? $_->[0] : $_) =~ s/^ModuleBuild$/MakeMaker/; $_ } $self->$orig(@_);
};

__PACKAGE__->meta->make_immutable;

1;



=pod

=head1 NAME

Dist::Zilla::PluginBundle::ACPS::MakeMaker - Dist::Zilla ACPS bundle that uses MakeMaker instead of ModuleBuild

=head1 VERSION

version 0.30

=head1 DESCRIPTION

This plugin bundle is identical to L<@ACPS|Dist::Zilla::PluginBundle::ACPS> except it uses
[MakeMaker] instead of [ModuleBuild].

=head1 AUTHOR

Graham Ollis <gollis@sesda3.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by NASA GSFC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

