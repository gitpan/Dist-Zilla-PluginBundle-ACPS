package Dist::Zilla::Plugin::ACPS::RPM;

use Moose;
use v5.10;
use Dist::Zilla::MintingProfile::ACPS;
use Dist::Zilla::PluginBundle::ACPS;
use Path::Class qw( dir file );
use File::HomeDir;
use File::Copy qw( copy );
use List::MoreUtils qw( uniq );
use Template;

# ABSTRACT: RPM Dist::Zilla plugin for ACPS
our $VERSION = '0.27'; # VERSION

with 'Dist::Zilla::Role::Plugin';

use namespace::autoclean;

has 'spec_template' => (
  is => 'ro',
  default => sub { 
    Dist::Zilla::PluginBundle::ACPS
      ->share_dir
      ->subdir('rpm')
      ->file('dist.spec.tt')
      ->stringify;
  },
);

has 'prefer_make_maker' => (
  is => 'ro',
  default => 0,
);

has 'filter_requires' => (
  is => 'ro',
  isa => 'ArrayRef[Str]',
);

sub mvp_multivalue_args { qw(filter_requires) }

sub mk_spec {
  my($self, $archive, $spec_filename) = @_;

  # this is different from the superclass, we allow fully qualified filenames, because
  # we want to keep the spec template in the share directory with the other profile
  # stuff.
  my $template = $self->spec_template =~ /^\// ? $self->spec_template : $self->zilla->root->file($self->spec_template);

  my $tt2 = Template->new( ABSOLUTE => 1 );

  my $release = do {
    my $name    = $self->zilla->name;
    my $version = $self->zilla->version;
    $self->log("% ap nextrelease acps-$name $version");
    `ap nextrelease acps-$name $version`;
  };
  chomp $release;
  
  my $vars = {
    zilla => $self->zilla,
    rpm   => { 
      prefer_make_maker => $self->prefer_make_maker,
      archive           => $archive,
      version           => $self->zilla->version,
      release           => $release,
      requires          => [map { "perl($_)" } uniq sort grep !/^perl$/, $self->zilla->prereqs->requirements_for('runtime', 'requires')->required_modules],
      build_requires    => [map { "perl($_)" } uniq sort grep !/^perl$/, map { $self->zilla->prereqs->requirements_for($_, 'requires')->required_modules } qw( configure build test runtime )],
      filter_requires   => $self->filter_requires,
    },
  };

  $template .= ''; # make sure this is a string and not an object
  $self->log("using spec template: " . $template);
  my $spec_text = '';
  $tt2->process($template, $vars, \$spec_text) || $self->log_fatal("TT2 error: " . $tt2->error);

  $self->log("creating spec: " . $spec_filename)
    if defined $spec_filename;

  return $spec_text;
}

sub mk_rpm {
  my $self = shift;

  $self->log_fatal("first create a ~/rpmbuild directory (and make sure rpmbuild is installed)")
  unless -d dir(File::HomeDir->my_home, 'rpmbuild');

  mkdir dir(File::HomeDir->my_home, 'rpmbuild', $_) for qw( BUILD RPMS SOURCES SPECS SRPMS );

  my $tar = sprintf('%s-%s.tar.gz',$self->zilla->name,$self->zilla->version);

  $self->log_fatal("could not find tar file (expected $tar to work)") unless -f $tar;

  # create .rpmmacros file if it doesn't already exist.
  do {
    my $rpmmacros_file = file(File::HomeDir->my_home, '.rpmmacros');
    unless(-f $rpmmacros_file)
    {
      $self->log("creating " . $rpmmacros_file);
      my $fh = $rpmmacros_file->openw;
      say $fh '%packager %(echo "$USER")';
      say $fh '%_topdir %(echo $HOME)/rpmbuild';
      $fh->close;
    }
  };

  # copy tar to SOURCES directory
  do {
    my $from = $tar;
    my $to   = file(File::HomeDir->my_home, 'rpmbuild', 'SOURCES', $tar);
    $self->log("copy tar: $to");
    copy($from, $to) || $self->log_fatal("Copy failed: $!");
  };
    
  # generate spec file
  my $spec = do {
    my $outfile = Path::Class::File->new(File::HomeDir->my_home, qw( rpmbuild SPECS ), $self->zilla->name . '.spec');
    my $out = $outfile->openw;
    $self->log("creating spec: " . $outfile);
    print $out $self->mk_spec($tar);
    $outfile;
  };

  # build rpm
  my @rpms = split /\n/, `ap build $spec`;
  $self->log("generate rpm: " . $_) for @rpms;
  
  @rpms;
}

sub install_rpm
{
  my($self, @rpms) = @_;
  $self->log("installing rpm: " . $_) for @rpms;
  `ap install @rpms`;
}

sub upload_rpm
{
  my($self, @rpms) = @_;
  $self->log("uploading rpm: " . $_) for @rpms;
  `ap upload @rpms`;
  $self->log("createrepo on build");
  `restyumclient-createrepo build`;
}

__PACKAGE__->meta->make_immutable;

1;



=pod

=head1 NAME

Dist::Zilla::Plugin::ACPS::RPM - RPM Dist::Zilla plugin for ACPS

=head1 VERSION

version 0.27

=head1 SYNOPSIS

 [ACPS::RPM]
 ; spec_template = foo.spec.tt ; by default this is pulled @ACPS
 ; prefer_make_maker = 1       ; default is 0, set to 1 to use MakeMaker instead of Module::Build
 ; filter_requires = '^perl(Filter::Module)$' ; specify requires which should be filtered out.

=head1 DESCRIPTION

This builds rpms for the ACPS environment.

=head1 OPTIONS

=head2 spec_template

The TT2 template for generating the spec file.  If not specified on
that comes bundled with @ACPS is used.

=head2 prefer_make_maker

This generates a spec file which prefers MakeMaker over Moduke::Build.

=head2 filter_requires

Specify requirements to filter out.  May be specified multiple times.

=head1 AUTHOR

Graham Ollis <gollis@sesda3.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by NASA GSFC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

