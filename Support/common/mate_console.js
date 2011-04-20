// Desktop log line
// [20:19:13:685] [Titanium.Host] [Information] Loaded module = tifilesystem

// Mobile log line
// [DEBUG] executing command: /usr/bin/killall iPhone Simulator

function run(cmd, onread) {
	
	function to_lines(read_input, f) {
		var lines = read_input.split("\n");
		for(var li in lines) {
			var line = lines[li];
			f(line);
		}
	}
	
	function output(status, line) {
		var html = onread(status, line);

		var el = $(html);
								
		el.appendTo('#result');
	}
	
	myCommand = TextMate.system(cmd, function(status) {
		output('finished', status);
	});
	myCommand.onreadoutput = function(read_input) {           
		to_lines(read_input, function(line) {
			output('read', line);
		});
		
		prettyPrint();
	};
	myCommand.onreaderror = function(read_input) { 
		to_lines(read_input, function(line) {
			output('error', line);
		});
		
		prettyPrint();
	};	
}
