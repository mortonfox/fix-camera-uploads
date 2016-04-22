#!/usr/bin/env ruby
# Attempt to correct EXIF timestamps and rename photo files in Dropbox Camera Uploads folder.

require 'mini_exiftool'
require 'time'
require 'fileutils'
require 'getoptlong'

def find_unique newname, newsuffix
  newfilename = "#{newname}#{newsuffix}"
  return newfilename unless File.exist? newfilename

  # Look for a non-conflicting file name.
  1.upto(1000) { |i|
    newfilename = "#{newname}-#{i}#{newsuffix}"
    return newfilename unless File.exist? newfilename
  }

  raise "Can't find non-conflicting file name for #{newname}-???#{newsuffix}"
end

def rename_file oldname, newname, newsuffix
  File.rename oldname, find_unique(newname, newsuffix)
end

# Don't modify any timestamps above this time. Those are assumed to be
# already valid.
TIME_LOWER_BOUND = Time.local 2010

default_path = File.join Dir.home, 'Dropbox', 'Camera Uploads'

USAGE = <<-EOM.freeze
Usage: #{$PROGRAM_NAME} [OPTIONS] [path]

-h, --help:
    Show help.

path:
    Folder in which to process image files.
    Default: #{default_path}
EOM

begin
  opts = GetoptLong.new(
    ['--help', '-h', GetoptLong::NO_ARGUMENT]
  )

  opts.each { |opt, _arg|
    case opt
    when '--help'
      puts USAGE
      exit
    end
  }
rescue => err
  puts USAGE
  exit 1
end

path = ARGV[0] || default_path
unless Dir.exist? path
  warn "Path '#{path}' is not a folder or does not exist."
  exit 1
end

puts "Using path #{path}..."
Dir.chdir path

Dir.glob('2002-*.jpg') { |fname|
  begin
    photo = MiniExiftool.new fname

    puts "File: #{fname}"

    new_time = nil
    t = photo.gps_date_time
    if t && t > TIME_LOWER_BOUND
      t = t.localtime
      puts "Using GPS time #{t}..."
      new_time = t
    else
      t = photo.file_modify_date
      if t && t > TIME_LOWER_BOUND
        puts "Using file modify time #{t}..."
        new_time = t
      end
    end

    puts "Can't get a proper time for this file." unless new_time

    t = photo.create_date
    if t && t > TIME_LOWER_BOUND
      puts "Not changing create_date #{t}."
    else
      photo.create_date = new_time
    end

    t = photo.date_time_original
    if t && t > TIME_LOWER_BOUND
      puts "Not changing date_time_original #{t}."
    else
      photo.date_time_original = new_time
    end

    if photo.changed?
      puts 'Saving EXIF changes...'
      photo.save
      FileUtils.touch fname, mtime: new_time
    end

    newname = new_time.strftime '%Y-%m-%d %H-%M-%S'
    puts "Renaming file to #{newname}.jpg"
    rename_file fname, newname, '.jpg'
  rescue => err
    warn "Error processing file #{fname}: #{err}"
  end
}
