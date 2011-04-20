$tm_bundle_support_path = "#{ENV['TM_BUNDLE_SUPPORT']}" if $tm_bundle_support_path == nil

require $tm_bundle_support_path + '/common/jsl_tools'
require $tm_bundle_support_path + '/common/ti_texts'

if __FILE__ == $0
  result = JslTools::run_jsl(ENV['TM_FILEPATH'])

  puts jsl_document_tmplate(result[:errors], result[:warnings])
end
