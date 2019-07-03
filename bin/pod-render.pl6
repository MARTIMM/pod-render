#!/usr/bin/env perl6

use v6;
use Pod::Render;

#-------------------------------------------------------------------------------
=begin pod

=TITLE pod-render.pl6

=SUBTITLE Program to render Perl6 Pod documentation

Render your pod documents and generate html, pdf or md output depending on the options --html, --pdf or --md. When one of the options are not used, the output files of previous runs are removed (see as if it is older documentation). The default option is --html if none of them is provided.

=head1 Synopsis

  pod-render.pl6 --pdf bin/pod-render.pl6

=head1 Usage

pod-render.pl6 [<R<options>> ...] <R<pod-file | pod-dir>> ...

=head2 Arguments

=head3 pod-file
=para This is the file where to find the pod documentation and is rendered. A pod file is checked to have at least 5 pod render commands like C<=begin ...> or C<=for ...> to get rendered.

=head3 pod-dir
=para Search directory and subdirectories for perl6 pod documentation looking for extensions B<.pl6>, B<.pm6>, B<.pod6>, B<.pl>, B<.pm> or B<.pod>.

=head2 Options

=head3 --d=dir

Normally the output is placed in the current directory or in the B<./doc> directory if it exists. This option will place the output elsewhere if present. if 'dir' does not exist, it is placed in the current directory.

=head3 --g=github-path

Generate a list of markdown references into the file B<markdown-refs.md>. The format of this file will be like the following;

  [pod-render.pl6 html]: https://nbviewer.jupyter.org/github/MARTIMM/pod ...
  [pod-render.pl6 pdf]: https://nbviewer.jupyter.org/github/MARTIMM/pod- ...
  [pod-render.pl6 md]: https://github.com/MARTIMM/pod-render/blob/master ...
  ...

Where the github path is B<github.com/MARTIMM/pod-render> and the pod files are found at B<bin/pod-render.pl6> and B<lib/Pod/Render.pm6>.

=head3 --html

Generate output in html format. This is the default. Result is placed in the current directory or in the B<./doc> directory if it exists.

=head3 --md

Generate output in md format. Result is placed in current directory or in the B<./doc> directory if it exists.

=head3 --pdf

Generate output in pdf format. Result is placed in current directory or in the B<./doc> directory if it exists. Pdf is generated using the program B<prince> so that must be installed. See L<downloads|https://www.princexml.com/download/>.

=end pod
#-------------------------------------------------------------------------------
my Str $md-refs = '';
#my Str $pv = 'https://htmlpreview.github.io/?';
my Str $pv = 'https://nbviewer.jupyter.org/github/';
my Str $out-dir = '.';

sub MAIN (
  *@pod-files, Str :$g, Str :$d,
  Bool :$pdf = False, Bool :$html = False, Bool :$md = False
) {

  $out-dir = (($d // '/non-existend-dir').IO.d ?? $d !! Any) //
             ('doc'.IO.d ?? 'doc' !! '.');
  $out-dir ~= '/';

  for @pod-files -> $pod {
    recurse-dir( $pod, :$g, :$pdf, :$html, :$md);
  }

  'markdown-refs.md'.IO.spurt($md-refs) if ?$g and $md-refs;
}

#-------------------------------------------------------------------------------
sub recurse-dir (
  Str:D $pod, Str :$g, Bool :$pdf, Bool :$html is copy, Bool :$md
) {

  # check if name is a dir. if so, recursivly through dir content
  if $pod.IO.d {
    for dir($pod).sort -> $pf {

      # scan sub dirs and pod files. rest is ignored
      recurse-dir( $pf.Str, :$g, :$pdf, :$html, :$md)
        if $pf.IO.d or $pf.IO.extension ~~ m/^ [ pm || pl || pod ] 6? $/;
    }
  }

  else {
    return unless check-pod($pod);
    #$html = True if ?$g or !($pdf or $md);

    note "Render pod in $pod";
    render-pod( $pod, :$pdf, :$html, :$md);

    if ?$g {
      my Str $pod-ref;

      my Str $pod-bn = $pod.IO.basename;
      $pod-bn ~~ s/ \. <-[.]>* $//;
      if $pod.IO.extension ~~ / pm 6?/ {
        $pod-ref = $pod;
        $pod-ref ~~ s/ \. <-[.]>* $//;
        $pod-ref ~~ s/ lib '/' //;
        $pod-ref ~~ s:g/ \/ /::/;
      }

      else {
        $pod-ref = $pod.IO.basename;
      }

      # write out entries
      if $html {
        $md-refs ~= [~] '[', $pod-ref, ' html]: ', $pv, $g,
                    '/blob/master', 'doc'.IO.d ?? '/doc/' !! '/',
                    $pod-bn, ".html\n";
      }

      if $pdf {
        $md-refs ~= [~] '[', $pod-ref, ' pdf]: ', $pv, $g,
                    '/blob/master', 'doc'.IO.d ?? '/doc/' !! '/',
                    $pod-bn, ".pdf\n";
      }

      if $md {
        $md-refs ~= [~] '[', $pod-ref, ' md]: ', 'https://github.com/', $g,
                    '/blob/master', 'doc'.IO.d ?? '/doc/' !! '/',
                    $pod-bn, ".md\n";
      }
    }
  }
}

#-------------------------------------------------------------------------------
sub render-pod ( Str:D $pod-file, Bool :$pdf, Bool :$html is copy, Bool :$md ) {

  my Pod::Render $pr .= new;

  my Str $html-file = $out-dir ~ $pod-file.IO.basename;
  $html-file ~~ s/\. <-[.]>+ $/.html/;

  my Str $pdf-file = $html-file;
  $pdf-file ~~ s/\. <-[.]>+ $/.pdf/;

  my Str $md-file = $html-file;
  $md-file ~~ s/\. <-[.]>+ $/.md/;

  # Default is html
  $html = True unless $html or $pdf or $md;

  $pr.render( 'pdf', $pod-file, $pdf-file) if $pdf;
  $pr.render( 'html', $pod-file, $html-file) if $html;
  $pr.render( 'md', $pod-file, $md-file) if $md;

  # remove previously generated output if is not selected in this run
  unlink $html-file unless $html;
  unlink $md-file unless $md;
  unlink $pdf-file unless $pdf;
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
