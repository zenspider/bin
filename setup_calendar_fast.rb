#!/usr/bin/env ruby

require "date"

LOCATION = {
  :home => "530 Broadway E\nSeattle WA 98102\nUnited States",
  :gym  => "1666 E Olive Way\nSeattle WA 98102\nUnited States"
}

sun, mon, tue, wed, thu, fri, sat = (0..6).to_a

year = Date.today.year

d = Date.new(year, 1, 1)

week = (d..(d+6)).to_a

first_weekday = week.find { |day| d.wday.between? mon, fri }

first = week.rotate(-d.wday)

def t n_or_a
  case n_or_a
  when Array
    "%02d:%02d" % n_or_a
  else
    "%02d:%02d" % [n_or_a, 0]
  end
end

def all_day date, title
  puts "-- %s all day %s" % [date, title]

  date = Date.parse(date) if String === date
  fmt = "%m/%d/%Y"
  d = date.to_time.strftime fmt

  puts "set theEvent to create event event store theStore destination calendar theCal event summary %p starting date (date %p) ending date (date %p) with runs all day" % [title, d, d]
  puts "store event event theEvent event store theStore"
  puts
end

def event date, start, stop, repeat, title, where = nil
  puts "-- %s %s-%s %-8s %s" % [date, t(start), t(stop), repeat, title]

  date = Date.parse(date) if String === date

  h0, m0 = start
  h1, m1 = stop

  m0 ||= 0
  m1 ||= 0

  where = "event location %p" % LOCATION[where] if where

  fmt = "%m/%d/%Y %H:%M %p"
  t0 = (date.to_time + (h0 * 3600) + (m0 * 60)).strftime fmt
  t1 = (date.to_time + (h1 * 3600) + (m1 * 60)).strftime fmt

  puts "set theEvent to create event event store theStore destination calendar theCal event summary %p starting date (date %p) ending date (date %p) %s" % [title, t0, t1, where]

  case repeat
  when :weekly, :weekdays then
    puts "modify recurrence event theEvent event frequency do weekly event interval 1 repeats until endOfYear"
  when :yearly then
    puts "modify recurrence event theEvent event frequency do yearly event interval 1 repeats for 10"
  else
    raise "UNKNOWN: #{repeat}"
  end
  puts "store event event theEvent event store theStore"

  if repeat == :weekdays then
    puts "my setToWeekdays(event_external_ID of (event info for event theEvent))"
  end

  puts
end

puts DATA.read
puts
event first[mon],    18,      23,      :weekly,   "Me Night",   :home
event first[mon],    10,      [10,30], :weekly,   "Weekly Planning"
event first[thu],    [10,30], 11,      :weekly,   "1:1"
event first[tue],    18,      19,      :weekly,   "Study Group"
event first[tue],    19,      21,      :weekly,   "Nerd Party"
event first[wed],    12,      [12,30], :weekly,   "Ryan & Phil Call"
event first[thu],    18,      23,      :weekly,   "Kai"
event first[fri],    18,      23,      :weekly,   "Me Night",   :home

# event first_weekday, 12,      13,      :weekdays, "Get Moving", :home
# event first_weekday, 13,      [13,30], :weekdays, "Standup",    :home

event "4/23",        12,      [12,30], :yearly,   "Pay Property Taxes"
event "10/23",       12,      [12,30], :yearly,   "Pay Property Taxes"

all_day "4/30",                                   "Property Taxes"
all_day "10/31",                                  "Property Taxes"
all_day "3/14",                                   "Steak & Blowjob Day"
all_day "5/8",                                    "Outdoor Intercourse Day"
all_day "10/15",                                  "My Ruby Birthday (2000)"

__END__
use scripting additions
use script "CalendarLib EC" version "1.1.4" -- put this at the top of your scripts

set thisYear to year of (current date)
set startOfYear to date ("Jan 1 " & thisYear)
set endOfYear to date ("Dec 31 " & thisYear & " 23:59 PST")

set theStore to fetch store
set theCal to fetch calendar "Test" cal type cal cloud event store theStore

if theCal is missing value then
  error "Couldn't find Test calendar"
end if

set myEvents to fetch events starting date startOfYear ending date endOfYear searching cals {theCal} event store theStore
repeat with anEvent in myEvents
        remove event event anEvent event store theStore
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
