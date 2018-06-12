#!/usr/bin/ruby -w

require 'time'

file   = ARGV.shift
format = ARGV.shift || "%Y"

mails = File.read(file).b.split(/^From /).map { |s| "From #{s}" }
mails.shift # first one is bogus because of split creating empty string

mails.each do |mail|
  h, b = mail.split(/\n\n/, 2)
  from = h.split(/\n/).first
  f, e, _ = from.split(/\s/, 3)
  h.sub!(/^date: /, 'Date: ') # lame, but necessary
  date = h.lines.grep(/^Date: /).first
  time = date ? Time.parse(date) : Time.now

  h.sub!(/^From .*/, "#{f} #{e} #{time.strftime "%c"}")

  File.open("#{file}.#{time.strftime(format)}", "a") do |io|
    io.puts h
    io.puts
    io.puts b
  end
end
