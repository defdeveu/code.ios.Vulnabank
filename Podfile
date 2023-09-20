platform :ios, '12.0'

target 'vulnabankIOs' do
  use_frameworks!
  # Pods for vulnabankIOs
  pod 'XMLCoder', '~> 0.9.0'
  pod 'SwiftyRSA', '~> 1.5'
  pod 'CryptoSwift', '~> 1.3'
  pod 'Swinject'
  post_install do |installer|
    installer.pods_project.targets.each do |target|
              target.build_configurations.each do |config|
                    # config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
                    config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
                    config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
                    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
              end
      end
  end
end
