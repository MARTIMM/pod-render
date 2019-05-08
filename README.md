# Rendering of pod documents

[![Travis Build Status](https://travis-ci.org/MARTIMM/pod-render.svg?branch=master)](https://travis-ci.org/MARTIMM/pod-render) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/MARTIMM/pod-render?branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending&svg=true)](https://ci.appveyor.com/project/MARTIMM/pod-render/branch/master) [![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

## Synopsis

```
pod-render --html lib/Your/Module.pm6
```

## Documentation

The pdf output is generated with the program `prince`. You can find the downdload page [here](https://www.princexml.com/download/).

### Program and library
* [pod-render.pl6 html][pod-render.pl6 html]
* [Pod::Render html][Pod::Render html]

### Other examples of the same documents
* [pod-render.pl6 pdf][pod-render.pl6 pdf]
* [pod-render.pl6 md][pod-render.pl6 md]
* [Pod::Render pdf][Pod::Render pdf]
* [Pod::Render md][Pod::Render md]

### Release notes
* [Release notes](https://github.com/MARTIMM/pod-render/blob/master/doc/CHANGES.md)

## Installing

`zef install Pod::Render`

## Versions of PERL, MOARVM

This project is tested with latest Rakudo built on MoarVM implementing Perl v6.

## Authors

`© Marcel Timmerman (MARTIMM on github)`

## Attribution

* `Pod::To::HTML`
* Camelia™ (butterfly) is © 2009 by Larry Wall


[pod-render.pl6 html]: https://nbviewer.jupyter.org/github/MARTIMM/pod-render/blob/master/doc/pod-render.html
[pod-render.pl6 pdf]: https://nbviewer.jupyter.org/github/MARTIMM/pod-render/blob/master/doc/pod-render.pdf
[pod-render.pl6 md]: https://github.com/MARTIMM/pod-render/blob/master/doc/pod-render.md
[Pod::Render html]: https://nbviewer.jupyter.org/github/MARTIMM/pod-render/blob/master/doc/Render.html
[Pod::Render pdf]: https://nbviewer.jupyter.org/github/MARTIMM/pod-render/blob/master/doc/Render.pdf
[Pod::Render md]: https://github.com/MARTIMM/pod-render/blob/master/doc/Render.md
