#!/usr/local/bin/ruby -w

require 'fileutils'

system 'find . -name .DS_Store -exec rm {} \;'
system 'find . -maxdepth 1 -empty -type d -exec rmdir {} \;'

Dir['*'].each do |f|
  next if test ?d, f

  ext = File.extname(f)
  next if ext.empty?
  ext = ext[1..-1]
  Dir.mkdir(ext) unless test ?d, ext
  FileUtils.mv f, ext unless test ?f, File.join(ext, f)
end
