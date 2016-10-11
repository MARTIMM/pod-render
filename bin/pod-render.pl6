#!/usr/bin/env perl6

use v6.c;
use PodRender;

say "Resources: ", $%?RESOURCES.perl;

sub MAIN ( Str $pod-file, Bool :$pdf, Bool :$html, Bool :$md ) {

  my PodRender $pr .= new;
  
  $pr.render( 'html', $pod-file) if $html;
  $pr.render( 'pdf', $pod-file) if $pdf;
  $pr.render( 'md', $pod-file) if $md;
}


