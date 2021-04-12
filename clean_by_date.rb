#!/usr/bin/env ruby -ws

$t ||= false

require 'fileutils'

system 'find . -maxdepth 1 -empty -type d -exec rmdir {} \;'

format = "%Y-%m"
now = Time.now.strftime(format)

Dir['*'].each do |f|
  next if f =~ /^\d\d\d\d-\d\d$|^@/
  dir = File.mtime(f).strftime(format)
  p :skip => [f, dir] if dir == now
  next if dir == now

  Dir.mkdir(dir) unless File.exist? dir
  unless File.exist? File.join(dir, f) then
    FileUtils.mv f, dir
  else
    puts "file #{f} exists in #{dir}"
  end
end

if $t then
  Dir['*'].each do |f|
    next unless f =~ /^\d\d\d\d-\d\d$/

    Dir.chdir f do
      system "clean_by_type.rb"
    end
  end
end
