## CHANGELOG

See [semantic versioning](http://semver.org/). Please note point 4. on
that page: *Major version zero (0.y.z) is for initial development. Anything may
change at any time. The public API should not be considered stable.*

* 2019-04-24 0.7.6
  * Changed html to pdf converter to use `prince`.
  * Removed google prettify and with that the `--style` option to `pod-render.pl6`
  * Dropped the inline style too and moved to `pod6.css`.
* 2019-04-24 0.7.5
  * Bugfixes
* 2019-04-23 0.7.4
  * The program `pod-render.pl6` can process multiple files. Also it will descend directories recursively when a directory is provided in the argument list.
  * Program usage is shown using a filtered version of `perl6 --doc=Text` of the programs pod information.
  * Generate a list of markdown references when using `--g`. This can be used in e.g. `README.md`.
  * Added doc references in `README.md`.
* 2019-04-18 0.7.3
  * The file Camelia.svg is stored in resources now and used from there instead of referencing it to the website where it is shown.
* 0.7.2
  * Samantha McVey found an error in the redirection to the external program for generating PDF files. Thanks Samantha!
  * Generating the PDF finishes now before the program finishes. This will let the command prompt be shown properly after that.
* 0.7.1 Operation Zoffix Znet to modify abspath() into absolute(), Thanks Zoffix!
* 0.7.0
  * option --style added to pod-render.pl6. Html and pdf rendering is using this option to control google prettify styles
* 0.6.1
  * Bugfix in Meta config
* 0.6.0
  * Added Google code highlighting and prettifying.
* 0.5.7
  * Changes caused by bugfix in Pod::To::HTML. This module does not have to repair it anymore.
  * Change in css for C<data>. Tiny bit larger font.
* 0.5.6
  * Changes in css to render tables nicer
* 0.5.5
  * Added appveyor tests to test on windows platform
* 0.5.4
  * Minor css changes
* 0.5.3
  * C<something> colored to separate it better in the surrounding text.
* 0.5.2
  * Extended honouration on the bottom line to other programs and modules on the bottom line when
  generating html or pdf
* 0.5.1
  * get-abs-rsrc-path is not needed because %?RESOURCES<pod6.css> does it! Might need a few words on the perl6 doc site!
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
