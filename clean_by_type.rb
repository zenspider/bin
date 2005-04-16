#!/usr/local/bin/ruby -w

require 'fileutils'

Dir['*'].each do |f|
  next if test ?d, f

  ext = File.extname(f)
  next if ext.empty?
  ext = ext[1..-1]
  Dir.mkdir(ext) unless test ?d, ext
  FileUtils.mv f, ext
end
