package Dist::Zilla::Plugin::ACPS::Mint;

use Moose;
use v5.10;
use Git::Wrapper;

# ABSTRACT: init plugin for ACPS
our $VERSION = '0.24'; # VERSION

with 'Dist::Zilla::Role::AfterMint';
with 'Dist::Zilla::Role::FileGatherer';

use namespace::autoclean;

sub after_mint
{
  my($self, $opts) = @_;

  my $git = Git::Wrapper->new($opts->{mint_root});

  foreach my $remote ($git->remote('-v'))
  {
    # TODO maybe also create the cm repo remote
    if($remote =~ /^public\s+(.*):(public_git\/.*\.git) \(push\)$/)
    {
      my($hostname,$dir) = ($1,$2);
      use autodie qw( :system );
      system('ssh', $hostname, 'git', "--git-dir=$dir", 'init', '--bare');
      $git->push(qw( public master ));
    }
  }

}

sub gather_files
{
  my($self, $arg) = @_;
  $self->gather_file_travis_yml($arg);
}

sub gather_file_travis_yml
{
  my($self, $arg) = @_;

  my $file = Dist::Zilla::File::InMemory->new({
    name    => '.travis.yml',
    content => join("\n", q{language: perl},
                          q{},
                          q{#install:},
                          q{#  - cpanm -n Foo::Bar},
                          q{},
                          q{perl:},
                          (map { "  - \"5.$_\""} qw( 10 12 14 16 18 )),
                          q{},
                          q{#before_script: /bin/true},
                          q{},
                          q{script: HARNESS_IS_VERBOSE=1 prove -lv t xt},
                          q{},
                          q{#after_script: /bin/true},
                          q{},
                          q{branches:},
                          q{  only:},
                          q{    - master},
                          q{},
    ),
  });

  $self->add_file($file);

}

__PACKAGE__->meta->make_immutable;

1;



=pod

=head1 NAME

Dist::Zilla::Plugin::ACPS::Mint - init plugin for ACPS

=head1 VERSION

version 0.24

=head1 DESCRIPTION

Standard init plugin for ACPS distros.

=head1 AUTHOR

Graham Ollis <gollis@sesda3.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by NASA GSFC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

