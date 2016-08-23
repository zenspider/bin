#!/usr/bin/ruby -ws

ENV["HOME"] = "/Users/ryan"
ENV["PATH"] = "#{ENV["PATH"]}:/Users/ryan/Bin"

$n ||= false

require "time"
require "date"

class Calendar
  def initialize(year, month)
    @year = year
    @month = month
    @last_day = Date.new(year, month, -1).mday
    @dow = [[],[],[],[],[],[],[]]

    (1..@last_day).each do |day|
      d = Date.new(year, month, day)
      @dow[d.wday] << d
    end
  end

  Date::DAYNAMES.each_with_index do |name, wday|
    define_method(name.downcase) { @dow[wday] }
  end
end

def run cmd
  puts "cmd: #{cmd}"
  system cmd unless $n
end

def tweet user, text
  run "t set active #{user}"
  run "t update #{text.inspect}"
end

def study
  tweet "searbsg", "Remember: Study Group Tonight! show up. talk. have coffee. vivace 6-7. https://groups.google.com/forum/#!forum/seattlerb-study"
end

def so_like desc
  "so like... we're meeting 'n stuff. you should show up. #{desc}. rawr. http://www.seattlerb.org/join-us"
end

def weekly
  tweet "seattlerb", so_like("code. talk. have coffee. vivace 7-9")
end

def monthly
  tweet "seattlerb", so_like("watch talks. not have coffee. substantial 7-9")
end

arg = ARGV.first

today = if arg
          Date.parse arg
        else
          Date.today
        end

first_tues = Calendar.new(today.year, today.month).tuesday.first

case today.wday
when 2
  study
  if today == first_tues then
    monthly
  else
    weekly
  end
else
  puts "nothing to do"
end

puts "DONE"
puts
