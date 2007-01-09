#!/usr/local/bin/ruby -w

# TODO: while you are doing this, add an emacs method that toggles
# between test file and implementation!

def usage
  puts "quickbench number-of-benchmarks"
  exit 1
end

# path = ARGV.shift || usage
count = ARGV.shift.to_i || usage
usage unless ARGV.empty?

print <<'EOM'
require 'benchmark'

max = (ARGV.shift || 1_000_000).to_i

puts "# of iterations = #{max}"
Benchmark::bm(20) do |x|
  x.report("null_time") {
    for i in 0..max do
      # do nothing
    end
  }

EOM

count.times do |n|
  print <<"EOM"
  x.report("benchmark-#{n+1}") {
    for i in 0..max do
      # insert code here
    end
  }

EOM
end

puts "end"

