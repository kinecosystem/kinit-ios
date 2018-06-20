fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios test_fairy
```
fastlane ios test_fairy
```
Submits a new build to TestFairy
### ios test_flight
```
fastlane ios test_flight
```
Submits a new build to TestFlight
### ios app_store
```
fastlane ios app_store
```
Submits a new build to the App Store
### ios release_build
```
fastlane ios release_build
```
Builds a release build under the Kin Ecosystem account

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
