#!/usr/bin/env ruby -ws

$y ||= false # yes, commit

require "date"

class Date
  def next_monday
    (self..(self+7)).find { |day| day.wday == 1 }
  end
end

if $y then
  warn "setting $stdout to osascript"
  $stdout = IO.popen "osascript", "w"
end

LOCATION = {
  :home => "530 Broadway E\nSeattle WA 98102\nUnited States",
  :gym  => "RCF\n1516 11th Ave\nSeattle, WA 98122\nUnited States",
}

sun, mon, tue, wed, thu, fri, sat = (0..6).to_a
sun = sun # warning
sat = sat # warning

year = Date.today.year

d = Date.new(year, 1, 1)

week = (d..(d+6)).to_a

first_weekday = week.find { |day| day.wday.between? mon, fri }

first = week.rotate(-d.wday)

def t n_or_a
  case n_or_a
  when Array
    "%02d:%02d" % n_or_a
  else
    "%02d:%02d" % [n_or_a, 0]
  end
end

def new_event title, t0, t1, where, repeat:nil
  puts "set theEvent to create event event store theStore destination calendar theCal event summary %p starting date (date %p) ending date (date %p) %s" % [title, t0, t1, where]

  case repeat
  when :weekly, :weekdays then
    puts "modify recurrence event theEvent event frequency do weekly event interval 1 repeats until endOfYear"
  when :yearly then
    # do nothing?
    # puts "modify recurrence event theEvent event frequency do yearly event interval 1 repeats for 10"
  else
    # do nothing
  end

  puts "store event event theEvent event store theStore"

  if repeat == :weekdays then
    puts "my setToWeekdays(event_external_ID of (event info for event theEvent))"
  end

  puts
end

def all_day date, title
  date = Date.parse(date) if String === date

  puts "-- %s all day %s" % [date, title]

  d = date.to_time.strftime "%D"

  new_event title, d, d, "with runs all day"
end

def event date, start, stop, repeat, title, where = nil
  date = Date.parse(date) if String === date
  date = date.next_year if repeat == :next_year

  puts "-- %s %s-%s %-8s %s" % [date, t(start), t(stop), repeat, title]

  h0, m0 = start
  h1, m1 = stop

  m0 ||= 0
  m1 ||= 0

  where = "event location %p" % LOCATION[where] if where

  fmt = "%m/%d/%Y %H:%M %p"
  t0 = (date.to_time + (h0 * 3600) + (m0 * 60)).strftime fmt
  t1 = (date.to_time + (h1 * 3600) + (m1 * 60)).strftime fmt

  new_event title, t0, t1, where, repeat:repeat

  if repeat == :weekdays then
    puts "my setToWeekdays(event_external_ID of (event info for event theEvent))"
  end

  puts
end

puts DATA.read
puts

#     date,       start,    stop,       repeat,   title,        where=nil

event first_weekday, [10,30], 11,      :weekdays, "Coffee & Triage"

event first[mon],    18,      23,      :weekly,   "Me Night",   :home
event first[mon],    [15,30], 16,      :weekly,   "1:1"
event first[mon],    [16,30], [17,30], :weekly,   "Pain",       :gym
event first[tue],    18,      19,      :weekly,   "Study Group"
event first[tue],    19,      21,      :weekly,   "Nerd Party"
event first[wed],    18,      23,      :weekly,   "Me Night",   :home
event first[thu],    18,      23,      :weekly,   "Kai"
event first[fri],    18,      23,      :weekly,   "Me Night",   :home
event first[fri],    12,      13,      :weekly,   "Pain",       :gym

may_taxes = Date.new(year,  4, 15).next_monday
oct_taxes = Date.new(year, 10, 15).next_monday

event may_taxes,     12,      [12,30], :yearly,   "Schedule Property Tax Payment"
event oct_taxes,     12,      [12,30], :yearly,   "Schedule Property Tax Payment"
event "4/23",        12,      [12,30], :yearly,   "No, Really! Pay Property Taxes"
event "10/23",       12,      [12,30], :yearly,   "No, Really! Pay Property Taxes"

event "1/1",         12,      [12,30], :next_year,"Run setup_calendar_fast.rb"

all_day "4/30",                                   "Property Taxes"
all_day "10/31",                                  "Property Taxes"
all_day "3/14",                                   "Steak & Blowjob Day"
all_day "5/8",                                    "Outdoor Intercourse Day"
all_day "10/15",                                  "My Ruby Birthday (2000)"
all_day "2/28",                                   "Seattle.rb Anniversary (2002)"

if $y then
  $stdout.flush
  $stdout.close
end

__END__
use scripting additions
use script "CalendarLib EC" version "1.1.5" -- put this at the top of your scripts

set thisYear to year of (current date)
set startOfYear to date ("Jan 1 " & thisYear)
set endOfYear to date ("Dec 31 " & thisYear & " 23:59 PST")

set theStore to fetch store
if theStore is missing value then
  error "Couldn't find Calendar Store"
end if

set theCal to fetch calendar "Test" cal type cal cloud event store theStore
if theCal is missing value then
  error "Couldn't find Test calendar"
end if

set myEvents to fetch events starting date startOfYear ending date endOfYear searching cals {theCal} event store theStore
repeat with anEvent in myEvents
        try
                remove event event anEvent event store theStore
        on error errMsg number errNum
                -- do nothing, I'm assuming this is from repeating tasks?
        end try
end repeat

on setToWeekdays(myID)
  tell application "Calendar"
    tell calendar "Test"
      set e to (event id myID)
      set s to recurrence of e

      -- from "FREQ=WEEKLY;INTERVAL=1;UNTIL=20191231T235900"
      -- to   "FREQ=WEEKLY;UNTIL=20181221T200000Z;BYDAY=MO,TU,WE,TH,FR"
      set mydate to last word of s
      set newS to "FREQ=WEEKLY;UNTIL=" & mydate & ";BYDAY=MO,TU,WE,TH,FR"

      set recurrence of e to newS
    end tell
  end tell
end setToWeekdays
