#!/usr/bin/env ruby -w

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

soon = Time.now + 86400 - Time.new(2001, 1, 1)

cmd = ["sqlite3 %p 'select COUNT(*) from task",
       "left join projectinfo p on task.containingprojectinfo=p.pk",
       "where (folderEffectiveActive is null or folderEffectiveActive = 1)",
       'and (status is null or status = "active")',
       "and dateCompleted is null",
       "and effectiveDateDue < %d'"].join(" ") % [db, soon]

count = `#{cmd}`.to_i

puts count
