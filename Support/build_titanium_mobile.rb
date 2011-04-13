#!/usr/bin/env ruby

# The program takes a javascript or html file
# and runs it through jslint (jsl command).
#
# This application is intended for usage with
# TextMate as a TextMate bundle.
#
# Author::    Fredrik Andersson (mailto:fredrik@kondensator.se)
# Copyright:: Copyright (c) 2011 KONDENSATOR AB
# License::   Distributes under the same terms as Ruby

require 'cgi'

require ENV['TM_BUNDLE_SUPPORT'] + '/common_build_titanium'

# For mobile
# python '/Library/Application Support/Titanium/mobilesdk/osx/1.5.1/iphone/builder.py' simulator '4.3' '/Users/fredrik/Documents/gitrep/smtg-journal-mobile' se.kondensator.smtgjournal 'smtg-journal-mobile' iphone

def find_project_root(dir)
  f = File.join(dir, "tiapp.xml")
  
  return dir if File.exist?(f)
  return find_project_root(File.expand_path("..", dir))
end

proj_dir = find_project_root(ENV["TM_PROJECT_DIRECTORY"])
tiapp_xml = File.open(File.join(proj_dir, "tiapp.xml"), 'r') { |f| f.read }
id = tiapp_xml.scan(/^\<id\>(.*)\<\/id\>/)[0]
name = tiapp_xml.scan(/^\<name\>(.*)\<\/name\>/)[0]
version = "4.3"

cmd = "python '/Library/Application Support/Titanium/mobilesdk/osx/1.5.1/iphone/builder.py' simulator '#{version}' '#{proj_dir}' #{id} '#{name}' iphone"

document_tmplate(cmd)
