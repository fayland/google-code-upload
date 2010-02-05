use inc::Module::Install;

name     'Google-Code-Upload';
all_from 'lib/Google/Code/Upload.pm';
author   'Fayland Lam <fayland@gmail.com>';
license  'perl';

requires 'File::Spec';
requires 'File::Basename';
requires 'List::MoreUtils';
requires 'MIME::Base64';
requires 'LWP::UserAgent';
requires 'HTTP::Headers';
requires 'HTTP::Request';
requires 'Getopt::Long';
requires 'Pod::Usage';
requires 'Term::ReadKey';

#if ( $^O eq 'MSWin32' ) {
#	requires 'Win32';
#} else {
#	requires 'File::HomeDir';
#}

build_requires 'Test::More';

repository 'http://github.com/fayland/google-code-upload';

install_script glob('script/*.pl');

auto_install;

WriteAll;

