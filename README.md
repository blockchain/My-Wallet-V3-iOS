# My-Wallet-V3-iOS

# Building

## Install Git submodules

    git submodule update --init

## Install JS Dependencies

Install a node version manager such as [nvm](https://github.com/creationix/nvm) or [n](https://github.com/tj/n).
    
    # use node v7.9.0
    npm install -g n
    n v7.9.0

    # use npm 5.6.0
    npm install -g npm@5.6.0

    # install and build js files
    sh scripts/install-js.sh && sh scripts/build-js.sh

    # build js files, watch My-Wallet-V3 for changes
    sh scripts/watch-js.sh

## Prepare OpenSSL

    cd ../OpenSSL-for-iPhone
    ./build-libssl.sh

## Install Cocoapods
`sudo gem install cocoapods`

## Install Dependencies
`pod install`

## Add production Config file

    #create a directory named Config in the root
    mkdir Config

    #create the config file
    vi Production.xcconfig

    #write the following in Production.xcconfig
    APP_NAME = Blockchain

    APP_ICON = AppIcon

    API_URL = api.blockchain.info

    WALLET_SERVER = blockchain.info

    WEBSOCKET_SERVER = ws.blockchain.info/inv

    WEBSOCKET_SERVER_BCH = ws.blockchain.info/bch/inv

    WEBSOCKET_SERVER_ETH = ws.blockchain.info/eth/inv

    BUY_WEBVIEW_URL = blockchain.info/wallet/#/intermediate

    LOCAL_CERTIFICATE_FILE = blockchain

    GCC_PREPROCESSOR_DEFINITIONS = DEBUG=1 COCOAPODS=1

    OTHER_SWIFT_FLAGS = -DDEBUG
    
    RETAIL_CORE_URL = api.dev.blockchain.info/nabu-app

## Add Config to Pods
    In XCode, Go to Pods folder
    open corresponding .xcconfig
    
    Add the contents of the above .xcconfig file to the end of `Pods/Target Support Files/Pods-Blockchain/Pods-Blockchain.xcconfig`
    
## Open the project in Xcode

    open Blockchain.xcworkspace

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
