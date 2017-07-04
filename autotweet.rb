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

def study_group desc
  "Remember: Study Group Tonight! show up. learn. #{desc}. https://groups.google.com/forum/#!forum/seattlerb-study"
end

def study
  tweet "searbsg", study_group("have coffee. vivace 6-7")
end

def monthly_study
  tweet "searbsg", study_group("not have coffee. substantial 6-7")
end

def holiday_study
  tweet "searbsg", "No study group tonight due to holiday!"
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

def holiday
  tweet "seattlerb", "No nerd party tonight due to holiday!"
end

arg = ARGV.first

today = if arg
          Date.parse arg
        else
          Date.today
        end

mm_dd = today.to_s[5..-1]

holidays = %w[07-04 10-31 12-25 12-31]

if holidays.include?(mm_dd) then
  holiday_study
  holiday
elsif today.wday == 2
  first_tues = Calendar.new(today.year, today.month).tuesday.first

  if today == first_tues then
    monthly_study
    monthly
  else
    study
    weekly
  end
else
  puts "nothing to do" if $n
end
