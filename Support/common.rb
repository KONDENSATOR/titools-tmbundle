#(c) Copyright 2010 Fredrik Andersson Kondensator AB. All Rights Reserved.

require 'readline'

def perform(text) 
  start = Time.now
  print text
  yield 
  puts " [in %0.2fs]" % (Time.now - start)
end

def if_fail_perform(text, f) 
  start = Time.now
  if f.call() == false
    print text 
  else
    puts " [in %0.2fs]" % (Time.now - start)
  end
end

def yn_question(question)
  list = [
    'yes', 'no'
  ].sort
  
  comp = proc { |s| list.grep( /^#{Regexp.escape(s)}/ ) }
  Readline.completion_proc = comp
  answer = ""
  while answer != "y" and answer != "n"
    answer = Readline.readline(question, false)
  end
end

def append_file(file, text)
  open(file, 'a') do |f|
    f.puts text
  end
end

def with_ensured_path(path)
  puts "Ensuring path (#{path})"
  if !File.exists?(path)
    puts "Creating path (#{path})"
    File.makedirs path
    yield path
  end
end

def run(cmd)
  puts "Running (#{cmd})"
  system cmd
end

# @valid_args << :id => :client, :match => "client=", :question => "Client company name: ", :description => ""
#             << :id => :project, :match => "project=", :question => "Project name: ", :description => ""
#             << :id => :platform, :match => "platform=", :question => "Platform name: ", :description => ""
#             << :id => :name, :match => "name=", :description => "", :is_default => true

def take_args(valid_args)
  result = {}
    
  ARGV.each { |a| 
    valid_args.each { |arg| 
      id, match, question, description = arg[:id], arg[:match], arg[:question], arg[:description]
      result[id] = a.gsub(/^#{match}/, "") if a.match(/^#{match}/) 
      }
    }
  
  default = valid_args.select { |i| i[:is_default] }
  
  result[default] = ARGV.join(" ") if result.length == 0 and default
  
  return result
end

def take_input(args, requested)
  requested.each do arg
    args[arg[:id]] = Readline.readline(arg[:question], true) if !args[arg[:id]]
  end
	return args
end

def help?
  ARGV.each do|a|
    if /^help/.match(a) 
      return true
    end
  end
  return false
end

def project_name(client, project, platform)
  return "#{client}#{@separator}#{project}#{@separator}#{platform}"
end
def with_dir(path)
  current_dir = Dir.pwd
  begin
    Dir.chdir path
    yield    
  ensure
    Dir.chdir current_dir
  end  
end
def find_path_with_child(path, child)
  return path if File.directory?(File.join(path, child))
  
  folders = path.split('/')
  
  return nil if folders.length <= 1
  
  folders = folders[0, folders.length-1]
  
  return find_path_with_child(folders.join('/'), child)
end