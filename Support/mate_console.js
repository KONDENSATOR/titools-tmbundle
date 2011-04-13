function log_line(type, output, timestamp, host_code){
	type = type.toLowerCase();
	
	if(type == "information") {
		type = "info";
	}
	console.log("<div class='" + type + "'>" + output + "</div>");
	return "<div class='" + type + "'>" + output + "</div>";
}

function to_lines(read_input, f) {
	var lines = read_input.split("\n");
	for(var li in lines) {
		var line = lines[li];
		f(line);
	}
}

// Desktop log line
// [20:19:13:685] [Titanium.Host] [Information] Loaded module = tifilesystem

// Mobile log line
// [DEBUG] executing command: /usr/bin/killall iPhone Simulator

function run(cmd) {
	myCommand = TextMate.system(cmd);
	myCommand.onreadoutput = function(read_input) {           
		to_lines(read_input, function(line) {
			// Desktop regex
			var regex = /^\[([^\]]+)\]\s+\[([^\]]+)\]\s+\[([^\]]+)\]\s(.+)$/;
			var matches = regex.exec(line);

			if(matches !== null) {
				document.getElementById("result").innerHTML += log_line(matches[3], matches[4], matches[1], matches[2]);
			} else {

				// Mobile regex
				regex = /^\[([^\]]+)\]\s(.+)$/;
				matches = regex.exec(line);

				if(matches !== null) {
					document.getElementById("result").innerHTML += log_line(matches[1], matches[2]);
				}
			}
		});
	};
	myCommand.onreaderror = function(str) { console.log("error: " + str); };
}
