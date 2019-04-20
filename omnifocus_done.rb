#!/usr/bin/env ruby -w

hours = (ARGV.shift || 8).to_i

db = File.expand_path ["~/Library/Containers",
                       "com.omnigroup.OmniFocus3/Data/Library",
                       "Application Support",
                       "OmniFocus/OmniFocus Caches",
                       "OmniFocusDatabase"].join "/"

unless File.file? db
  db = File.expand_path ["~/Library/Containers",
                         "com.omnigroup.OmniFocus2/Data/Library",
                         "Caches", "com.omnigroup.OmniFocus2",
                         "OmniFocusDatabase2"].join "/"
end

OFQUERY="sqlite3 %p" % [db]

def runsql what, where
  sql = ["SELECT #{what}",
         "FROM task t LEFT JOIN task p ON t.parent=p.persistentIdentifier",
         "WHERE #{where}",
         "ORDER BY p.name, t.datecompleted ASC"
        ].join " "

  cmd = %(%s "%s") % [OFQUERY, sql]

  `#{cmd}`.chomp
end

t = Time.now
last8hours   = Time.now - (hours * 3600)
unixepoch    = Time.utc 1970, 1, 1, 0, 0, 0
osxepoch     = Time.utc 2001, 1, 1, 0, 0, 0
yearzero     = osxepoch.to_i - unixepoch.to_i
start_of_day = Time.local t.year, t.month, t.day

recently = start_of_day
recently = last8hours

done      = "(#{yearzero} + t.dateCompleted)"
matches   = "#{done} > #{recently.to_i}"

done_count = runsql "count(*)", matches
done_deets = runsql "p.name, t.name", matches

printf "Done Today (%s)\n" % done_count

old_proj = nil
done_deets.each_line do |line|
  proj, title = line.split "|", 7

  if proj != old_proj then
    old_proj = proj
    puts "\n* %s" % [proj]
  end

  puts "  * %s" % [title]
end
