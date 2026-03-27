#!/usr/bin/env -S ruby -ws

$l ||= false # longer version

require "erb"

abort "quickbench [-l] number-of-benchmarks" unless ARGV.size == 1
count = ARGV.shift.to_i

# remove unused var warnings. usage not seen in ERB template
names = methods = imethods = nil

names    = count.times.map { |n| ":bench_#{n}" }
methods  = count.times.map { |n| "def bench_#{n} = nil" }
imethods = methods.map { |s| s.gsub(/^/, "  ") }

short, long = DATA.read.split "OR"
template = $l ? long : short

puts ERB.new(template.strip).result

__END__
#!/usr/bin/env -S ruby -w --yjit

require "benchmark/ips"

<%= methods.join "\n" %>

Benchmark.ips_quick(<%= names.join ", " %>, warmup: 2, time: 5)
OR
#!/usr/bin/env -S ruby -w --yjit

require "benchmark/ips"

class B
<%= imethods.join "\n" %>
end

b = B.new

Benchmark.ips_quick(<%= names.join ", " %>, on: b, warmup: 2, time: 5)
