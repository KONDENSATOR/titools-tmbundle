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
# python /Library/Application Support/Titanium/mobilesdk/osx/1.5.1/iphone/builder.py simulator "4.3" "/Users/fredrik/Documents/gitrep/

# For desktop
# python "/Library/Application Support/Titanium/sdk/osx/1.1.0/tibuild.py" -d "$TM_PROJECT_DIRECTORY"/../dist/osx -a "/Library/Application Support/Titanium/sdk/osx/1.1.0" -n -r -v -s "/Library/Application Support/Titanium" "$TM_PROJECT_DIRECTORY"/../


proj_dir = ENV["TM_PROJECT_DIRECTORY"]

cmd = "python '/Library/Application Support/Titanium/sdk/osx/1.1.0/tibuild.py' -d '#{proj_dir}/../dist/osx' -a '/Library/Application Support/Titanium/sdk/osx/1.1.0' -n -r -v -s '/Library/Application Support/Titanium' '#{proj_dir}/../'"

document_tmplate(cmd)
