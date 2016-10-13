use v6.c;
use Pod::To::HTML;
use Pod::To::Markdown;
use OpenSSL::Digest;

#-------------------------------------------------------------------------------
#unit package Pod:auth<https://github.com/MARTIMM>;

#-------------------------------------------------------------------------------
class Pod::Render:auth<https://github.com/MARTIMM> {

note "R: ", %?RESOURCES.perl;
#note "W: ", %?RESOURCES.WHAT;
#note "M: ", %?RESOURCES.^methods;
  #-----------------------------------------------------------------------------
  multi method render ( 'html', Str:D $pod-file ) {

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

    my $pod-css = 'file://' ~ self!get-abs-rsrc-path('pod6.css');

note $pod-css;

    my Str $html = '';

    # Start translation process
    my Proc $p = shell "perl6 --doc=HTML '$pod-file'", :out;

    # search for style line in the head and add a new one
    for $p.out.lines -> $line is copy {
      if $line ~~ m/^ \s* '<link' \s* 'rel="stylesheet"' \s*
                     'href="//design.perl6.org/perl.css"' \s*
                     '>' $/ {
say qq|  <link rel="stylesheet" href="$pod-css">|;
        $html ~= qq|  <link rel="stylesheet" href="$pod-css">\n|;
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

say $html;
    $html;
  }

  #-----------------------------------------------------------------------------
  method !get-abs-rsrc-path ( Str $rsrc --> Str ) {

    my Str $dist-id = %?RESOURCES.dist-id;
    my Str $repo-path = %?RESOURCES.repo;
    my Str $rsrc-path;

    if ?$dist-id {
      # in installed repo
      $repo-path ~~ s/ 'inst#' //;
      $repo-path ~= '/resources/';

      $rsrc-path = $repo-path ~
        self!file-id( "resources/$rsrc", $dist-id)>>.fmt(
          '%02x'
        ).join.uc ~ '.' ~ $rsrc.IO.extension;
    }

    else {
      # in local repo
      $repo-path ~~ s/^ 'file#' //;
      $repo-path ~~ s/ '/lib' $//;
      $rsrc-path = "$repo-path/resources/$rsrc";
    }
#say "P: $rsrc-path";

    $rsrc-path;
  }

  #-----------------------------------------------------------------------------
  # Directly from rakudo/src/core/CompUnit/Repository/Installation.pm with
  # minor changes
  method !file-id ( Str $name, Str $dist-id) {
    my $id = $name ~ $dist-id;
    sha1($id.encode);
  }
}

