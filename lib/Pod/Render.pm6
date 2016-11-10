use v6.c;
use Pod::To::HTML;
use Pod::To::Markdown;

#-------------------------------------------------------------------------------
#unit package Pod:auth<https://github.com/MARTIMM>;

#===============================================================================
=begin pod

=TITLE class Pod::Render

=SUBTITLE Render POD documents to HTML, PDF or MD

  class Pod::Render { ... }

=head1 Synopsis

  use Pod::Render;
  my Pod::Render $pr .= new;
  $pr.render( 'html', 'my-excelent-pod-document.pod6');

=end pod
#-------------------------------------------------------------------------------
class Pod::Render:auth<https://github.com/MARTIMM> {

  has Str $!involved = 'Pod::Render';

  #=============================================================================
  =begin pod
  =head1 Methods
  
  =head2 render

    multi method render ( 'html', Str:D $pod-file )
    multi method render ( 'pdf', Str:D $pod-file )
    multi method render ( 'md', Str:D $pod-file )

  Render the document given by C<$pod-file> to one of the output formats html,
  pdf or markdown. To generate pdf the program C<wkhtmltopdf> is used so that
  program must be installed.

  =end pod
  #-----------------------------------------------------------------------------
  multi method render ( 'html', Str:D $pod-file ) {

    $!involved ~= ', Pod::To::HTML';
    my Str $html = self!html($pod-file.IO.abspath);

    my Str $html-file;
    if 'doc'.IO ~~ :d {
      $html-file = 'doc/' ~ $pod-file.IO.basename;
    }

    else {
      $html-file = $pod-file.IO.basename;
    }

    $html-file ~~ s/\. <-[.]>+ $/.html/;
    spurt( $html-file, $html);
  }

  #-----------------------------------------------------------------------------
  multi method render ( 'pdf', Str:D $pod-file ) {

    $!involved ~= ', Pod::To::HTML, wkhtmltopdf';
    my Str $html = self!html($pod-file.IO.abspath);

    my Str $pdf-file;
    if 'doc'.IO ~~ :d {
      $pdf-file = 'doc/' ~ $pod-file.IO.basename;
    }

    else {
      $pdf-file = $pod-file.IO.basename;
    }

    $pdf-file ~~ s/\. <-[.]>+ $/.pdf/;

    # send result to pdf generator
    my Proc $p = shell "wkhtmltopdf - '$pdf-file' &>wkhtml2pdf.log", :in;
#    my Proc $p = shell "wkhtmltopdf - '$pdf-file'", :in, :out;
    $p.in.print($html);

#    my Promise $pout .= start( {
#        for $p.err.lines {
#          "Err: ", .say;
#        }
#      }
#    );
  }

  #-----------------------------------------------------------------------------
  multi method render ( 'md', Str:D $pod-file ) {

    my Str $md-file;
    if 'doc'.IO ~~ :d {
      $md-file = 'doc/' ~ $pod-file.IO.basename;
    }

    else {
      $md-file = $pod-file.IO.basename;
    }

    $md-file ~~ s/\. <-[.]>+ $/.md/;

    shell "perl6 --doc=Markdown " ~ $pod-file.IO.abspath ~ " > $md-file";
  }

  #-----------------------------------------------------------------------------
  method !html ( Str $pod-file --> Str ) {


    my $pod-css = 'file://' ~ %?RESOURCES<pod6.css>;

    my Str $html = '';

    # Start translation process
    my Proc $p = shell "perl6 --doc=HTML '$pod-file'", :out;

    # search for style line in the head and add a new one
    for $p.out.lines -> $line is copy {
      if $line ~~ m/^ \s* '<link' \s* 'rel="stylesheet"' \s*
                     'href="//design.perl6.org/perl.css"' \s*
                     '>' $/ {
        $html ~= qq|  <link rel="stylesheet" href="$pod-css">\n|;
#        $html ~= $line ~ "\n";
      }

      elsif $line ~~ m/^ \s* '</body>' / {
        $html ~= "<div class=footer>Generated using $!involved\</div>";
        $html ~= $line;
      }

      else {
        $html ~= $line ~ "\n";
      }
    }

    $html;
  }
}

