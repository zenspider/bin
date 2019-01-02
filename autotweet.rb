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

def tweet user, *text
  run "t set active #{user}"
  run "t update #{text.join(" ").inspect}"
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
  tweet "seattlerb", "It's our monthly! Come watch talks, not have coffee, and share something for show and tell. substantial 7-9. http://www.seattlerb.org/join-us"
end

def holiday
  tweet "seattlerb", "No nerd party tonight due to holiday!"
end

def birfday!
  age = Time.now.year - 2002

  suffix = case age % 10
           when 1 then
             "st"
           when 2 then
             "nd"
           when 3 then
             "rd"
           else
             "th"
           end

  tweet("seattlerb",
        "Happy #{age}#{suffix} Birfday to Seattle.rb!",
        "Thanks to @the_zenspider, @drbrain, and @PatEyler",
        "(and everyone who followed them) for making this happen!")
end

arg = ARGV.first

today = if arg
          Date.parse arg
        else
          Date.today
        end

mm_dd = today.to_s[5..-1]

holidays = %w[01-01 07-04 10-31 12-25 12-31]

if today.wday == 2 then
  first_tues = Calendar.new(today.year, today.month).tuesday.first

  case
  when holidays.include?(mm_dd) then
    holiday_study
    holiday
  when today == first_tues then
    monthly_study
    monthly
  else
    study
    weekly
  end
else
  puts "nothing to do" if $n
end

if today.month == 2 && today.day == 28 then
  birfday!
end
