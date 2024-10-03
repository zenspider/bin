#!/usr/bin/env ruby -ws

$o ||= false # open dead, exits
$p ||= false # pry at end
$y ||= false # yes, delete

require "isolate"
Isolate.now! name: "prune_gists" do
  gem "octokit"
end
require "octokit"

now   = Time.now
stale = now - 365 * 86_400

github_token = %x(gh auth token).chomp
ghc = Octokit::Client.new(access_token: github_token)
ghc.auto_paginate = true
ghc.per_page = 100

gs = ghc.gists

$stderr.print "#{gs.count}: "
dead = gs.select { |g|
  $stderr.print "."
  # g[:forks] = ghc.get(g.forks_url)
  g[:comments] = ghc.get(g.comments_url)

  g.created_at < stale &&
    g.updated_at < stale &&
    g[:comments].map(&:body).join !~ /KEEP/
}
$stderr.puts "done"

if $o then
  system "open", *dead.map(&:html_url)
  exit
end

dead.reverse.each do |g|
  puts g.to_h[:html_url]
  ghc.delete_gist g.id if $y
end

pp TOTAL: gs.count, DEAD: dead.count

if $p then
  require "pry"; binding.pry

  p :done
end
