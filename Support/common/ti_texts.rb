def text_project_path_error()
  html = <<output
<p><b>Error finding tiapp.xml</b> - You must open your TextMate project folder from within a Titanium project path.</p>
<p>Preferably the root of the project or the Resources folder.</p>
output
  return html
end

def style_template()
  html = <<output
  body { font-family:sans-serif; }
  .debug {
    font-family: "Bitstream Vera Sans Mono", monospace;
    color:#bbb;
    font-size: 12px;
    display: none;
    margin-top: 6px;
    margin-bottom: 2px;
  }
  .info {
    font-family: "Bitstream Vera Sans Mono", monospace;
    font-size: 12px;
    display: none;
    margin-top: 6px;
    margin-bottom: 2px;
  }
  .finished {
    margin-top: 50px;
    color: #aaa;
    font-size: 12px;
    background:rgb(200, 0,0);
  }
  .parse_fail {
    font-family: "Bitstream Vera Sans Mono", monospace;
    font-size: 12px;
    margin-top: 6px;
    margin-bottom: 2px;
    background:rgb(200, 0,0);
  }
  .footer {
    margin-top: 10px;
    text-align: right;
    color: #aaa;
    font-size: 12px;
  }
  header .toggle_button {
  	background: -webkit-gradient(linear, 0% 0%, 0% 100%, from(#83c77a), to(#0e6700));
  	width: 103px;
  	height: 15px;
  	float: right;
  	border: 1px solid green;
  	text-align: center;
  	padding-left: 2px;
  	font-size: 12px;
  	margin-right: 10px;
  	margin-top: 10px;
  	cursor: pointer;
  	opacity: 0.75;

  	-webkit-box-shadow: 0 1px 3px rgba(0,0,0,0.5);
  	-webkit-border-radius: 10px;
  	-webkit-transition-property:opacity;
  	-webkit-transition-duration: 0.15s, 0.15s;
  	-webkit-transition-timing-function: linear, ease-in;
  }

  header .toggle_button:hover {
  	opacity: 1.0;
  }

  header .toggle_button .toggle_tooltip {
  	display: none;

  	font-size: 10px;
  	color: white;
  	padding: 3px;
  	border: 1px solid black;
  	background-color:rgba(0,0,0,0.5);
  	width: 115px;
  	margin-top: -17px;

  	position: absolute;
  	right: 30px;

  	-webkit-transition-property:display;
  	-webkit-transition-duration: 0.15s, 0.15s;
  	-webkit-transition-timing-function: linear, ease-in;
  }

  header .toggle_button:hover .toggle_tooltip {
  	display: block;
  }
output
  return html
end

def body_template(cmd, parser)
  html = <<output
      <header>
        <div id="toggle_debug" class="toggle_button" onclick="debug_visible = toggle_display('debug', debug_visible);">Debug</div>
        <div id="toggle_info" class="toggle_button" onclick="info_visible = toggle_display('info', info_visible);">Info</div>
      </header>
      <div id="result">
      </div>
      <div class="footer">JSLINT TextMate bundle provided by <a href="http://kondensator.se">KONDENSATOR</a></div>
      <script>
        $(document).ready(function(){
          var debug_visible = false;
          var info_visible = true;
          
          function output_visibility(type){
              var displ = 'block';
              if((type == 'debug' && debug_visible === false) ||
                (type == 'info' && info_visible === false)) {
                displ = 'none';
              }
              return "display:"+displ+";"
          }
          
          function output_row(type, output){
            var prettify = "";
          
            if(/^\\s*[{|\\[]/.test(output)){
              prettify = "prettyprint";
              var o = JSON.parse(output);
              output = JSON.stringify(o, null, 2);
            }
            
            return "<pre style='"+output_visibility(type)+"' class='"+type+" "+ prettify +"'>" +output+ "</pre>";
          }
          
          run("#{cmd}", #{parser});
        });
      </script>
output
  return html
end

def css_include_template(file)
  %{<link href="file://#{file}" type="text/css" rel="stylesheet" />}
end
def js_include_template(file)
  %{<script type="text/javascript" src="file://#{file}"></script>}
end

def document_template(js_includes, css_includes, cmd, parsers)
  html = <<output
<!DOCTYPE html>
<html>
  <head>
  	<meta charset="utf-8">
      <style type="text/css">
        #{style_template}
      </style>
      
      #{ js_includes.map() { |js_inc| js_include_template(js_inc) }.join("\n") }
      #{ css_includes.map() { |js_inc| css_include_template(js_inc) }.join("\n") }

      <script type="text/javascript">
        var debug_visible = false;
        var info_visible = true;
        
        function toggle_display(type, visibility) {
          if(visibility === true) {
            $('.' + type).css('display','block');
            return false;
          } else {
            $('.' + type).css('display','none');
            return true;
          }
        }
      </script>
    </head>
  <body>
    #{body_template(cmd, parsers)}
  </body>
</html>
output
  return html
end

# Output item html
def jsl_item_template(item, type)
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
def jsl_document_tmplate(errors, warnings)
  warnings_str = warnings.map() { |warning| jsl_item_template(warning, :warning) }.join("\n")
  errors_str = errors.map() { |error| jsl_item_template(error, :error) }.join("\n")
  
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

def js_parse_desktop()
  js = <<output_desktop
  function(status, line) {
    return "<div>"+line+"<div>";
  }
output_desktop
end

def js_parse_ios()
  js = <<output_ios
  function(status, line) {
    var regex = /^\\[(\\w+)\\](.*)$/;
    var result = "";
    
    if(line == "") {
    } else if(status == "finished") {
      result = output_row('finished', 'Application finished');
    } else { 
      var matches = regex.exec(line);
      
      if(matches !== null) {
        var type = matches[1].toLowerCase();
        var output = matches[2];
        
        result = output_row(type, output);
      } else {
        result = output_row('parse_fail', line);
      }
    }
    return result;
  }
output_ios
end

def js_parse_android()
  js = <<output_android
  function(status, line) {
    var regex = /^(\\w)\\/([\\w|-]+)\\s*(\\(\\s*\\d+\\)):(.*)/i;
    var result = "";
    
    if(status == "finished") {
      result = output_row('finished', 'Application finished');
    } else if(regex.test(line) === false) {
      result = output_row('parse_fail', line);
    } else { 
      var matches = regex.exec(line);
      
      var priority = matches[1].toLowerCase();
      type = 'info';
      
      switch(priority) {
        case 'v': type = 'debug'; break; // V — Verbose (lowest priority)
        case 'd': type = 'debug'; break; // D — Debug
        case 'i': type = 'info'; break; // I — Info
        case 'w': type = 'info'; break; // W — Warning
        case 'e': type = 'info'; break; // E — Error
        case 'f': type = 'info'; break; // F — Fatal
        case 's': type = 'debug'; break; // S — Silent (highest priority, on which nothing is ever printed)
      }
      
      var output = matches[4];

      var logline_regex = /^\\s*\\((.+)\\)\\s+\\[\\d+,\\d+]\\s(.*)/
      
      if(logline_regex.test(output)){
        var logline_matches = logline_regex.exec(output);
        
        output = logline_matches[2];
        type = 'info';
      } else {
        console.log(output);
        
        type = 'debug';
      } 

      result = output_row(type, output);
    }
    return result;
  }
output_android
end
