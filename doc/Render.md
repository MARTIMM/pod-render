TITLE
=====

class Pod::Render

SUBTITLE
========

Render POD documents to HTML, PDF or MD

Synopsis
========

    use Pod::Render;
    my Pod::Render $pr .= new;
    $pr.render(
      'html', 'my-excellent-pod-document.pod6', 'ny-dir/my-html-result.html'
    );

Methods
=======

render
------

    multi method render ( 'html', Str:D $pod-file, Str $html-file )
    multi method render ( 'pdf', Str:D $pod-file, Str $pdf-file )
    multi method render ( 'md', Str:D $pod-file, Str $md-file )

Render the document given by `$pod-file` to one of the output formats html, pdf or markdown. To generate pdf the program `prince` is used so that program must be installed.

