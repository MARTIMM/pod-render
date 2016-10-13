## CHANGELOG

See [semantic versioning](http://semver.org/). Please note point 4. on
that page: *Major version zero (0.y.z) is for initial development. Anything may
change at any time. The public API should not be considered stable.*

* 0.5.0
  * Documentation of pod-render.pl6 and Pod::Render
* 0.4.0
  * Store css file in resources dir
  * Add resources info to META.info
  * Define ```!get-abs-rsrc-path ( Str $rsrc --> Str )``` to calculate path to resource.
* 0.3.1 Namespace change into Pod::Render. Bugs in perl6 but cannot golf it.
* 0.3.0 Add support for MD and pdf.
* 0.2.0 Start making a program to do the rendering
* 0.1.0 Tried to 'use PodRender'. Works now but has a minor impact when not to render.
* 0.0.1 Setup
