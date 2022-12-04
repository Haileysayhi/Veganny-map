# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Veganny Map' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GoogleMaps
pod 'GoogleMaps'
pod 'GooglePlaces' 
pod 'Google-Maps-iOS-Utils' 

  # Pods for SwiftLint
pod 'SwiftLint'
 
  # Pods for FloatingPanel
pod 'FloatingPanel'

  # Pods for IQKeyboardManagerSwift
pod 'IQKeyboardManagerSwift'

  # Pods for Firebase
pod 'Firebase/Firestore'
pod 'Firebase/Core'
pod 'FirebaseFirestoreSwift'
pod 'Firebase/Storage'
pod 'Firebase/Auth'
pod 'Firebase/Crashlytics'
pod 'Firebase/Analytics'

  # Pods for Kingfisher
pod 'Kingfisher'

  # Pods for SPAlert
pod 'SPAlert'

  # Pods for JGProgressHUD
pod 'JGProgressHUD'


  # Pods for lottie-ios
pod 'lottie-ios'


  # Pods for MJRefresh
pod 'MJRefresh'

  # Pods for SwiftJWT
pod 'SwiftJWT'

  # Pods for KeychainSwift
pod 'KeychainSwift', '~> 20.0'

  # Pods for Floating Button
pod 'MaterialComponents/Buttons'

pod 'MDFInternationalization'

post_install do |installer|
installer.pods_project.targets.each do |target|
target.build_configurations.each do |config|
config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
end
end
end


end
