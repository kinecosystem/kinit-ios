# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

def add_kin_sdk
  pod 'KinSDK', :git => 'https://github.com/kinecosystem/kin-sdk-ios', :branch => 'link-wallets'
end

target 'KinWallet' do
  use_frameworks!

  pod 'Firebase/Auth'
  pod 'libPhoneNumber-iOS'
  pod 'KinMigrationModule', :git => 'https://github.com/kinecosystem/kin-migration-module-ios', :branch => 'kinnovation'
  add_kin_sdk
  #pod 'MoveKin', :path => '/Users/natan/Documents/Kik/MoveKin'

  # Pods for KinWallet

  target 'OneWalletExtension' do
    inherit! :search_paths
    add_kin_sdk
  end

  target 'KinWalletTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'KinWalletUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
