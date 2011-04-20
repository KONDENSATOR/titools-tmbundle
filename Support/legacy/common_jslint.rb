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

# Split input on empty lines
def error_chunks(text) 
  text.split(/^$/).select(){ |block| block =~ /^(\d+)\t([^\t]+)\t([^\t]+)\t(.+)$/ }
end

# Parse a text chunk
def parse(text)
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

# Output item html
def item_template(item, type)
    html = <<output
      <div class='issue #{type}'>
        <div class='filename'>#{item[:filename]}</div>
        <div class='description'>#{type} #{item[:description]}</div>
        <span class='line_number'>Line #{item[:linenumber]}<span>
        <span class='code'><a href="txmt://open?url=file://#{item[:filename]}&line=#{item[:linenumber]}">#{CGI::escapeHTML(item[:code])}</a></span>
      </div>
output
end

# Output document template
def document_tmplate(errors, warnings)
  warnings_str = warnings.map() { |warning| item_template(warning, :warning) }.join("\n")
  errors_str = errors.map() { |error| item_template(error, :error) }.join("\n")
  
  html = <<output
  <html>
    <head>
      <style type="text/css">
        body { font-family:sans-serif; }

        h2 { font-size: 18px; margin: 18px 0 4px 4px; }

        h2.errors, h2.errors a { color: #cc3300; }

        h2.warnings, h2.warnings a { color: #0563b2; }

        a { text-decoration:none; color: #000; }
        a:hover { text-decoration:underline; }
        .error { background-color:#f9d3d3; border-color: #cc3300; }
        .error a{ color: #cc3300; }
        .warning { background-color:#ebf4fc; border-color: #0563b2; }
        .warning a{ color: #0563b2; }
        .issue {
          border-style:solid;
          border-width:1px;
          margin-bottom:5px;
          padding:8px;
          border-radius: 8px;
          -moz-border-radius: 8px;
        }
        .filename, .line_number, .description { font-size: 12px; margin-bottom: 3px; }
        .line_number {
          min-width:170px;
          font-family: "Bitstream Vera Sans Mono", monospace;
          font-weight: bold;
        }
        .filename:before { font-weight: bold; content: 'File: '; }
        .code {
          font-family: "Bitstream Vera Sans Mono", monospace;
          /*border-style:dotted;*/
          border-width:1px;
          margin-bottom:5px;
          font-weight: bold;
        }
        .footer {
          margin-top: 10px;
          text-align: right;
          color: #AAA;
          font-size: 12px;
        }
        </style>
      </head>
    <body>
      <h2 class="errors">Errors (#{errors.length})</h2>
      #{errors_str}
      <h2 class="errors">Warnings (#{warnings.length})</h2>
      #{warnings_str}
      <div class="footer">JSLINT TextMate bundle provided by <a href="http://kondensator.se">KONDENSATOR</a></div>
    </body>
  </html>
output
end

# Execute jsl command
def run_jsl()
  s = `"#{ENV['TM_BUNDLE_SUPPORT']}/jsl-0.3.0-mac/jsl" -conf "#{ENV['TM_BUNDLE_SUPPORT']}/jsl.conf" -process "#{ENV['TM_FILEPATH']}"`
  
  # Ignore jquery files
  chunks = error_chunks(s).select { |itm| not itm =~ /.*jquery.*/i }

  # Parse output
  chunks = chunks.map { |chunk| 
    parse(chunk) 
    }
    
  # Devide result in errors and warnings
  errors = chunks.select { |chunk| chunk == nil ? false : chunk[:type] == "error" ? true : false }
  warnings = chunks.select { |chunk| chunk == nil ? false : chunk[:type] == "warning" ? true : false }
  
  return {
    :errors => errors,
    :warnings => warnings
  }
end