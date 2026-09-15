source 'https://repo.veryfi.com/shared/lens/veryfi-lens-podspec.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'VeryfiLensHeadless-CreditCards' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'VeryfiLensHeadless-CreditCards', '3.0.18.3'
  # Pods for VeryfiLensHeadless-CreditCards

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
