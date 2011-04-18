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

require ENV['TM_BUNDLE_SUPPORT'] + '/common_build_titanium'
require ENV['TM_BUNDLE_SUPPORT'] + '/config'
require 'rexml/document'

# Traverse the directory tree to find the root of the project
def find_project_root(dir)
  return nil if dir == nil 
    
  f = File.join(dir, "tiapp.xml")
  
  return dir if File.exist?(f)
  return find_project_root(File.expand_path("..", dir))
end

# Find out project dir root
proj_dir = find_project_root(ENV["TM_PROJECT_DIRECTORY"])

if proj_dir == nil then
  
  puts "<p><b>Error finding tiapp.xml</b> - You must open your TextMate project folder from within a Titanium project path.</p>"
  puts "<p>Preferably the root of the project or the Resources folder.</p>"
  
  exit()
end

# Read project tiapp.xml
tiapp_xml = REXML::Document.new(File.new(File.join proj_dir, 'tiapp.xml')).root

@id = tiapp_xml.elements['id'].first.to_s
@name = tiapp_xml.elements['name'].first.to_s
@desktop = tiapp_xml.elements['url'].first.to_s.start_with?('app:')

if @desktop
  # Command for running desktop app
  cmd = "python '#{@titanium_path}/sdk/osx/#{@tid_version}/tibuild.py' -d '#{proj_dir}/dist/osx' -a '#{@titanium_path}/sdk/osx/#{@tid_version}' -n -r -v -s '#{@titanium_path}' '#{proj_dir}'"
elsif @android
  cmd = "ruby '#{ENV['TM_BUNDLE_SUPPORT']}/build_ti_android.rb' '#{proj_dir}'"
else
  # Command for running iPhone app
  cmd = "python '#{@titanium_path}/mobilesdk/osx/#{@tim_version}/iphone/builder.py' simulator '#{@ios_version}' '#{proj_dir}' #{@id} '#{@name}' iphone"
end

# Execute output
document_tmplate(cmd)
