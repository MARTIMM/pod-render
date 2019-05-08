use v6;
use Pod::To::HTML;
use Pod::To::Markdown;

#-------------------------------------------------------------------------------
#unit package Pod:auth<https://github.com/MARTIMM>;

#===============================================================================
=begin pod

=TITLE class Pod::Render

=SUBTITLE Render POD documents to HTML, PDF or MD

=head1 Synopsis

  use Pod::Render;
  my Pod::Render $pr .= new;
  $pr.render( 'html', 'my-excellent-pod-document.pod6');

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
  pdf or markdown. To generate pdf the program C<prince> is used so that
  program must be installed. The style is one of the following styles;
  pod6, default, desert, doxy, sons-of-obsidian or sunburst.

  =end pod
  #-----------------------------------------------------------------------------
  multi method render ( 'html', Str:D $pod-file ) {

    my Str $html = self!html($pod-file.IO.absolute);

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

    my Str $html = self!html($pod-file.IO.absolute);
    $!involved ~= ', prince';

    my Str $html-file;
    if 'doc'.IO ~~ :d {
      $html-file = 'doc/' ~ $pod-file.IO.basename;
    }

    else {
      $html-file = $pod-file.IO.basename;
    }

    $html-file ~~ s/\. <-[.]>+ $/.html/;
    spurt( $html-file, $html);

    my Str $pdf-file = $html-file;
    $pdf-file ~~ s/\. <-[.]>+ $/.pdf/;

    # send result to pdf generator
    run 'prince', $html-file, '-o', $pdf-file;
  }

  #-----------------------------------------------------------------------------
  multi method render ( 'md', Str:D $pod-file ) {

    $!involved ~= ', Pod::To::Markdown';

    my Str $md-file;
    if 'doc'.IO ~~ :d {
      $md-file = 'doc/' ~ $pod-file.IO.basename;
    }

    else {
      $md-file = $pod-file.IO.basename;
    }

    $md-file ~~ s/\. <-[.]>+ $/.md/;

    my $cmd = run "perl6", "--doc=Markdown", $pod-file.IO.absolute, :out;
    $md-file.IO.spurt($cmd.out.slurp);
  }

  #-----------------------------------------------------------------------------
  method !html ( Str $pod-file --> Str ) {

    $!involved ~= ', Pod::To::HTML, Camelia™ (butterfly) is © 2009 by Larry Wall';

    my Str $html = '';

    # Start translation process
    my Proc $p = run "perl6", "--doc=HTML", $pod-file, :out;

    # search for style line in the head and add a new one
    my @lines = $p.out.lines;
    for @lines -> $line is copy {

      # insert styles and javascript just after meta
      if $line ~~ m:s/ '<meta' 'charset="UTF-8"' '/>' / {

        # copy meta line
        $html ~= "$line\n";

        my $pod-css = 'file://' ~ %?RESOURCES<pod6.css>;
        $html ~= qq|  <link type="text/css" rel="stylesheet" href="$pod-css">\n|;
      }

      # drop perl6 css
      elsif $line ~~ m/^ \s* '<link' \s* 'rel="stylesheet"' \s*
                    'href="//design.perl6.org/perl.css"' \s*
                    '>' $/ {
      }

      # add onload to body element
      elsif $line ~~ m:s/^ \s* '<body ' / {
        $html ~= qq| <body class="pod" onload="prettyPrint()">\n|;
      }

      # insert extra info in footer element
      elsif $line ~~ m:s/^ \s* '</body>' / {
        $html ~= "<div class=footer>Generated using $!involved\</div>";
        $html ~= "$line\n";
      }

      elsif $line ~~ m/'h1' \s+ "class='title'"/ {
        my Str $camelia = 'file://' ~ %?RESOURCES<Camelia.svg>.Str;
        $line ~~ s/'h1' \s+ "class='title'"/div class='title h1'><img src= '$camelia' align='left'/;
        $html ~= "$line\n";
      }

      else {
        $html ~= "$line\n";
      }
    }

    $html;
  }
}
