# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

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
# 7.6.2 fixes the KFImageRenderer conditional-binding error without a major upgrade.
pod 'Kingfisher', '7.6.2'

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
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end

    # BoringSSL-GRPC 0.0.24 passes this warning setting as a compiler option.
    # Newer Clang parses its leading "-G" as an unsupported target flag.
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        next unless file.settings && file.settings['COMPILER_FLAGS']

        flags = file.settings['COMPILER_FLAGS'].split
        flags.delete('-GCC_WARN_INHIBIT_ALL_WARNINGS')
        file.settings['COMPILER_FLAGS'] = flags.join(' ')
      end
    end
  end

  # FirebaseFirestore 9.6.0 places ABSL_CONST_INIT before an extern "C"
  # declaration, which newer Clang versions reject. The attribute is only a
  # compile-time initialization check, so removing it does not change the ABI.
  firestore_settings = File.join(
    installer.sandbox.root.to_s,
    'FirebaseFirestore/Firestore/Source/API/FIRFirestoreSettings.mm'
  )
  if File.exist?(firestore_settings)
    source = File.read(firestore_settings)
    patched_source = source.sub(
      'ABSL_CONST_INIT extern "C" const int64_t',
      'extern "C" const int64_t'
    )
    if patched_source != source
      original_mode = File.stat(firestore_settings).mode
      begin
        File.chmod(original_mode | 0200, firestore_settings)
        File.write(firestore_settings, patched_source)
      ensure
        File.chmod(original_mode, firestore_settings)
      end
    end
  end
end


end
