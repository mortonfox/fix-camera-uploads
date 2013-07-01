# fix-camera-uploads

Attempt to fix EXIF timestamps and rename photo files in Dropbox Camera Uploads folder.

## Introduction

On my LG Optimus Elite, running Android 2.3, I use primarily [Camera ZOOM FX](http://www.androidslide.com/) to take photos. For reasons unknown, this app adds the wrong EXIF timestamp (2002-12-08 12:00) to JPEG files that it saves to the SD card. Unfortunately, the Dropbox camera upload feature uses this EXIF timestamp to generate file names. So I end up with a ```Dropbox/Camera Uploads``` folder full of ```2002-12-08 12.00.00*.jpg``` files.


## What it does

* Iterate through the ```Camera Uploads``` folder, looking for JPEG files with names beginning with ```2002-```. Do the following on these files:
    * Extract the timestamp from the EXIF GPS info.
    * If EXIF GPS info is not available, use the file modification timestamp.
    * Write this timestamp to the ```create_date``` and ```date_time_original``` EXIF fields.
    * Rename the file to match this timestamp.

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
* This script does not do any file-locking so it is not safe to run multiple instances of it on the same folder at the same time.
* ExifTool is actually a Perl module, so this script would be faster if written in Perl. In Ruby, it has to run an external ```exiftool``` command on each image file. Oh well.
