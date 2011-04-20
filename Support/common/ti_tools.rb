require 'yaml'
require 'rexml/document'

# Do this to accuire this functionality
# require ENV['TM_BUNDLE_SUPPORT'] + '/common/ti_tools'
$tm_bundle_support_path = "#{ENV['TM_BUNDLE_SUPPORT']}" if $tm_bundle_support_path == nil
$tm_project_path = "#{ENV["TM_PROJECT_DIRECTORY"]}" if $tm_project_path == nil

class Common
  # The textmate bundle support path
  def self.support_path()
    $tm_bundle_support_path 
  end
  # The textmate project path. This is the root folder visible in "Project Drawer".
  def self.project_path()
    $tm_project_path
  end
  
  # Traverse the directory tree to find the root of given folder.
  def self.find_root_of(file, dir)
    return nil if dir == nil 

    f = File.join(dir, file)

    return dir if File.exist?(f)
    return Common::find_root_of(file, File.expand_path("..", dir))
  end
end

class TiTools
  # The configuration file
  def self.config()
    YAML::load( File.open( "#{Common::support_path}/config.yaml" ) )
  end
  # The path to jquery
  def self.jquery_include()
    "#{Common::support_path}/external/jquery-1.5.2.min.js"
  end
  # The path to prettify javascript
  def self.prettify_js_include()
    "#{Common::support_path}/external/prettify/prettify.js"
  end
  # The path to mate_console javascript
  def self.mate_console_js_include()
    "#{Common::support_path}/common/mate_console.js"
  end
  # The path to prettify css
  def self.prettify_css_include()
    "#{Common::support_path}/external/prettify/prettify.css"
  end
  # The path to jsl command
  def self.jsl_command(file)
    "'#{Common::support_path}/external/jsl-0.3.0-mac/jsl' -conf '#{Common::support_path}/jsl.conf' -process '#{file}'"
  end
  
  # Build command for titanium desktop
  def self.build_ti_desktop(config, project)
    "python '#{config['titanium_path']}/sdk/osx/#{config['tid_version']}/tibuild.py' -d '#{project.project_root}/dist/osx' -a '#{config['titanium_path']}/sdk/osx/#{config['tid_version']}' -n -r -v -s '#{config['titanium_path']}' '#{project.project_root}'"
  end
  # Build command for titanium iOS
  def self.build_ti_ios(config, project)
    "python '#{config['titanium_path']}/mobilesdk/osx/#{config['tim_version']}/iphone/builder.py' simulator '#{config['ios_version']}' '#{project.project_root}' #{project.app_id} '#{project.app_name}' #{config['mobile_target']}"
  end
  # Build command for titanium android
  def self.build_ti_android(config, project)
    "ruby '#{Common::support_path}/commands/build_ti_android.rb' '#{project.project_root}'"
  end
  
  attr_accessor :app_id
  attr_accessor :app_name
  attr_accessor :app_is_desktop
  attr_accessor :project_root_path

  # Fetch real project root. This is where titanium keeps the tiapp.xml-file
  def project_root()
    return @project_root_path if @project_root_path
    
    @project_root_path = Common::find_root_of("tiapp.xml", Common::project_path)
  end
  # Path to resources folder. This is where javascript files is among other things.
  def resources_root()
    "#{project_root}/Resources"
  end
  # Path to build root folder. This is where android and iphone binaries end up.
  def build_root()
    "#{project_root}/build"
  end
  # Path to android build root folder.
  def android_build_root()
    "#{build_root}/android"
  end
  # Path to iphone build root folder
  def iphone_build_root()
    "#{build_root}/iphone"
  end
  # Project temp folder
  def project_tmp_root()
    "#{project_root}/tmp"
  end
  # Read project tiapp.xml
  def project_properties()
    xml_file = File.join(project_root, 'tiapp.xml')
    tiapp_xml = REXML::Document.new(File.new(xml_file)).root
    
    { 
      :id => tiapp_xml.elements['id'].first.to_s,
      :name => tiapp_xml.elements['name'].first.to_s,
      :desktop => tiapp_xml.elements['url'].first.to_s.start_with?('app:')
      }
  end

  def platform(config = TiTools::config())
    return 'desktop' if @app_is_desktop
    return mtarget = config["mobile_target"]
  end
  
  # Build project for desired platform
  def build_ti(config = TiTools::config())
    mtarget = config["mobile_target"]

    builders = {
      "desktop" => lambda { TiTools::build_ti_desktop(config, self) },
      "iphone" => lambda { TiTools::build_ti_ios(config, self) },
      "ipad" => lambda { TiTools::build_ti_ios(config, self) },
      "android" => lambda { TiTools::build_ti_android(config, self) }
    }
    
    builders[mtarget].call
  end
  
  # Initialize TiTools by loading project properties
  def initialize()
    props = project_properties
    
    @app_id = props[:id]
    @app_name = props[:name]
    @app_is_desktop = props[:desktop]
  end
end



# Perform any tests
def test_ti_tools
  puts Common::support_path
  puts Common::project_path
  puts Common::find_root_of('tiapp.xml', Common::project_path)
  
  puts TiTools::config.inspect
  puts TiTools::jquery_include
  puts TiTools::prettify_js_include
  puts TiTools::prettify_css_include
  puts TiTools::jsl_command("#{Common::project_path}/app.js")
  
  ti_tools = TiTools.new()
  
  config = TiTools::config()

  config['mobile_target'] = 'android'
  puts ti_tools.build_ti(config)
  
  config['mobile_target'] = 'iphone'
  puts ti_tools.build_ti(config)

  config['mobile_target'] = 'ipad'
  puts ti_tools.build_ti(config)
  
end

if __FILE__ == $0
  $tm_bundle_support_path = File.expand_path("~/Library/Application Support/TextMate/Bundles/ti-tools.tmbundle/Support")
  $tm_project_path = File.expand_path("~/gitrep/smtg-journal-mobile/Resources")
  
  test_ti_tools
end
