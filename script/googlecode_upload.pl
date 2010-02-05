#!/usr/bin/perl

use strict;
use warnings;

our $VERSION = '0.05';
our $AUTHORITY = 'cpan:FAYLAND';

use Getopt::Long;
use Pod::Usage;
use Term::ReadKey;
use Google::Code::Upload qw/upload/;

my %params;

GetOptions(
	\%params,
	"help|?",
	"s|summary=s",
	"n|project=s",
	"u|user=s",
	"p|pass=s",
	"l|labels=s",
);

my $file = pop @ARGV;
unless ($file) { pod2usage(1); }
-e $file or die "$file is not found\n";

unless ( exists $params{n} ) {
	print "Please enter your project name: ";
	while ( $params{n} = ReadLine(0) ) {
		chomp($params{n});
		last if $params{n};
	}
}
unless ( exists $params{u} ) {
	print "Please enter your googlecode.com username: ";
	while ( $params{u} = ReadLine(0) ) {
		chomp($params{u});
		last if $params{u};
	}
}
unless ( exists $params{p} ) {
    ReadMode('noecho');
	print "** Note that this is NOT your Gmail account password! **\n",
		"It is the password you use to access Subversion repositories,\n",
		"and can be found here: http://code.google.com/hosting/settings\n",
		"your password: ";
	while ( $params{p} = ReadLine(0) ) {
		chomp($params{p});
		last if $params{p};
	}
	ReadMode 'normal';
}
unless ( exists $params{s} ) {
	print "\nPlease enter your file summary: ";
	while ( $params{s} = ReadLine(0) ) {
		chomp($params{s});
		last if $params{s};
	}
}

my @labels;
if ( exists $params{l} ) {
	@labels = split(/\,\s*/, $params{l} );
} else {
    print "Please enter your file labels (eg: 'Featured, Type-Source, OpSys-All'): ";
	while ( my $labels = ReadLine(0) ) {
		chomp($labels);
		@labels = split(/\,\s*/, $labels);
		last;
    }
}

my ( $status, $reason, $url ) = 
	upload( $file, $params{n}, $params{u}, $params{p}, $params{s}, \@labels );

if ( $url ) {
	print "The file was uploaded successfully.\nURL: $url\n";
} else {
	print "An error occurred. Your file was not uploaded.\nGoogle Code upload server said: $reason ($status)\n";
}

1;
__END__

=head1 NAME

googlecode_upload - script uploading files to a Google Code project.

=head1 SYNOPSIS

    googlecode_upload.pl [options] FILE

=head1 OPTIONS

=over 4

=item B<-?>, B<--help>

=item B<s|summary>

Short description of the file

=item B<n|project>

Google Code project name

=item B<u|user>

Your Google Code Subversion username

=item B<p|pass=s>

Your Google Code Subversion password

=item B<l|labels>

An optional list of labels to attach to the file

=back

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
