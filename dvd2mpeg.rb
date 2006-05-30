#!/usr/local/bin/ruby -ws

path = ARGV.shift or raise "need a VIDEO_TS directory to process"
root = File.dirname path
queue = Hash.new { |h,k| h[k] = [] }
title = -1

IO.popen("HBTest -t 0 -i #{path} 2>&1") do |io|
  io.each_line do |line|
    puts line if defined? $n
    if line =~ /^\+ title (\d+)/ then
      title = $1.to_i
    end

    if line =~ /^    \+ (\d+):/ then
      queue[title] << $1.to_i
    end
  end
end

p queue

queue.keys.sort.each do |t|
  queue[t].sort.each do |c|
    c2 = "%02d" % c
    output = File.join(root, "t#{t}c#{c2}.mp4")
    unless test ?f, output then
      cmd = %W(HBTest -2 -d -t #{t} -c #{c} -i #{path} -o #{output})
      unless defined? $n then
        puts "Processing title #{t} chapter #{c}:"
        unless system(*cmd) then
          exit 2
        end
      else
        puts cmd.join(' ')
      end
    end
  end
end
