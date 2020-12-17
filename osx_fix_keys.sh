#!/usr/bin/env ruby -w

# glossary:
#
# @ = command
# ~ = option
# ^ = ctrl
# $ = shift

{
  "com.apple.iWork.Keynote" => {
    "Collapse All"             => "@~0",
    "Expand All"               => "@~9",
    "Fit in Window"            => "@~=>",
    "Light Table"              => "@~l",
    "Navigator"                => "@~n",
    "Outline"                  => "@~u",
    "Play Slideshow"           => "@p",
    "Reapply Master to Slide"  => "@^m",
    "Reapply Master to Slides" => "@^m",
    "Rehearse Slideshow"       => "@r",
  }
}.each do |domain, bindings|
  bindings.each do |menu, binding|
    system "defaults write %s NSUserKeyEquivalents -dict-add %p -string %p" \
      % [domain, menu, binding]
  end
end
