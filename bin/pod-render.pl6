#!/usr/bin/env perl6

use v6.c;
use Pod::Render;

#-------------------------------------------------------------------------------
=begin pod

=TITLE pod-render.pl6

=SUBTITLE Program to render Pod documentation

=head1 Synopsis

  pod-render.pl6 --pdf bin/pod-render.pl6

=head1 Usage

  pod-render.pl6 [--pdf] [--html] [--md] <pod-file>

=head2 Arguments

=head3 --pdf

Generate output in pdf format. Result is placed in current directory or in the
C<./doc> directory if it exists. Pdf is generated using the program
B<wkhtmltopdf> so that must be installed.


=end pod
#-------------------------------------------------------------------------------

sub MAIN ( Str $pod-file, Bool :$pdf, Bool :$html, Bool :$md ) {

  my Pod::Render $pr .= new;

  $pr.render( 'html', $pod-file) if $html;
  $pr.render( 'pdf', $pod-file) if $pdf;
  $pr.render( 'md', $pod-file) if $md;
}

