TITLE
=====

pod-render.pl6

SUBTITLE
========

Program to render Perl6 Pod documentation

Render your pod documents and generate html, pdf or md output depending on the options --html, --pdf or --md. When one of the options are not used, the output files of previous runs are removed (see as if it is older documentation). The default option is --html if none of them is provided.

Synopsis
========

    pod-render.pl6 --pdf bin/pod-render.pl6

Usage
=====

pod-render.pl6 [<<var>options</var>> ...] <<var>pod-file | pod-dir</var>> ...

Arguments
---------

### pod-file

This is the file where to find the pod documentation and is rendered. A pod file is checked to have at least 5 pod render commands like `=begin ...` or `=for ...` to get rendered.

### pod-dir

Search directory and subdirectories for perl6 pod documentation looking for extensions **.pl6**, **.pm6**, **.pod6**, **.pl**, **.pm** or **.pod**.

Options
-------

### --d=dir

Normally the output is placed in the current directory or in the **./doc** directory if it exists. This option will place the output elsewhere if present. if 'dir' does not exist, it is placed in the current directory.

### --g=github-path

Generate a list of markdown references into the file **markdown-refs.md**. The format of this file will be like the following;

    [pod-render.pl6 html]: https://nbviewer.jupyter.org/github/MARTIMM/pod ...
    [pod-render.pl6 pdf]: https://nbviewer.jupyter.org/github/MARTIMM/pod- ...
    [pod-render.pl6 md]: https://github.com/MARTIMM/pod-render/blob/master ...
    ...

Where the github path is **github.com/MARTIMM/pod-render** and the pod files are found at **bin/pod-render.pl6** and **lib/Pod/Render.pm6**.

### --html

Generate output in html format. This is the default. Result is placed in the current directory or in the **./doc** directory if it exists.

### --md

Generate output in md format. Result is placed in current directory or in the **./doc** directory if it exists.

### --pdf

Generate output in pdf format. Result is placed in current directory or in the **./doc** directory if it exists. Pdf is generated using the program **prince** so that must be installed. See [downloads](https://www.princexml.com/download/).

