# Kin Wallet iOS

Kin iOS application with earn/spend capabilities

# Guide

1 - Install [SwiftGen](https://github.com/SwiftGen/SwiftGen), [SwiftLint](https://github.com/Realm/SwiftLint) and [Sourcery](https://github.com/krzysztofzablocki/Sourcery) via [Homebrew](https://brew.sh):
`brew install sourcery swiftgen swiftlint`.

2 - Initialize submodules with `git submodule init && git submodule update --recursive`. The Kin SDK also has its own submodules, so this step is required inside `Submodules/KinCore/KinSDK` and StellarKit as well.
