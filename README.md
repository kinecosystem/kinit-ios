# kinit-app-ios
This repository hosts the code for the Kinit iOS app.
Kin is set out to change the digital world and the way people experience and exchange value online. 
Kinit is a mobile app with a standalone Kin experience. For more info about the app, you are welcome to read 
[Kinit Beta App and the Lean Startup approach](https://medium.com/inside-kin/kinit-beta-app-and-the-lean-startup-approach-71bc81937f5).


## Build
Our code is open source, however some information such as api keys are not included so you won't be able to build a working version of the Kinit app on your own.
You are welcome though to read through the code and use it as an example to build your own app using the KIN token.

## Integration with kin-core SDK
We use the [kin-core-ios](https://github.com/kinecosystem/kin-core-ios) SDK to create a KIN wallet for users, 
check for balance and create spending transactions (either to pay KIN for an offer or to transfer KIN to a friend).
The Kinit private beta is working over the Stellar public testnet. We will move over to the Kin public blockchain 
(Stellar fork) for our public beta which is planned in mid July.

## Guide
1 - Install [SwiftGen](https://github.com/SwiftGen/SwiftGen), [SwiftLint](https://github.com/Realm/SwiftLint) and [Sourcery](https://github.com/krzysztofzablocki/Sourcery) via [Homebrew](https://brew.sh):
`brew install sourcery swiftgen swiftlint`.

2 - Initialize submodules with `git submodule init && git submodule update --recursive`. The Kin SDK also has its own submodules, so this step is required inside `Submodules/KinCore/KinSDK` and StellarKit as well.
