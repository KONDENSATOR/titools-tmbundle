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


# Traverse the directory tree to find the root of the project
def find_project_root(dir)
  f = File.join(dir, "tiapp.xml")
  
  return dir if File.exist?(f)
  return find_project_root(File.expand_path("..", dir))
end

# Find out project dir root
proj_dir = find_project_root(ENV["TM_PROJECT_DIRECTORY"])

# Read project tiapp.xml
tiapp_xml = File.open(File.join(proj_dir, "tiapp.xml"), 'r') { |f| f.read }

# Fetch app id from tiapp.xml
id = tiapp_xml.scan(/^\<id\>(.*)\<\/id\>/)[0]

# Fetch app name from tiapp.xml
name = tiapp_xml.scan(/^\<name\>(.*)\<\/name\>/)[0]

# Is project a desktop or mobile project
desktop = tiapp_xml =~ /\<url\>app:\/\/.+\<\/url\>/


if desktop == nil then
  # Command for running desktop app
  cmd = "python '#{@titanium_path}/mobilesdk/osx/#{@tim_version}/iphone/builder.py' simulator '#{@ios_version}' '#{proj_dir}' #{@id} '#{@name}' iphone"
elsif
  # Command for running iPhone app
  cmd = "python '#{@titanium_path}/sdk/osx/#{@tid_version}/tibuild.py' -d '#{proj_dir}/dist/osx' -a '#{@titanium_path}/sdk/osx/#{@tid_version}' -n -r -v -s '#{@titanium_path}' '#{proj_dir}'"
end

# Execute output
document_tmplate(cmd)
