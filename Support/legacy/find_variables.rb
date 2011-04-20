# require ENV['TM_BUNDLE_SUPPORT'] + '/config'
require '/Users/fredrik/Library/Application Support/TextMate/Bundles/ti-tools.tmbundle/Support/config'

def device_matches()
  result = %x{ps Ax}

  regex = /^\s+\d+\s+[\?|\w|\d]+\s+\w+\s+\d+:\d+\.\d+\s+python\s+([\/|\w|\s]+Titanium)[^\d]+([\d\.]+).*"([\d\.]+)"/

  matches = result.scan(regex)
  
  puts matches.inspect()
  
  return nil if matches == nil || matches[0] == nil
  
  return matches[0]
end

def devices_available()
  result = %x{#{@adb} devices}
  
  rows = result.split("\n")
  
  rows.delete_at(0)
  
  result = []
  
  rows.each do |row|
    itms = row.split("\t")
    result << { :name => itms[0], :status => itms[1] }
  end
  
  return result
end


if __FILE__ == $0  
  matches = device_matches()
  
  if matches != nil then
    puts %{@titanium_path = "#{matches[0]}"}
    puts %{@tim_version = "#{matches[1]}"}
    puts %{@ios_version = "#{matches[2]}"}
  else
    puts %{You don't have any build/run process running.}
  end
end