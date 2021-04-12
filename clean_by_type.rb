#!/usr/bin/env ruby -w

require "pp"
require "fileutils"

system 'find . -name .DS_Store -exec rm {} \;'
system 'find . -maxdepth 1 -empty -type d -exec rmdir {} \;'

files = Hash.new { |h, k| h[k] = [] }

Dir["*"].each do |f|
  if File.file? f then
    ext = File.extname(f).delete_prefix "."

    if ext.empty? then
      warn "# skipping file      #{f}"
      next
    end

    files[ext] << f
  elsif File.directory? f then
    d = f

    unless d =~ /^[a-z]+$/ then
      warn "# skipping directory #{d}"
      next
    end

    underfiles = Dir["#{d}/*.#{d}"]

    files[d].concat underfiles
  else
    warn "# unprocessed: #{f}"
  end
end

fileutils = FileUtils::Verbose

files.each do |ext, paths|
  # only one entry in subdir = unpack
  # only one entry at top    = leave alone
  # otherwise                = make directory, move all files into subdirectory

  if paths.size == 1 then
    path = paths.first
    if path =~ %r%/% then
      warn "# unpacking #{path}"
      fileutils.mv path, "."
      fileutils.rmdir ext
    end
  else
    move = paths.grep_v %r%/%

    unless move.empty? then
      warn "# organizing #{ext}"

      fileutils.mkdir ext unless File.directory? ext

      fileutils.mv move, ext
    end
  end
end
