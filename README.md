# Blockchain Wallet for iOS

![Banner](Documentation/Other/github_banner.png)
![GitHub last commit](https://img.shields.io/github/last-commit/blockchain/My-Wallet-V3-iOS.svg)
![GitHub pull requests](https://img.shields.io/github/issues-pr/blockchain/My-Wallet-V3-iOS.svg)

# Building

## Install Xcode

After installing Xcode, open it to begin the Command Line Tools installation. After finished, make sure that a valid CL Tool version is selected in `Xcode > Preferences > Locations > Command Line Tools`.


## Install `homebrew`

https://brew.sh/

## Install Git submodules

    $ git submodule update --init

## Install JS Dependencies

Install a node version manager such as [nvm](https://github.com/creationix/nvm) or [n](https://github.com/tj/n).

    # Install Yarn dependency
    $ brew install yarn

    # Install/Use node v7.9.0
    $ npm install -g n
    $ n v7.9.0

    # Use npm 5.6.0
    $ npm install -g npm@5.6.0

    # Checkout ios branch from Submodules/My-Wallet-V3
    $ cd Submodules/My-Wallet-V3
    $ git checkout ios
    $ cd ../..


    # Install and build js files
    $ sh scripts/install-js.sh && sh scripts/build-js.sh

## Prepare OpenSSL

    $ cd ./Submodules/OpenSSL-for-iPhone
    $ ./build-libssl.sh --cleanup --archs="x86_64 arm64"

## Install Ruby dependencies

Install a Ruby version manager such as [rbenv](https://github.com/rbenv/rbenv).

    $ brew update && brew install rbenv
    $ rbenv init

Install a recent ruby version:

    $ rbenv install 2.6.5
    $ rbenv global 2.6.5

Then the project ruby dependencies (`fastlane`, etc.):

    $ gem install bundler
    $ bundle install

## Install build dependencies (brew)

    $ sh scripts/install-brew-dependencies.sh

## Bootstrap Carthage Dependencies

To workaround a error when bootstraping Firebase dependencies, use this custom script:

    $ sh scripts/carthage-bootstrap.sh

## Add production Config file

Clone `wallet-ios-credentials` repository and copy it's `Config` directory to this project root directory, it contains a `.xcconfig` for each environment:
```
Config/BlockchainConfig/Dev.xcconfig
Config/BlockchainConfig/Production.xcconfig
Config/BlockchainConfig/Staging.xcconfig
Config/NetworkKitConfig/Dev.xcconfig
Config/NetworkKitConfig/Production.xcconfig
Config/NetworkKitConfig/Staging.xcconfig
```

This is how `BlockchainConfig/Production.xcconfig` looks like:
```
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon
OPENSSL_CERT_URL = blockchain.info
```

This is how `NetworkKitConfig/Production.xcconfig` looks like:
```
API_URL = api.blockchain.info
BUY_WEBVIEW_URL = blockchain.info/wallet/#/intermediate
COINIFY_URL = app-api.coinify.com
EXCHANGE_URL = exchange.blockchain.com
EXPLORER_SERVER = blockchain.com
RETAIL_CORE_SOCKET_URL = ws.blockchain.info/nabu-gateway/markets/quotes
RETAIL_CORE_URL = api.blockchain.info/nabu-gateway
WALLET_SERVER = blockchain.info
WEBSOCKET_SERVER = ws.blockchain.info/inv
WEBSOCKET_SERVER_BCH = ws.blockchain.info/bch/inv
WEBSOCKET_SERVER_ETH = ws.blockchain.info/eth/inv
```
## Add Firebase Config Files

Clone `wallet-ios-credentials` repository and copy it's `Firebase` directory into `Blockchain` directory, it contains a `GoogleService-Info.plist` for each environment.
```
Firebase/Dev/GoogleService-Info.plist
Firebase/Prod/GoogleService-Info.plist
Firebase/Staging/GoogleService-Info.plist
```

## XcodeGen

### Installing:

    $ brew install xcodegen

### Generate projects:

We are integrating XcodeGen and, despite still committing project files in git, we should generate project files using the following script:

    $ sh scripts/generate_projects.sh

## Open the project in Xcode

    $ open Blockchain.xcworkspace

## Build the project

    cmd-r

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

For a full list of supported types, see [.changelogrc](https://github.com/blockchain/My-Wallet-V3-iOS/blob/dev/.changelogrc#L6...L69).

# License

Source Code License: LGPL v3

Artwork & images remain Copyright Blockchain Luxembourg S.A.R.L

# Security

Security issues can be reported to us in the following venues:
* Email: security@blockchain.info
* Bug Bounty: https://hackerone.com/blockchain
