#!/usr/bin/env ruby -ws

$t ||= false

require 'fileutils'
FU = FileUtils::Verbose

FU.rm Dir["**/.DS_Store"]
FU.rm_r Dir["*"].select { |d| File.directory?(d) && Dir.children(d).empty? }

format = "%Y-%m"
now = Time.now.strftime(format)

Dir['*'].each do |f|
  next if f =~ /^\d\d\d\d-\d\d$|^@/
  dir = File.mtime(f).strftime(format)

  next if dir == now

  Dir.mkdir(dir) unless File.exist? dir
  unless File.exist? File.join(dir, f) then
    FU.mv f, dir
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
