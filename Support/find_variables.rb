result = %x{ps Ax}

regex = /^\s+\d+\s+[\?|\w|\d]+\s+\w+\s+\d+:\d+\.\d+\s+python\s+([\/|\w|\s]+Titanium)[^\d]+([\d\.]+).*"([\d\.]+)"/

matches = result.scan(regex)

if matches != nil then
  puts %{@titanium_path = "#{matches[0][0]}"}
  puts %{@tim_version = "#{matches[0][1]}"}
  puts %{@ios_version = "#{matches[0][2]}"}
else
  puts %{You don't have any build/run process running.}
end
