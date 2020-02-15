require "csv"

class Omnifocus

  dbs = [
    ["~/Library/Group Containers", # omnifocus 3.5
     "34YW5XSRB7.com.omnigroup.OmniFocus",
     "com.omnigroup.OmniFocus3",
     "com.omnigroup.OmniFocusModel",
     "OmniFocusDatabase.db"],

    ["~/Library/Containers",       # omnifocus 3
     "com.omnigroup.OmniFocus3",
     "Data/Library",
     "Application Support",
     "OmniFocus/OmniFocus Caches",
     "OmniFocusDatabase"],

    ["~/Library/Containers",       # omnifocus 2 ... should this go?
     "com.omnigroup.OmniFocus2",
     "Data/Library/Caches",
     "com.omnigroup.OmniFocus2",
     "OmniFocusDatabase2"]
  ]

  DB = dbs
    .map  { |ary| File.expand_path ary.join "/" }
    .find { |path| File.file? path }

  # puts "DB = #{DB}"

  OFQUERY   = "sqlite3 -csv %p" % [DB]
  UNIXEPOCH = Time.utc 1970, 1, 1, 0, 0, 0
  OSXEPOCH  = Time.utc 2001, 1, 1, 0, 0, 0
  YEARZERO  = OSXEPOCH.to_i - UNIXEPOCH.to_i

  def runsql what, where, order = nil
    where = "(pi.status IS NULL OR pi.status = 'active')
      AND #{where}"

    order ||= "t.effectiveDateDue ASC, proj.name ASC, t.name ASC"

    sql = ["SELECT #{what}",
           "FROM task t",
           "LEFT JOIN task        proj ON t.parent=proj.persistentIdentifier",
           "LEFT JOIN projectinfo pi   ON t.containingprojectinfo=pi.pk",
           "WHERE #{where}",
           "ORDER BY #{order}",
          ].join " "

    cmd = %(%s "%s") % [OFQUERY, sql]

    CSV.parse `#{cmd}`
  end

  def results type, args = ARGV
    _title, what, where, order = self.send "#{type}_cmd", args

    runsql what, where, order
  end

  def run type, args = ARGV
    title, what, where, order = self.send "#{type}_cmd", args

    results = runsql what, where, order

    report title, results
  end

  def report type, results
    return if results.empty?

    puts "%s (%s)\n\n" % [type, results.size]

    old_proj = Object.new
    results.each do |(title, proj)|
      if proj != old_proj then
        old_proj = proj
        puts "* %s" % [proj] if proj
      end

      puts "  * %s" % [title]
    end
  end

  ############################################################

  def done_cmd args
    hours = (args.shift || 24).to_i

    title = "Done in Last %d Hours" % hours
    order =  "proj.name, t.datecompleted ASC"
    [title, "t.name, proj.name", done(hours), order]
  end

  def due_cmd args
    ["Overdue", "t.name, proj.name", now]
  end

  def inbox_cmd args
    ["Inbox", "t.name", inbox]
  end

  def soon_cmd args
    ["Due Soon", "t.name", soon]
  end

  def count_soon_cmd args
    [nil, "COUNT(*)", due_and_soon]
  end

  ############################################################

  def done hours
    "(#{YEARZERO} + t.dateCompleted) > #{recently(hours).to_i}"
  end

  def inbox
    incomplete "t.inInbox = 1"
  end

  def now
    incomplete "t.effectiveDateDue < #{now_t}"
  end

  def soon
    incomplete "t.effectiveDateDue >= #{now_t} and t.effectiveDateDue < #{soon_t}"
  end

  def due_and_soon
    incomplete "t.effectiveDateDue < #{soon_t}"
  end

  ############################################################

  def incomplete sql
    "t.dateCompleted IS NULL AND #{sql}"
  end

  def now_t
    Time.now - Time.new(2001, 1, 1)
  end

  def recently hours
    Time.now - (hours * 3600)
  end

  def soon_t
    now_t + 86_400
  end
end
