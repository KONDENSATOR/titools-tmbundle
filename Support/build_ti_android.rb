require ENV['TM_BUNDLE_SUPPORT'] + '/common_build_titanium'
require ENV['TM_BUNDLE_SUPPORT'] + '/config'
require ENV['TM_BUNDLE_SUPPORT'] + '/find_variables'


# this line makes our prints, print directly
STDOUT.sync = true

exit(255) if ARGV.length == 0

# Setting up variables
project_root = ARGV[0]
resource_root = "#{project_root}/Resources"

puts project_root

# Expand paths so that we get full path to file
appapk = File.expand_path("#{project_root}/build/android/bin/app.apk")
appunsigned = File.expand_path("#{project_root}/build/android/bin/app-unsigned.apk")

# Fetching package info from AndroidManifest file
manifest = unpack_android_manifest_file(android_manifest_file(project_root))

perform("[Info] deleting lingering temp directory")      { FileUtils.remove_dir("#{project_root}/tmp") } if File.directory?("#{project_root}/tmp") 
perform("[Info] preparing temp directory")               { prep_tmp_android(resource_root, project_root) }
perform("[Info] updating apk-unsigned [#{appunsigned}]") { update_unsigned(project_root, appunsigned) }  
perform("[Info] deleting temp directory")                { FileUtils.remove_dir("#{project_root}/tmp") }
perform("[Info] signing apk file")                       { sign_android(appapk, appunsigned) }

if_fail_perform("[Info] error installing and running - device not found", lambda {
  devices = devices_available()
  if devices.length > 0
    devices.each { |device| puts("[Info] found device '#{device[:name]}' status: #{device[:status]}") }
    perform("[Info] installing apk onto device")             { install_android(appapk) }
    perform("[Info] starting application on device")         { run_android(manifest) }
    
    %x{#{@adb} logcat}
    return true
  end
  return false
})
