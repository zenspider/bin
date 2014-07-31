#!/usr/bin/env ruby -w

def usage
  puts "quickbench number-of-benchmarks"
  exit 1
end

# path = ARGV.shift || usage
count = ARGV.shift.to_i || usage
usage unless ARGV.empty?

print <<'EOM'
#!/usr/bin/env ruby -w

require 'benchmark/ips'

Benchmark.ips do |x|
  # x.options
EOM

count.times do |n|
  print <<"EOM"

  x.report("benchmark-#{n+1}") do |max|
    max.times do
      # insert code here
    end
  end
EOM
end

puts "  x.compare!"
puts "end"
