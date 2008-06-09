#!/usr/bin/env ruby -w

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
#!/usr/bin/env ruby -w

require 'benchmark'

max = (ARGV.shift || 1_000_000).to_i

puts "# of iterations = #{max}"
Benchmark::bm(20) do |x|
  x.report("null_time") do
    for i in 0..max do
      # do nothing
    end
  end

EOM

count.times do |n|
  print <<"EOM"
  x.report("benchmark-#{n+1}") do
    for i in 0..max do
      # insert code here
    end
  end

EOM
end

puts "end"

