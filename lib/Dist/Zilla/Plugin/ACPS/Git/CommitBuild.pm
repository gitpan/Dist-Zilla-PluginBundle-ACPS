#
# This file is part of Dist-Zilla-Plugin-Git
#
# This software is copyright (c) 2009 by Jerome Quelin.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use 5.008;
use strict;
use warnings;

package Dist::Zilla::Plugin::ACPS::Git::CommitBuild;
our $VERSION = '0.25'; # VERSION
# ABSTRACT: checkin build results on separate branch

use Git::Wrapper 0.021;
use IPC::Open3;
use IPC::System::Simple; # required for Fatalised/autodying system
use File::chdir;
use File::Spec::Functions qw/ rel2abs catfile /;
use File::Temp;
use Moose;
use namespace::autoclean;
use MooseX::AttributeShortcuts;
use Path::Class;
use MooseX::Types::Path::Class ':all';
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw{ Str };
use Cwd qw(abs_path);
use Try::Tiny;

use String::Formatter (
	method_stringf => {
		-as   => '_format_branch',
		codes => {
			b => sub { (shift->name_rev( '--name-only', 'HEAD' ))[0] },
		},
	},
	method_stringf => {
		-as   => '_format_message',
		codes => {
			b => sub { (shift->_git->name_rev( '--name-only', 'HEAD' ))[0] },
			h => sub { (shift->_git->rev_parse( '--short',    'HEAD' ))[0] },
			H => sub { (shift->_git->rev_parse('HEAD'))[0] },
		    t => sub { shift->zilla->is_trial ? '-TRIAL' : '' },
		    v => sub { shift->zilla->version },
		}
	}
);

# debugging...
#use Smart::Comments '###';

with 'Dist::Zilla::Role::Releaser';
with 'Dist::Zilla::Role::Git::Repo';

# -- attributes

has release_branch  => ( ro, isa => Str, default => 'release', required => 1 );
has release_message => ( ro, isa => Str, default => 'build release %v', required => 1 );
has build_root => ( rw, coerce => 1, isa => Dir );
has _git => (rw, weak_ref => 1);

# -- role implementation

sub release {
    my ( $self, $args) = @_;

    $self->_commit_build( $args, $self->release_branch, $self->release_message );
}

sub _commit_build {
    my ( $self, undef, $branch, $message ) = @_;

    return unless $branch;

    my $tmp_dir = File::Temp->newdir( CLEANUP => 1) ;
    my $src     = Git::Wrapper->new( $self->repo_root );
    $self->_git($src);

    my $target_branch = _format_branch( $branch, $src );
    #my $dir           = $self->build_root;
    my $dir           = dir($self->zilla->root, $self->zilla->name . '-' . $self->zilla->version);

    # returns the sha1 of the created tree object
    my $tree = $self->_create_tree($src, $dir);

    my ($last_build_tree) = try { $src->rev_parse("$target_branch^{tree}") };
    $last_build_tree ||= 'none';

    ### $last_build_tree
    if ($tree eq $last_build_tree) {

        $self->log("No changes since the last build; not committing");
        return;
    }

    my @parents = grep {
        eval { $src->rev_parse({ 'q' => 1, 'verify'=>1}, $_ ) }
    } $target_branch;

    ### @parents

    my $this_message = _format_message( $message, $self );
    my @commit = $src->commit_tree( { -STDIN => $this_message }, $tree, map { ( '-p' => $_) } @parents );

    ### @commit
    $src->update_ref( 'refs/heads/' . $target_branch, $commit[0] );
}

sub _create_tree {
    my ($self, $repo, $fs_obj) = @_;

    ### called with: "$fs_obj"
    if (!$fs_obj->is_dir) {

        my ($sha) = $repo->hash_object({ w => 1 }, "$fs_obj");
        ### hashed: "$sha $fs_obj"
        return $sha;
    }

    my @entries;
    for my $obj ($fs_obj->children) {

        ### working on: "$obj"
        my $sha  = $self->_create_tree($repo, $obj);
        my $mode = sprintf('%o', $obj->stat->mode); # $obj->is_dir ? '040000' : '
        my $type = $obj->is_dir ? 'tree' : 'blob';
        my $name = $obj->basename;

        push @entries, "$mode $type $sha\t$name";
    }

    ### @entries

    my ($sha) = $repo->mktree({ -STDIN => join("\n", @entries, q{}) });

    return $sha;
}

1;


__END__
=pod

=head1 NAME

Dist::Zilla::Plugin::ACPS::Git::CommitBuild - checkin build results on separate branch

=head1 VERSION

version 0.25

=head1 SYNOPSIS

In your F<dist.ini>:

    [ACPS::Git::CommitBuild]
       ; these are the defaults
    release = release/%b
    release_message = 'build release %v'

=head1 DESCRIPTION

Forked from [Git::CommitBuild] to do the action during release, not 
after.  Only operates on release, not on build.

=head1 AUTHOR

Graham Ollis <gollis@sesda3.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by NASA GSFC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

