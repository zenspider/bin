#!/usr/bin/env ruby

$: << "/opt/homebrew/Library/Homebrew"

class Object
  def present?
    respond_to?(:empty?) ? !empty? : !!self
  end
end

module Homebrew
  module EnvConfig
    def self.const_missing name
      :NAH!
    end

    def self.sig
      :NAH!
    end
  end
end

module T
  module Sig
  end
end

ENV["HOMEBREW_USER_CONFIG_HOME"] = "fuck off"
require "env_config"
ENV.delete "HOMEBREW_USER_CONFIG_HOME"

current = ENV.keys.grep(/HOMEBREW/)
exclude = DATA.read.split

man = `man brew`
  .gsub(/\x08./, "") # delete \b<char> from bold manpage output
  .scan(/HOMEBREW_\w+/)
  .sort
  .uniq

envs = Homebrew::EnvConfig::ENVS.keys.map(&:to_s)

(envs + man - exclude).uniq.each do |name|
  next unless name =~ /BREW_NO_/ and not current.include? name

  puts "export #{name}=1"
end

(current - envs - man).each do |name|
  puts "Remove? #{name}"
end

__END__
HOMEBREW_NO_BOOTSNAP
HOMEBREW_NO_CLEANUP_FORMULAE
HOMEBREW_NO_ENV_HINTS
HOMEBREW_NO_INSTALL_FROM_API
HOMEBREW_NO_UPDATE_REPORT_NEW
