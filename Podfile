# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'SubwayWhen' do

def requisite
 
pod 'RxAlamofire'
pod 'RxSwift', '6.5.0' 
pod 'RxCocoa', '6.5.0'
pod 'RxDataSources'
pod 'RxOptional'

pod 'Alamofire'
end


  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SubwayWhen

requisite

pod 'Then'
pod 'SnapKit', '~> 5.7.0'
pod 'lottie-ios'
pod 'AcknowList'
 
pod 'Firebase/Analytics'
pod 'Firebase/Database'

target 'SubwayWhenNetworking' do
  use_frameworks!

requisite

end

target 'SubwayWhenHomeWidgetExtension' do
  use_frameworks!

pod 'RxDataSources'

end

	target 'SubwayWhenTests' do
	inherit! :search_paths
	# Pods for testing
	pod 'Nimble'
	pod 'RxBlocking'
	pod 'RxTest'

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end

installer.pods_project.targets.each do |target|
    if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
      target.build_configurations.each do |config|
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
  end
end




end
end
