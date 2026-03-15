platform :ios, '13.4'

target 'JobTrack' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for JobTrack
  pod 'SwiftCSVExport'
  pod 'Charts', '~> 4.1'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.4'
    end
  end
end
