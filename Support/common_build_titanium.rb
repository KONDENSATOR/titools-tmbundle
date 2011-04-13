
def document_tmplate(cmd)
  html = <<output
  <html>
    <head>
      <style type="text/css">
        body { font-family:sans-serif; }
        .debug {
          font-family: "Bitstream Vera Sans Mono", monospace;
          /*border-style:dotted;*/
          border-width:1px;
          margin-bottom:5px;
          font-weight: bold;
          font-size: 12px;
        }
        .information {
          font-family: "Bitstream Vera Sans Mono", monospace;
          /*border-style:dotted;*/
          border-width:1px;
          margin-bottom:5px;
          font-size: 12px;
        }
        .info {
          font-family: "Bitstream Vera Sans Mono", monospace;
          /*border-style:dotted;*/
          border-width:1px;
          margin-bottom:5px;
          font-size: 12px;
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
      <div id="result">
      </div>
      <div class="footer">JSLINT TextMate bundle provided by <a href="http://kondensator.se">KONDENSATOR</a></div>
      <script>
        function log_line(type, output, timestamp, host_code){
          type = type.toLowerCase();
          
          return "<div class='" + type + "'>" + output + "</div>";
        }
        
        function to_lines(read_input, f) {
          var lines = read_input.split("\\n");
          for(var li in lines) {
            var line = lines[li];
            console.log(line);
            f(line);
          }
        }
        
        myCommand = TextMate.system("#{cmd}");
        myCommand.onreadoutput = function(read_input) {           
          to_lines(read_input, function(line) {            
            
            // Desktop log line
            // [20:19:13:685] [Titanium.Host] [Information] Loaded module = tifilesystem
            
            // Mobile log line
            // [DEBUG] executing command: /usr/bin/killall iPhone Simulator
            
            // Desktop regex
            var regex = /^\\[([^\\]]+)\\]\\s+\\[([^\\]]+)\\]\\s+\\[([^\\]]+)\\]\\s(.+)$/;
            var matches = regex.exec(line);

            if(matches !== null) {
              document.getElementById("result").innerHTML += log_line(matches[3], matches[4], matches[1], matches[2]);
            } else {
              
              regex = /^\\[([^\\]]+)\\]\\s(.+)$/;
              var matches = regex.exec(line);
              
              if(matches !== null) {
                document.getElementById("result").innerHTML += log_line(matches[1], matches[2]);
              }
            }
          });
        };
        myCommand.onreaderror = function(str) { console.log("error: " + str); };
      </script>
    </body>
  </html>
output
  puts html
end