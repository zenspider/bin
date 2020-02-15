#!/usr/bin/env ruby -w

require_relative "./of_common.rb"

of = Omnifocus.new
results = of.results :count_soon
p results.flatten.first.to_i
