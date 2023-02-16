# Blockchain Wallet for iOS

![Banner](Documentation/Other/github_banner.png)
![GitHub last commit](https://img.shields.io/github/last-commit/blockchain/My-Wallet-V3-iOS.svg)
![GitHub pull requests](https://img.shields.io/github/issues-pr/blockchain/My-Wallet-V3-iOS.svg)

# Tooling

Homebrew: 3.4.1+
Xcode: 13.2.1+
Ruby: 2.6.9
Ruby-Gems: 3.0.3
Swiftlint: 0.46.5+
Swiftformat: 0.49.5+

If you are using a M1 you might need to update ruby to version 2.7.5 or 3.x.x. Postponing the upgrade now so we don't disturb the current builds until the CI is updated to M1 and everybody get their M1s.

# Building

## Install Xcode

After installing Xcode, open it to begin the Command Line Tools installation. After finished, make sure that a valid CL Tool version is selected in `Xcode > Preferences > Locations > Command Line Tools`.

## Install `homebrew`

https://brew.sh/

## Install Ruby dependencies

Install a Ruby version manager such as [rbenv](https://github.com/rbenv/rbenv).

    $ brew update && brew install rbenv
    $ rbenv init

Install a recent ruby version:

    $ rbenv install 2.6.9
    $ rbenv global 2.6.9
    $ eval "$(rbenv init -)"
    
For M1 use this:
    $ rbenv install 2.7.6
    $ rbenv global 2.7.6
    $ eval "$(rbenv init -)"

Then the project ruby dependencies (`fastlane`, etc.):

    $ gem install bundler
    $ bundle install

## Install build dependencies (brew)

    $ sh scripts/install-brew-dependencies.sh

## Add production Config file

Clone the [wallet-ios-credentials](https://github.com/blockchain/wallet-ios-credentials) repository and copy it's `Config` directory to this project root directory, it contains a `.xcconfig` for each environment:

```
Config/BlockchainConfig/Dev.xcconfig
Config/BlockchainConfig/Production.xcconfig
Config/BlockchainConfig/Staging.xcconfig
Config/BlockchainConfig/Alpha.xcconfig
Config/NetworkKitConfig/Dev.xcconfig
Config/NetworkKitConfig/Production.xcconfig
Config/NetworkKitConfig/Staging.xcconfig
Config/NetworkKitConfig/Alpha.xcconfig
```

For example, This is how `BlockchainConfig/Production.xcconfig` looks like:

```
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon
OPENSSL_CERT_URL = blockchain.info
```

For example, This is how `NetworkKitConfig/Production.xcconfig` looks like:

```
API_URL = api.blockchain.info
EXCHANGE_URL = exchange.blockchain.com
EXPLORER_SERVER = blockchain.com
RETAIL_CORE_URL = api.blockchain.info/nabu-gateway
WALLET_SERVER = blockchain.info
WEBSOCKET_SERVER = ws.blockchain.info
```

## Add Firebase Config Files

Clone `wallet-ios-credentials` repository and copy it's `Firebase` directory into `Blockchain` directory, it contains a `GoogleService-Info.plist` for each environment.

```
Firebase/Dev/GoogleService-Info.plist
Firebase/Prod/GoogleService-Info.plist
Firebase/Staging/GoogleService-Info.plist
Firebase/Alpha/GoogleService-Info.plist
```

## Add environment variables for scripts

Clone `wallet-ios-credentials` repository and copy the `env` to the root folder of the project, hide the file by using `mv env .env`

## XcodeGen

We are integrating XcodeGen and, despite still committing project files in git, we should generate project files using the following script:

### Installing:

    $ brew install xcodegen

## Generate projects & dependencies: 

    $ sh scripts/bootstrap.sh

👉 Beware that this will take a while. Feel free to read some docs, a 📖, get a ☕, or go for a 🚶 while it runs…

⚠️ You may need to run the following command if you encounter an `xcode-select` error:

    $ sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

## Build the project

    cmd-r

# Modules

Please refer to the [README](./Modules/README.md) in the `Modules` directory.
Please also refer to the [README](./TestKit/README.md) in the `TestKit` directory.

# Contributing

If you would like to contribute code to the Blockchain iOS app, you can do so by forking this repository, making the changes on your fork, and sending a pull request back to this repository.

When submitting a pull request, please make sure that your code compiles correctly and all tests in the `BlockchainTests` target passes. Be as detailed as possible in the pull request’s summary by describing the problem you solved and your proposed solution.

Additionally, for your change to be included in the subsequent release’s change log, make sure that your pull request’s title and commit message is prefixed using one of the changelog types.

The pull request and commit message format should be:

```
<changelog type>(<component>): <brief description>
```

For example:

```
fix(Create Wallet): Fix email validation
```

For a full list of supported types, see [.changelogrc](https://github.com/blockchain/My-Wallet-V3-iOS/blob/master/.changelogrc#L6...L69).

# License

Source Code License: LGPL v3

Artwork & images remain Copyright Blockchain Luxembourg S.A.R.L

# Security

Security issues can be reported to us in the following venues:
* Email: security@blockchain.info
* Bug Bounty: https://hackerone.com/blockchain
