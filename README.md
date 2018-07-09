# My-Wallet-V3-iOS


# Building

## Setup git submodules

Prepare SocketRocket:

    git submodule update --init

Prepare the MyWallet Javascript:

    # use node v7.9.0 by using a node version manager such as NVM or n
    npm install -g n
    n v7.9.0

    # use npm 5.6.0
    npm install -g npm@5.6.0

    # install and build js files
    sh scripts/install-js.sh && sh scripts/build-js.sh

    # build js files, watch My-Wallet-V3 for changes
    sh scripts/watch-js.sh

Prepare OpenSSL:

    cd ../OpenSSL-for-iPhone
    ./build-libssl.sh

## Open the project in Xcode

    open Blockchain.xcodeproj

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
