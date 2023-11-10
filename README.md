<p align="center">
  <img alt="MacPacker Logo" src="https://raw.githubusercontent.com/SarensX/MacPacker/c55540e27fe8d9e419651b7e917b4e09ce238c52/MacPacker/Assets.xcassets/Logo.imageset/icon_128x128.png">
</p>

## Why?

- Because essential tools should be free
- Because open source creates a community for long-time maintenance
- Because extracting the full archive to get just one file doesn't make sense

## What is MacPacker?

A free, open-source, tool to work with archives. Currently, it supports navigating and extracting files from an archive only. Creating or editing archives will follow. Inspired by 7-Zip, but without any claim to comparability. See the roadmap for more details.

## Roadmap

### Backlog
- Support decompression of formats: Deflate, LZMA2, LZMA, BZip2
- Support archives: ZLib, GZip, 7zip, XZ, RAR
- Right click context menu in Finder to immediately extract the archive to a sub folder or without
- Create/edit archive

### v0.3
- feat: highlight when dragging file to MacPacker window
- feat: double click any file opens it using the default system app
- feat: breadcrumb showing the current path in the archive
- feat: support for any valid zip-based file
- feat: automatic cache cleaning

### v0.2
- feat: welcome & about dialog
- feat: auto update
- feat: zip support
- feat: "Open With..." context menu support

### v0.1
- feat: Drag & drop an lz4 or tar file to MacPacker
- feat: Manual option to clear the cache
- feat: Traverse through nested archives
