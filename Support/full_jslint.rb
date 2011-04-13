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

require ENV['TM_BUNDLE_SUPPORT'] + '/common_jslint'


# Generate HTML
result = run_jsl()

puts document_tmplate(result[:errors], result[:warnings])
