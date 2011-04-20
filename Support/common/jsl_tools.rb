# The program takes a javascript or html file
# and runs it through jslint (jsl command).
#
# This application is intended for usage with
# TextMate as a TextMate bundle.
#
# Author::    Fredrik Andersson (mailto:fredrik@kondensator.se)
# Copyright:: Copyright (c) 2011 KONDENSATOR AB
# License::   Distributes under the same terms as Ruby

require "cgi"
require $tm_bundle_support_path + '/common/ti_tools'

class JslTools
  
  # Parse a text chunk
  def self.parse(text)
    # match = text.scan(/^(\/[^:]+):\s([^:]+):\s(.+)$/)[0]
    rows = text.split(/\n/)

    rows.shift(rows.length-3) if rows.length > 3

    match = rows[0].scan(/^(\d+)\t([^\t]+)\t([^\t]+)\t(.+)$/)[0]

    result = {
      :linenumber => match[0],
      :file => match[1],
      :filename => match[2],
      :type => match[3] =~ /warning/i ? "warning" : "error",
      :description => match[3],
      :code => rows[1],
      :position => rows[2].scan(/^(.*)\^$/)[0][0].length
    }
    return result
  end
  
  # Split input on empty lines
  def self.error_chunks(text) 
    text.split(/^$/).select(){ |block| block =~ /^(\d+)\t([^\t]+)\t([^\t]+)\t(.+)$/ }
  end
  
  # Execute jsl command
  def self.run_jsl(file)
    
    cmd = TiTools::jsl_command(file)
    
    # Perform command
    s = %x{#{cmd}}

    # Ignore jquery files
    chunks = JslTools::error_chunks(s).select { |itm| not itm =~ /.*jquery.*/i }

    # Parse output
    chunks = chunks.map { |chunk| JslTools::parse(chunk) }

    # Devide result in errors and warnings
    errors = chunks.select { |chunk| chunk == nil ? false : chunk[:type] == "error" ? true : false }
    warnings = chunks.select { |chunk| chunk == nil ? false : chunk[:type] == "warning" ? true : false }

    return {
      :errors => errors,
      :warnings => warnings
    }
  end
end

# Run tests
if __FILE__ == $0
  
end