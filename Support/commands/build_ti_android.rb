require 'fileutils'
$tm_bundle_support_path = "#{ENV['TM_BUNDLE_SUPPORT']}" if $tm_bundle_support_path == nil

require $tm_bundle_support_path + '/common/ti_tools'

class BuildTiAndroid
  attr_accessor :project
  
  def self.perform(text) 
    start = Time.now
    print text
    yield 
    puts "I/Building( 0): (Building) [0,0] (in %0.2fs)" % (Time.now - start)
  end
  
  def self.unpack_android_manifest_file(file) 
    {
      # Android intent, Find in AndroidManifest file
      :intent   => File.open(file).select { |intent| intent =~ /intent.action/}.to_s.gsub('<action android:name="', '').gsub('" />', '').strip,
      # Intent category, Find in AndroidManifest file
      :category => File.open(file).select { |category| category =~ /intent.category/}.to_s.gsub('<category android:name="', '').gsub('" />', '').strip,  
      # Package name. Find in AndroidManifest file
      :package  => File.open(file).select { |package| package =~ /package=/}.to_s.gsub('package="', '').gsub('"', '').strip,                             
      # Action class name. Find in AndroidManifest file
      :action   => File.open(file).select { |action| action =~ /name="\./}.to_s.gsub('android:name="', '').gsub('"', '').strip,
    }
  end
  def self.android_manifest_file(project)
    return File.join(project.android_build_root, "AndroidManifest.xml")
  end
  def self.prep_tmp_android(resource_root, tmp_root)
    FileUtils.mkdir_p("#{tmp_root}/assets")
    FileUtils.cp_r(resource_root, "#{tmp_root}/assets/")

    android_root = "#{tmp_root}/assets/Resources/android/"

    Dir.foreach(android_root) do |item|
      item = android_root + item
      if File.file?(item)
        FileUtils.cp(item, "#{tmp_root}/assets/Resources/")
      end
    end

    FileUtils.remove_dir("#{tmp_root}/assets/Resources/android")
    FileUtils.remove_dir("#{tmp_root}/assets/Resources/iphone")
  end
  def self.update_unsigned(tmp_root, appunsigned)
    current_path = File.expand_path('.')
    %x[cd '#{tmp_root}' && zip -r '#{appunsigned}' assets/Resources/\*] 
    %x[cd '#{current_path}']
  end
  def self.run_android(manifest)
    adb = TiTools::config['adb']
    
    # Run app on device by executing am on the device shell
    puts %x['#{adb}' shell am start -a #{manifest[:intent]} -c #{manifest[:category]} -n #{manifest[:package]}/#{manifest[:action]}]
  end

  def self.install_android(appapk)
    adb = TiTools::config['adb']
    
    # Added ''-wrapping of .apk files path
    puts %x['#{adb}' install -r '#{appapk}']
  end

  def self.sign_android(titanium_path, tim_version, appapk, appunsigned)
    # Added ''-wrapping of .apk files paths 
    puts %x[jarsigner -storepass tirocks -keystore '#{titanium_path}/mobilesdk/osx/#{tim_version}/android/dev_keystore' -signedjar '#{appapk}' '#{appunsigned}' tidev]
  end
  def self.devices_available()
    adb = TiTools::config['adb']
    cmd = "'#{adb}' devices"
    result = %x{#{cmd}}
    
    rows = result.split("\n")
    
    rows.delete_at(0)

    result = []

    rows.each do |row|
      itms = row.split("\t")
      result << { :name => itms[0], :status => itms[1] }
    end

    return result
  end
  def self.logcat(clear_log = false)
    adb = TiTools::config['adb']

    %{'#{adb}' logcat -c} if clear_log
    
    IO.popen("'#{adb}' logcat") do |chunk|
        chunk.each { |line| puts line }
    end
  end
  
  def self.compile_install_run(titanium_path, tim_version, project, bin_unsigned, appapk, manifest)
    perform("I/Building( 0): (Building) [0,0] deleting lingering temp directory") { 
      FileUtils.remove_dir(project.project_tmp_root) 
    } if File.directory?(project.project_tmp_root) 
      
    perform("I/Building( 0): (Building) [0,0] preparing temp directory") { 
      BuildTiAndroid::prep_tmp_android(project.resources_root, project.project_tmp_root) 
    }
      
    perform("I/Building( 0): (Building) [0,0] updating apk-unsigned (#{bin_unsigned})") { 
      BuildTiAndroid::update_unsigned(project.project_tmp_root, bin_unsigned) 
    }  
      
    perform("I/Building( 0): (Building) [0,0] deleting temp directory") { 
      FileUtils.remove_dir(project.project_tmp_root) 
    }
      
    perform("I/Building( 0): (Building) [0,0] signing apk file") { 
      BuildTiAndroid::sign_android(titanium_path, tim_version, appapk, bin_unsigned) 
    }

    devices = BuildTiAndroid::devices_available()
    
    if devices.length <= 0
      puts "I/Building( 0): (Building) [0,0] error installing and running - device not found"
    else
      devices.each { |device| puts("I/Building( 0): (Building) [0,0] found device '#{device[:name]}' status: #{device[:status]}") }

      perform("I/Building( 0): (Building) [0,0] installing apk onto device")      { BuildTiAndroid::install_android(appapk) }
      perform("I/Building( 0): (Building) [0,0] starting application on device")  { BuildTiAndroid::run_android(manifest) }

      BuildTiAndroid::logcat(true)
    end    
  end
  
  def initialize()
    STDOUT.sync = true

    @project = TiTools.new()
    
    # Expand paths so that we get full path to file
    @appapk = File.expand_path("#{@project.android_build_root}/bin/app.apk")
    @appunsigned = File.expand_path("#{@project.android_build_root}/bin/app-unsigned.apk")
    @manifest = BuildTiAndroid::unpack_android_manifest_file(BuildTiAndroid::android_manifest_file(@project))
  end
  
  def run(config)
    BuildTiAndroid::compile_install_run(
      config['titanium_path'],
      config['tim_version'],
      @project, @appunsigned, @appapk, @manifest)
  end
end


if __FILE__ == $0
  builder = BuildTiAndroid.new()
  
  builder.run(TiTools::config)
end
