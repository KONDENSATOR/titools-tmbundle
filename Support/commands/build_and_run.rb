# Override paths (FOR DEBUGING ONLY)
$tm_bundle_support_path = File.expand_path("~/Library/Application Support/TextMate/Bundles/ti-tools.tmbundle/Support")
$tm_project_path = File.expand_path("~/gitrep/smtg-journal-mobile/Resources")

require $tm_bundle_support_path + '/common/ti_tools'
require $tm_bundle_support_path + '/common/ti_texts'


class TiBuild
  attr_accessor :project
  
  def initialize()
    @project = TiTools.new()
    @parsers = {
      "desktop" => js_parse_desktop,
      "iphone" => js_parse_ios,
      "ipad" => js_parse_ios,
      "android" => js_parse_android
    }
  end

  def validate_project()
    text_project_path_error if @project.project_root == nil
  end
  
  def build_ti()
    platform = @project.platform()
    build_cmd = @project.build_ti()    
    
    document_template(
      [TiTools::jquery_include, TiTools::prettify_js_include, TiTools::mate_console_js_include], 
      [TiTools::prettify_css_include], 
      build_cmd,
      @parsers[platform]
      )
  end
end

if __FILE__ == $0
  build = TiBuild.new()
  
  if validation = build.validate_project 
    puts validation
    
    exit(255)
  end
  
  puts build.build_ti()
end
