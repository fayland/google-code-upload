package Google::Code::Upload;

use warnings;
use strict;
use File::Spec ();
use File::Basename ();
use List::MoreUtils qw/natatime/;
use MIME::Base64;
use LWP::UserAgent;
use HTTP::Headers;
use HTTP::Request;

use base 'Exporter';
use vars qw/@EXPORT_OK/;
@EXPORT_OK = qw/ upload /;

our $VERSION = '0.05';
our $AUTHORITY = 'cpan:FAYLAND';

sub upload {
    my ( $file, $project_name, $username, $password, $summary, $labels ) = @_;
    
    $labels ||= [];
    if ( $username =~ /^(.*?)\@gmail\.com$/ ) {
        $username = $1;
    }

    my @form_fields = (
        summary => $summary,
    );
    push @form_fields, ( label => $_ ) foreach (@$labels);
    
    my ( $content_type, $body ) = encode_upload_request(\@form_fields, $file);
    
    my $upload_uri  = "https://$project_name.googlecode.com/files";
    my $auth_token  = encode_base64("$username:$password", '');

    my $header = HTTP::Headers->new;
    $header->header('Authorization' => "Basic $auth_token");
    $header->header('User-Agent' => 'Googlecode.com uploader v0.9.4');
    $header->header('Content-Type' => $content_type);
  
    my $ua = LWP::UserAgent->new(
        agent => 'Googlecode.com uploader v0.9.4',
    );
    my $request = HTTP::Request->new(POST =>$upload_uri, $header, $body);
    my $response = $ua->request($request);

    if ($response->code == 201) {
        return ( $response->code, $response->status_line, $response->header('Location') );
    } else {
        return ( $response->code, $response->status_line, undef );
    }
}

sub encode_upload_request {
    my ($form_fields, $file) = @_;
    
    my $BOUNDARY = '----------Googlecode_boundary_reindeer_flotilla';
    my $CRLF = "\r\n";

    my @body;
    
    my $it = natatime 2, @$form_fields;
    while (my ( $key, $val ) = $it->()) {
        push @body, (
            "--$BOUNDARY",
            qq~Content-Disposition: form-data; name="$key"~,
            '',
            $val
        );
    }
    
    my $filename = File::Basename::basename($file);
    open(my $fh, '<', $file) or die $!;
    binmode($fh);
    my $content = do {
        local $/;
        <$fh>;
    };
    close($fh);
    
    push @body, (
        "--$BOUNDARY",
        qq~Content-Disposition: form-data; name="filename"; filename="$filename"~,
        # The upload server determines the mime-type, no need to set it.
        'Content-Type: application/octet-stream',
        '',
        $content,
    );

    # Finalize the form body
    push @body, ("--$BOUNDARY--", '');

    return ("multipart/form-data; boundary=$BOUNDARY", join( $CRLF, @body ) );
}

1;
__END__

=head1 NAME

Google::Code::Upload - uploading files to a Google Code project.

=head1 SYNOPSIS

    use Google::Code::Upload qw/upload/;

    upload( $file, $project_name, $username, $password, $summary, $labels );

=head1 DESCRIPTION

It's an incomplete Perl port of L<http://support.googlecode.com/svn/trunk/scripts/googlecode_upload.py>

basically you need L<googlecode_upload> script instead.

=head1 METHODS

=head2 upload

    upload( $file, $project_name, $username, $password, $summary, $labels );

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
