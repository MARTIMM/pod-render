use v6.c;
use Pod::To::HTML;
use Pod::To::Markdown;

class PodRender:auth<https://github.com/MARTIMM> {

  #-----------------------------------------------------------------------------
  multi method render ( 'html', Str:D $pod-file ) {

    my Str $html = self!html($pod-file.IO.abspath);

    my Str $html-file = 'doc/' ~ $pod-file.IO.basename;
    $html-file ~~ s/\. <-[.]>+ $/.html/;
    spurt( $html-file, $html);
  }

  #-----------------------------------------------------------------------------
  multi method render ( 'pdf', Str:D $pod-file ) {

    my Str $html = self!html($pod-file.IO.abspath);

    my Str $pdf-file = 'doc/' ~ $pod-file.IO.basename;
    $pdf-file ~~ s/\. <-[.]>+ $/.pdf/;

    # send result to pdf generator
    my Proc $p = shell "wkhtmltopdf - '$pdf-file' &>wkhtml2pdf.log", :in;
    $p.in.print($html);
  }

  #-----------------------------------------------------------------------------
  multi method render ( 'md', Str:D $pod-file ) {

    my Str $md-file = 'doc/' ~ $pod-file.IO.basename;
    $md-file ~~ s/\. <-[.]>+ $/.md/;

    shell "perl6 --doc=Markdown " ~ $pod-file.IO.abspath ~ " > $md-file";
  }

  #-----------------------------------------------------------------------------
  method !html ( Str $pod-file --> Str ) {

    my Str $pod-css = 'doc/pod6.css'.IO.abspath;
    my Str $html = '';

    # Start translation process
    my Proc $p = shell "perl6 --doc=HTML '$pod-file'", :out;

    # search for style line in the head and add a new one
    for $p.out.lines -> $line is copy {
      if $line ~~ m/^ \s* '<link' \s* 'rel="stylesheet"' \s*
                     'href="//design.perl6.org/perl.css"' \s*
                     '>' $/ {
        $html ~= qq|  <link rel="stylesheet" href="file://$pod-css">\n|;
#        $html ~= $line ~ "\n";
      }

      # wkhtmltopdf bug or misplaced by Pod::To::HTML? replace id on body to h1
      # of title
      elsif $line ~~ m/^ \s* '<body' \s* 'class="pod"' / {
        $line ~~ s/'id="___top"'//;
        $html ~= $line ~ "\n";
      }

      elsif $line ~~ m/^ \s* '<h1' \s* "class='title'" / {
        $line ~~ s/'<h1' \s* /<h1 id="___top" /;
        $html ~= $line ~ "\n";
        last;
      }

      else {
        $html ~= $line ~ "\n";
      }
    }

    # copy rest of it
    for $p.out.lines -> $line { $html ~= $line ~ "\n"; }

    $html;
  }
}

