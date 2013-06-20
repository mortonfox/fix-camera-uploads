# fix-camera-uploads - Attempt to correct EXIF timestamps and rename photo files in Dropbox Camera Uploads folder

## Introduction

On my LG Optimus Elite, running Android 2.3, I use primarily [Camera ZOOM FX](http://www.androidslide.com/) to take photos. Unfortunately, for reasons unknown, this app adds the wrong EXIF timestamp (2002-12-08 12:00) to JPEG files that it saves to the SD card. Unfortunately, the Dropbox camera upload feature uses this EXIF timestamp to generate file names. So I end up with a ```Dropbox/Camera Uploads``` folder full of ```2002-12-08 12.00.00*.jpg``` files.

This script attempts to extract the correct timestamp from the EXIF GPS info, falling back to the file modification time if that is unavailable, and writes it to the EXIF timestamp fields. It also renames the file following the new timestamp.

## Prerequisites

In order to run the script, you need the following:
* [ExifTool](http://www.sno.phy.queensu.ca/~phil/exiftool/)
* [MiniExiftool gem](http://miniexiftool.rubyforge.org/)

## Usage

    fixcu.rb

This command will process files in the default path, which is ```$HOME/Dropbox/Camera Uploads```

    fixcu.rb path
    
This command will process files in the specified path.

## Bugs

* I'm not sure if this will interfere with the Dropbox camera upload feature or with future implementations of said feature.
* This script does not do any file-locking so it is not safe to run multiple instances of it at the same time.
* ExifTool is actually a Perl module, so this script would be faster if written in Perl because in Ruby, it has to run the ```exiftool``` command on each image file. Oh well.
