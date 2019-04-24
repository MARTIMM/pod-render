#!/usr/bin/env perl6

use v6;
use Pod::Render;

#-------------------------------------------------------------------------------
=begin pod

=TITLE pod-render.pl6

=SUBTITLE Program to render Perl6 Pod documentation

=head1 Synopsis

  pod-render.pl6 --pdf bin/pod-render.pl6

=head1 Usage

pod-render.pl6 [<R<options>> ...] <R<pod-file | pod-dir>> ...

=head2 Arguments

=head3 pod-file
=para This is the file where to find the pod documentation and is rendered. The result is placed in the current directory or, when a directory B<doc> exists, in that directory. A pod file is checked to have at least 5 pod render commands like C<=begin ...> or C<=for ...> to get rendered.

=head3 pod-dir
=para Search directory and subdirectories for perl6 pod documentation looking for extensions B<.pl6>, B<.pm6>, B<.pod6>, B<.pl>, B<.pm> or B<.pod>.

=head2 Options

=head3 --g=github-path

Generate a list of markdown references into the file B<markdown-refs.md>. The format of this file will be like the following;

  [pod-render.pl6]: https://htmlpreview.github.io/?https://github.com/MARTIMM/pod-render/blob/master/doc/pod-render.html
  [Render.pm6]: https://htmlpreview.github.io/?https://github.com/MARTIMM/pod-render/blob/master/doc/Render.html

Where the github path is B<github.com/MARTIMM/pod-render> and the pod files are found at B<bin/pod-render.pl6> and B<lib/Pod/Render.pm6>.

=head3 --html

Generate output in html format. This is the default. Result is placed in the current directory or in the B<./doc> directory if it exists.

=head3 --md

Generate output in md format. Result is placed in current directory or in the B<./doc> directory if it exists.

=head3 --pdf

Generate output in pdf format. Result is placed in current directory or in the B<./doc> directory if it exists. Pdf is generated using the program B<wkhtmltopdf> so that must be installed.

=head3 --style=some-prettify-style

This program uses the Google prettify javascript and stylesheets to render the code. The styles are C<default>, C<desert>, C<doxy>, C<sons-of-obsidian> and C<sunburst>. By default the progam uses, well you guessed it, 'default'. This option is only useful with C<--html> and C<--pdf>. There is another style which is just plain and simple and not used with the google prettifier. This one is selected using C<pod6>.

=end pod
#-------------------------------------------------------------------------------
my Str $md-refs = '';
my Str $pv = 'https://htmlpreview.github.io/?';

sub MAIN (
  *@pod-files, Str :$style = 'default', Str :$g,
  Bool :$pdf = False, Bool :$html = False, Bool :$md = False
) {

  for @pod-files -> $pod {
    recurse-dir( $pod, :$g, :$style, :$pdf, :$html, :$md);
  }

  'markdown-refs.md'.IO.spurt($md-refs) if ?$g and $md-refs;
}

#-------------------------------------------------------------------------------
sub recurse-dir (
  Str:D $pod, Str :$style, Str :$g, Bool :$pdf, Bool :$html is copy, Bool :$md
) {

  if $pod.IO.d {
    for dir($pod) -> $pf {

      # scan sub dirs and pod files. rest is ignored
      recurse-dir( $pf.Str, :$g, :$style, :$pdf, :$html, :$md)
        if $pf.IO.d or $pf.IO.extension ~~ m/^ [ pm || pl || pod ] 6? $/;
    }
  }

  else {
    return unless check-pod($pod);
    $html = True if ?$g or !($pdf or $md);

    note "Render pod in $pod";
    render-pod( $pod, :$style, :$pdf, :$html, :$md);

    if ?$g {
      my Str $pod-ref;

      my Str $pod-bn = $pod.IO.basename;
      $pod-bn ~~ s/ \. <-[.]>* $//;
      if $pod.IO.extension ~~ / pm 6?/ {
        $pod-ref = $pod;
        $pod-ref ~~ s/ \. <-[.]>* $//;
        $pod-ref ~~ s/ lib '/' //;
        $pod-ref ~~ s/ \/ /::/;
      }

      else {
        $pod-ref = $pod.IO.basename;
      }

      if $html {
        $md-refs ~= [~] '[', $pod-ref, ' html]: ', $pv, 'https://', $g,
                    '/blob/master', 'doc'.IO.d ?? '/doc/' !! '/',
                    $pod-bn, ".html\n";
      }

      if $pdf {
        $md-refs ~= [~] '[', $pod-ref, ' pdf]: ', 'https://', $g,
                    '/blob/master', 'doc'.IO.d ?? '/doc/' !! '/',
                    $pod-bn, ".pdf\n";
      }

      if $md {
        $md-refs ~= [~] '[', $pod-ref, ' md]: ', 'https://', $g,
                    '/blob/master', 'doc'.IO.d ?? '/doc/' !! '/',
                    $pod-bn, ".md\n";
      }
    }
  }
}

#-------------------------------------------------------------------------------
sub render-pod (
  Str:D $pod, Str :$style, Bool :$pdf, Bool :$html, Bool :$md
) {

  my Pod::Render $pr .= new;
  $pr.render( 'html', $pod, :$style) if $html;
  $pr.render( 'pdf', $pod, :$style) if $pdf;
  $pr.render( 'md', $pod) if $md;

  # Default is html
  #$pr.render( 'html', $pod, :$style) unless $html or $pdf or $md;
}

#-------------------------------------------------------------------------------
sub USAGE ( ) {

  my Int $skip = 0;

  my Proc $p = run "perl6", "--doc=Text", $*PROGRAM-NAME, :out;
  my @lines = $p.out.lines;
  $p.out.close;

  for @lines -> $line is copy {

    $skip = 2 if $line ~~ m/^ TITLE /;
    $skip = 1 if $line ~~ m/^ SUBTITLE /;
    $skip = 3 if $line ~~ m/^ Synopsis /;
    if $skip {
      $skip -= 1;
    }

    else {
      note $line if not $skip;
    }
  }

  print "\n";
}

#-------------------------------------------------------------------------------
sub check-pod ( Str $pod-file --> Bool ) {

  my Int $count = 0;
  for $pod-file.IO.slurp.lines -> $line {
    $count++ if ?(
      $line ~~ m/ '=' [
         NAME || VERSION || AUTHOR || TITLE || SUBTITLE ||
         begin || end || head \d || for || item \d* || defn || coment
      ] /
    );

    # enaugh prove after 5 hits
    last if $count > 5;
  }

  # only true above 5 hits. it could be literal strings you know!
  return $count > 5;
}
