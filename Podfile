# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'KinWallet' do
  use_frameworks!

  pod 'Firebase/Auth'
  pod 'libPhoneNumber-iOS'
  pod 'KinMigrationModule', :git => 'https://github.com/kinecosystem/kin-migration-module-ios', :branch => 'fix-migrate-URL'
  pod 'KinSDK', :git => 'https://github.com/kinecosystem/kin-sdk-ios', :branch => 'fix-appId-length'
  #pod 'MoveKin', :path => '/Users/natan/Documents/Kik/MoveKin'

  # Pods for KinWallet

  target 'KinWalletTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'KinWalletUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
