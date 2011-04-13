
def document_tmplate(cmd)
  bundle_support = ENV['TM_BUNDLE_SUPPORT']
  
  html = <<output
<!DOCTYPE html>
<html>
  <head>
  	<meta charset="utf-8">
    <style type="text/css">
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
      </style>
      <!-- <link href="file://#{bundle_support}/prettify/prettify.css" type="text/css" rel="stylesheet" />
      <script type="text/javascript" src="file://#{bundle_support}/prettify/prettify.js"></script> -->

      <link href="file://#{bundle_support}/google-code-prettify/src/prettify.css" type="text/css" rel="stylesheet" />
      <script type="text/javascript" src="file://#{bundle_support}/google-code-prettify/src/prettify.js"></script>
      
      <script type="text/javascript" src="file://#{bundle_support}/jquery-1.5.2.min.js"></script>
      <script type="text/javascript" src="file://#{bundle_support}/mate_console.js"></script>
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
    <header>
      <div id="toggle_debug" class="toggle_button" onclick="debug_visible = toggle_display('debug', debug_visible);">Debug</div>
      <div id="toggle_info" class="toggle_button" onclick="info_visible = toggle_display('info', info_visible);">Info</div>
    </header>
    <div id="result">
    </div>
    <div class="footer">JSLINT TextMate bundle provided by <a href="http://kondensator.se">KONDENSATOR</a></div>
    <script>
      $(document).ready(function(){
        run("#{cmd}", function(type, output, timestamp, host_code){
          var displ = 'none';
          if((type == 'debug' && debug_visible === true) ||
            (type == 'info' && info_visible === true)) {
            displ = 'block';
          }

          var prettify = "";
          
          if(/^\\s*[{|\\[]/.test(output)){
            prettify = "prettyprint";
            var o = JSON.parse(output);
            output = JSON.stringify(o, null, 2);
          }
          
          return "<pre style='display:"+ displ +";' class='"+type+" "+prettify+"'>" + output + "</pre>";
        });
      });
    </script>
  </body>
</html>
output
  puts html
end
