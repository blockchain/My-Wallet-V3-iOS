# Blockchain Wallet V3 iOS

## 6b9b5ad4f ( Thu Nov 01 2018 20:29:22 GMT-0700 (PDT) )


## Bug Fixes

  - **appcoordinator**
    - show dashboard when backgrounding
  ([dd9a1042](https://github.com/blockchain/My-Wallet-V3-iOS/commit/dd9a1042a964c1c8cf3a8e774ecb721fa3576f66))

  - **appfeature**
    - check if boolean, not nil.
  ([bcbf94e6](https://github.com/blockchain/My-Wallet-V3-iOS/commit/bcbf94e668bd4d928c13ae5ded86d179a5362017))

  - **asset selector**
    - set image tint color
  ([6eb33ac4](https://github.com/blockchain/My-Wallet-V3-iOS/commit/6eb33ac40fb589f3cbcb5f6166aa0ec8e0247e26))

  - **assetaccountrepository**
    - pass StellarAccountAPI into initializer
  ([eadd9291](https://github.com/blockchain/My-Wallet-V3-iOS/commit/eadd92911e9c6a47688b78781b940a5bbd0c3c7a))

  - **assetselectorview**
    - fix direction
  ([966cb0e7](https://github.com/blockchain/My-Wallet-V3-iOS/commit/966cb0e751578baf910dab092947671d85abda7a))

  - **assettypecell**
    - make IBOutlet private
  ([f5de905e](https://github.com/blockchain/My-Wallet-V3-iOS/commit/f5de905e088ac9b4a4f21a958ce74609b1cc2d94))
    - make IBOutlets private
  ([15a59144](https://github.com/blockchain/My-Wallet-V3-iOS/commit/15a5914483e52bea833da4c8fce891adb44c8bd8))

  - **bch**
    - fix unrecognized selector
  ([4fb0b8c1](https://github.com/blockchain/My-Wallet-V3-iOS/commit/4fb0b8c1115c5987ec822c2407d103a1fa76164b))

  - **dashboard**
    - account for XLM balance for zero balances
  ([adc6efd6](https://github.com/blockchain/My-Wallet-V3-iOS/commit/adc6efd6715ed21b6cf88936078f678bc3dd70f6))
    - do not read stellar account from cache
  ([36ba3e92](https://github.com/blockchain/My-Wallet-V3-iOS/commit/36ba3e92f564153a9811dd4ecac6b3ac74c58140))
    - show XLM transactions view when balance legend key tapped
  ([b1474fe5](https://github.com/blockchain/My-Wallet-V3-iOS/commit/b1474fe57d65d60d3d9cb64cc4d97f7265640639))
    - use fiat currency code from settings
  ([e3b64358](https://github.com/blockchain/My-Wallet-V3-iOS/commit/e3b64358fddbef0086bccb0ecf1ba6134aacbfb8))
    - default to day time frame if no object set
  ([172d4c63](https://github.com/blockchain/My-Wallet-V3-iOS/commit/172d4c6325045c9fb965e99679f93c027db70602))
    - include missing value in string format
  ([ca869945](https://github.com/blockchain/My-Wallet-V3-iOS/commit/ca86994553e3f5045d908ff39bd542a29013403a))
    - expose TabBarTab enum to Objective-c
  ([1066f9f7](https://github.com/blockchain/My-Wallet-V3-iOS/commit/1066f9f718517ff3a28fbb7bd7292d979700ec13))
    - use static member horizontalPadding
  ([7b2d2932](https://github.com/blockchain/My-Wallet-V3-iOS/commit/7b2d2932f1c4c3ce8c1b326e2bae9ea16a8bdeba))
    - force unwrap BCPricePreviewView
  ([397598b5](https://github.com/blockchain/My-Wallet-V3-iOS/commit/397598b5a23b6ac05de3ebd6bce0650a41e041e5))
    - add stellar case
  ([96484787](https://github.com/blockchain/My-Wallet-V3-iOS/commit/964847874f8b8544eafc69642127c379b38c57af))
    - use relocated satoshi constant
  ([1b391cb6](https://github.com/blockchain/My-Wallet-V3-iOS/commit/1b391cb6b7a9d33cf3031067a56a7b5598ed2552))

  - **homebrew**
    - fix typo in copy change
  ([e12d0666](https://github.com/blockchain/My-Wallet-V3-iOS/commit/e12d0666f8c53c3356b8a5bfbac85f4b8f2ee0ef))

  - **homebrew-exchange**
    - fix NabuUser and OrderResult models
  ([4589fcc5](https://github.com/blockchain/My-Wallet-V3-iOS/commit/4589fcc541d3510f4f5ad785871e01b16f4758a0))

  - **nabuuser**
    - initialize tags
  ([4a996c0d](https://github.com/blockchain/My-Wallet-V3-iOS/commit/4a996c0db07b63c5e9f0559fc8b2424c8eefc6e1))

  - **number formatter**
    - round down for fiat currency
  ([7561fc75](https://github.com/blockchain/My-Wallet-V3-iOS/commit/7561fc75747d0f5c1652f39e196db1455b0a6f1c))

  - **numberformatter**
    - set maximum decimal places to 7 for stellar
  ([d5a9482d](https://github.com/blockchain/My-Wallet-V3-iOS/commit/d5a9482dc96c7085830d9cbc40b2e9e1641e3061))

  - **numberformattertests**
    - account for rounding down
  ([2452afde](https://github.com/blockchain/My-Wallet-V3-iOS/commit/2452afde3798e868a79df314b5f47f929743e5e1))

  - **project**
    - fix compiler errors
  ([617f31db](https://github.com/blockchain/My-Wallet-V3-iOS/commit/617f31db531fde83c13ccc080f881d06ae68f212))
    - IOS-1514 certificate Pinning | Whitelist doesn't work
  ([5703ca0f](https://github.com/blockchain/My-Wallet-V3-iOS/commit/5703ca0f2857058757482742826bdad8c693b6f6))
    - add StellarPaymentOperation.swift to test target
  ([7aa9f076](https://github.com/blockchain/My-Wallet-V3-iOS/commit/7aa9f0760f19f8e0c22cac34dde84f36ca67035e))
    - fix merge conflict
  ([760e0e07](https://github.com/blockchain/My-Wallet-V3-iOS/commit/760e0e079ca10966f12a016b87ca08735f5b1727))
    - IOS-1514 certificate Pinning | Whitelist doesn't work
  ([1a59c1b8](https://github.com/blockchain/My-Wallet-V3-iOS/commit/1a59c1b8a23495eb67a09181269ba5fd24068a8a))
    - run swiftlint via pod not brew installation
  ([bb94a097](https://github.com/blockchain/My-Wallet-V3-iOS/commit/bb94a097219010f7aff34dd1c92c95a346156a78))
    - correctly set rules for linter
  ([28fa1128](https://github.com/blockchain/My-Wallet-V3-iOS/commit/28fa112820f8ff323ec1c7121cad362f0a8a7760))

  - **sendlumensviewcontroller**
    - update fee label
  ([f9206591](https://github.com/blockchain/My-Wallet-V3-iOS/commit/f920659100906981fe521114f29066aee51fd4a4))
    - fix merge conflicts and set payment operation amount from stored property
  ([78cfcb12](https://github.com/blockchain/My-Wallet-V3-iOS/commit/78cfcb1288af28d5686f04f134c35ed74c46f6ae))
    - set text field delegates and allow conversion
  ([d49d5453](https://github.com/blockchain/My-Wallet-V3-iOS/commit/d49d5453d6e30c8613ee01203d65463f686e1193))
    - set model properties to private
  ([a1c18861](https://github.com/blockchain/My-Wallet-V3-iOS/commit/a1c18861fec1aa263c8398e7159bd1ba7a8e1670))

  - **sendxlmcoordinator**
    - calculate fee with NSDecimalNumber operations
  ([2fd2fcfa](https://github.com/blockchain/My-Wallet-V3-iOS/commit/2fd2fcfa952ed32baa4d3318c0520ebe71a9e50b))
    - use error label text update instead of alert
  ([ddcd58ca](https://github.com/blockchain/My-Wallet-V3-iOS/commit/ddcd58cadb1c4586e5ad6ef03fed83cb1ab27551))
    - use fiat currency symbol from settings
  ([42d49328](https://github.com/blockchain/My-Wallet-V3-iOS/commit/42d493283889309b06483fc202ad7370b7d77024))

  - **sendxlmmodelinterface**
    - remove unneeded optionals
  ([ff0913ff](https://github.com/blockchain/My-Wallet-V3-iOS/commit/ff0913fff78a734b85b14287273db563e6d50f2c))

  - **sendxlmviewcontroller**
    - update model before interface and hide error label
  ([2d249f63](https://github.com/blockchain/My-Wallet-V3-iOS/commit/2d249f632812b2251c4ba003d77859f096f75bb5))

  - **settings**
    - prevent app crash when getting local symbol
  ([bc361e82](https://github.com/blockchain/My-Wallet-V3-iOS/commit/bc361e8246563a652123626badd295b862fbb179))

  - **simplelist**
    - move custom cell implementation to SimpleListViewController
  ([c046d3ed](https://github.com/blockchain/My-Wallet-V3-iOS/commit/c046d3ed1eb3d2d496504b0f28a8b1334f2882fe))

  - **simplelistdataprovider**
    - update heightForRowAtIndexPath
  ([75080660](https://github.com/blockchain/My-Wallet-V3-iOS/commit/750806605e6a51bd95cc1e666a11e131fc929410))

  - **simpletransactionsviewcontroller**
    - handle all asset types for no transactions view
  ([661ec0b2](https://github.com/blockchain/My-Wallet-V3-iOS/commit/661ec0b2b540695c46443b2b8062967f2f65241a))

  - **stellarinformationservice**
    - calculate amounts based on base reserve
  ([753e36fe](https://github.com/blockchain/My-Wallet-V3-iOS/commit/753e36fe2df5b823276e20161b6f9ae12d03e24b))

  - **sunriver**
    - do not show error message if cancelling second password
  ([91c6a15b](https://github.com/blockchain/My-Wallet-V3-iOS/commit/91c6a15b68fd8a687655352395766210901fafc0))
    - pass shared service provider to reuse account instances
  ([d8dac988](https://github.com/blockchain/My-Wallet-V3-iOS/commit/d8dac9889c14df067292970e9394b5f3325979db))
    - allow nil amount entries
  ([9a29d0e6](https://github.com/blockchain/My-Wallet-V3-iOS/commit/9a29d0e6593c2ae8c1aa1896b6138d259e9d7a4f))

  - **xlmserviceprovider**
    - remove unused service
  ([578f8016](https://github.com/blockchain/My-Wallet-V3-iOS/commit/578f8016893a987cacda84628d361ece0294cb5c))




## Dependencies

  - **my-wallet-v3**
    - Update My-Wallet-V3 to c1ea951 (#21)
  ([153dbf67](https://github.com/blockchain/My-Wallet-V3-iOS/commit/153dbf679d93c72dcb0efc87300d7284f389a700))




## Features

  - **analytics**
    - IOS-1399 Added events to Firebase Analytics (#65)
  ([5f366843](https://github.com/blockchain/My-Wallet-V3-iOS/commit/5f3668432ca891c9029348a06dcab57a882307ec))

  - **appfeature**
    - add stellar in AppFeature enumeration (IOS-1504)
  ([73e11aef](https://github.com/blockchain/My-Wallet-V3-iOS/commit/73e11aeff939c69ed6c1a3d3948daeb340dfe2bb))

  - **assetaccountrepository**
    - get stellar account for Exchange
  ([2b70ea3b](https://github.com/blockchain/My-Wallet-V3-iOS/commit/2b70ea3b0aca204f9362da1e5fa03f35a3f6e2fe))

  - **assets**
    - add symbol image template property
  ([7b978959](https://github.com/blockchain/My-Wallet-V3-iOS/commit/7b97895930405d8a834159349e1109950bfa26c1))
    - add helper functions
  ([29a77bf7](https://github.com/blockchain/My-Wallet-V3-iOS/commit/29a77bf73b05ef5396a54b08c7b2f3d490e277a7))

  - **assetselector**
    - add entry for Stellar
  ([13cb0432](https://github.com/blockchain/My-Wallet-V3-iOS/commit/13cb0432e62714d8b03829351b667c58f37f95d4))

  - **assetselectorview**
    - use darker blue color for cells and table view
  ([aa1e7bf8](https://github.com/blockchain/My-Wallet-V3-iOS/commit/aa1e7bf8226244cbd38e97734239b253fe740cad))
    - use xib for new AssetTypeCell
  ([c46b0214](https://github.com/blockchain/My-Wallet-V3-iOS/commit/c46b0214e3a44a3c50bd3d6fc059d8da608ba9e5))

  - **assettype**
    - add brand image
  ([e0c8e8b5](https://github.com/blockchain/My-Wallet-V3-iOS/commit/e0c8e8b5fc4f168eb69d8c7414e80e0a7960a9ec))
    - add stellar as AssetType and LegacyAssetType
  ([514ca366](https://github.com/blockchain/My-Wallet-V3-iOS/commit/514ca36607719228c8b66a723a353604d4142034))

  - **assettypecell**
    - set darker highlight color
  ([ab1410b1](https://github.com/blockchain/My-Wallet-V3-iOS/commit/ab1410b104c629fda64c960fe540c330c06429e5))

  - **dashboard**
    - resolve async task dependency issue
  ([8e3e1eef](https://github.com/blockchain/My-Wallet-V3-iOS/commit/8e3e1eef1f7711c639553133ef9dbbbba72df691))
    - show XLM balance (WIP)
  ([285403d7](https://github.com/blockchain/My-Wallet-V3-iOS/commit/285403d75ed6622ca63bbee58057a5cf38166046))
    - use test configuration for XLM account
  ([593f506f](https://github.com/blockchain/My-Wallet-V3-iOS/commit/593f506f43f4d9a209886fe797de83335d62e00f))
    - add chart empty state
  ([9ffa2ec8](https://github.com/blockchain/My-Wallet-V3-iOS/commit/9ffa2ec8a3c1a4f4e44018786509f20a473fdb5a))
    - correctly display XLM price in chart title
  ([0f3ea968](https://github.com/blockchain/My-Wallet-V3-iOS/commit/0f3ea96833f9bac6c1c3aa485a20f2729201bbca))
    - get XML account balance
  ([93200479](https://github.com/blockchain/My-Wallet-V3-iOS/commit/932004799c3acc8e14dcb8c978983ae8f9c59a3a))
    - add stub for stellar legend tap event
  ([39d5e386](https://github.com/blockchain/My-Wallet-V3-iOS/commit/39d5e386b816e5e1b7bd8ca6663648aa6187c4ff))
    - being adding stellar to pie chart
  ([9f41eab6](https://github.com/blockchain/My-Wallet-V3-iOS/commit/9f41eab68e984822c73f28ad4cc4812b6c1a383c))
    - localize price preview view action button
  ([ec961172](https://github.com/blockchain/My-Wallet-V3-iOS/commit/ec961172c5e21d0915809f52ef014522cb9cebae))
    - add image to price preview view action button
  ([e61511c7](https://github.com/blockchain/My-Wallet-V3-iOS/commit/e61511c738b8b2913c1cf4fa1a56c81b6a6b1212))
    - price preview view UI improvements
  ([77f8463b](https://github.com/blockchain/My-Wallet-V3-iOS/commit/77f8463b0483421fc92510dfccffd1d2bdba458d))

  - **firebase**
    - Adding support different environments (dev, staging, prod)
  ([055a9dc4](https://github.com/blockchain/My-Wallet-V3-iOS/commit/055a9dc495862bc308b53256cec9abdd780ead88))
    - Adding LDFLAGS to release schema
  ([6b7ead0a](https://github.com/blockchain/My-Wallet-V3-iOS/commit/6b7ead0a369196d4d4729568b5bfe11ddc0c0bbd))
    - Adding Firebase to project in order to manage DeepLinks.
  ([ce3a606a](https://github.com/blockchain/My-Wallet-V3-iOS/commit/ce3a606a4bfe15fd0efd737719a5a55a5888f048))

  - **homebrew-exchange**
    - enforce 7 max fraction digits for XLM
  ([8a43330d](https://github.com/blockchain/My-Wallet-V3-iOS/commit/8a43330d5cbdcd1cc6dad06e4910f8ae33b787cd))

  - **numberformatter**
    - add conversion and symbol formatting methods
  ([939fb8ed](https://github.com/blockchain/My-Wallet-V3-iOS/commit/939fb8ed9b19c6971f0826b2a83c1c29c869b623))

  - **priceserviceclient**
    - create PriceServiceClient for fetching fiat prices (IOS-1508) (#22)
  ([2bb944eb](https://github.com/blockchain/My-Wallet-V3-iOS/commit/2bb944eb06786a0d3cb7bf057087279884ce8109))

  - **receivexlmviewcontroller**
    - create URI with public key and use in QR code
  ([c8fc258b](https://github.com/blockchain/My-Wallet-V3-iOS/commit/c8fc258bd5b136b6be9616ff5d66a090fcc8beb0))

  - **sendlumensviewcontroller**
    - format fiat symbol
  ([7ecee864](https://github.com/blockchain/My-Wallet-V3-iOS/commit/7ecee8644105d8ca0e38e57b394fea9941136714))

  - **simplelist**
    - add loading cell and default to one section
  ([dbdf5aeb](https://github.com/blockchain/My-Wallet-V3-iOS/commit/dbdf5aebc050c0ae86dd44ca289374feafa36d4b))
    - add loading cell and default to one section
  ([45d393f2](https://github.com/blockchain/My-Wallet-V3-iOS/commit/45d393f2901a4861874c7f90ac81b8ae2ef75455))

  - **sr**
    - switching to production for XLM. (#66)
  ([0e6afa53](https://github.com/blockchain/My-Wallet-V3-iOS/commit/0e6afa53f8e3be855170b545b8dd34e3e8ac60ec))
    - Adding memo to XLM Send Screen (#59)
  ([041b85a9](https://github.com/blockchain/My-Wallet-V3-iOS/commit/041b85a96e15c4f0ecbaf4197950d16c8d5baa13))
    - IOS-1443 - Funding Accounts Minimum (#58)
  ([b1b686af](https://github.com/blockchain/My-Wallet-V3-iOS/commit/b1b686afcb4314ea81b55c45ff51ad6555f91fe5))
    - IOS-1450 - Showing Transaction Details (#52)
  ([8c747f94](https://github.com/blockchain/My-Wallet-V3-iOS/commit/8c747f94fa83c8ed4c196ec588e2458daee5c05e))
    - StellarOperations progress (#37)
  ([489d5621](https://github.com/blockchain/My-Wallet-V3-iOS/commit/489d56213db2ae1b39d058759f9f2572ea4a3080))
    - Handling no stellar account UI. (#33)
  ([782786e1](https://github.com/blockchain/My-Wallet-V3-iOS/commit/782786e1a0963106fb6e9afe6ceacabaa74db41a))
    - Adding ActionableLabel (#29)
  ([dd2a9457](https://github.com/blockchain/My-Wallet-V3-iOS/commit/dd2a94570ab4c37e3f27c611ede877b9fe00582c))
    - Adding in StellarLedger and XLMCoordinator (#26)
  ([542e197b](https://github.com/blockchain/My-Wallet-V3-iOS/commit/542e197b73f8c848076cab9afc43730f9e21059e))
    - Fetching Transaction Details API call (#16)
  ([4282d287](https://github.com/blockchain/My-Wallet-V3-iOS/commit/4282d287fce23ea2bb13095aca903937d1b46f75))
    - Stubbing out Fetch Trades  (#12)
  ([48285853](https://github.com/blockchain/My-Wallet-V3-iOS/commit/4828585305e9b66d3079ef9f203faa7efb00be13))
    - pull SR info from wallet metadata (IOS-1471).
  ([28c1e4bc](https://github.com/blockchain/My-Wallet-V3-iOS/commit/28c1e4bcfb7afd20eb606dbb617a8bf73f95fd43))
    - Stubbing out Send Lumens screen.
  ([cd2a004e](https://github.com/blockchain/My-Wallet-V3-iOS/commit/cd2a004e2b2b6d3b4f8be78bbac8b564193b6de8))
    - - IOS-1472 - Adding SDK
  ([a410da7e](https://github.com/blockchain/My-Wallet-V3-iOS/commit/a410da7ec63e51941bdbefd73095af2244362af3))

  - **stellar**
    - show XLM price chart
  ([8428c227](https://github.com/blockchain/My-Wallet-V3-iOS/commit/8428c2279a682182bacef9f8bfc486f61c0d63f4))
    - format prices in price preview views
  ([c5b22d71](https://github.com/blockchain/My-Wallet-V3-iOS/commit/c5b22d7104a657cd9fe3a5c2bfcfbe84d8df7aba))
    - add Stellar entry timestamp
  ([ced79bb4](https://github.com/blockchain/My-Wallet-V3-iOS/commit/ced79bb4eb7f5c5f2a78c5d0152eabaf4d174de6))
    - begin stellar support for price charts
  ([0f0a7ea9](https://github.com/blockchain/My-Wallet-V3-iOS/commit/0f0a7ea937e0f0d0678fea4e9a6072126f3e1e34))

  - **stellarinformationservice**
    - format attributed strings
  ([f6f214ea](https://github.com/blockchain/My-Wallet-V3-iOS/commit/f6f214ea3f4d87cfa95e778c6bf1d789a12b0283))

  - **sun river**
    - creating ReceiveXlmViewController (IOS-1444)
  ([3057f4f6](https://github.com/blockchain/My-Wallet-V3-iOS/commit/3057f4f6e9eac5b37f4f23e578a457a4fc436ba8))

  - **sunriver**
    - airdrop onboarding cards (IOS-IOS-1477).
  ([d3676a3d](https://github.com/blockchain/My-Wallet-V3-iOS/commit/d3676a3d9eef9726f6b98c26a1a0f45215221c19))
    - direct user to stellar.org when tapping 'Read More'
  ([3197fe7d](https://github.com/blockchain/My-Wallet-V3-iOS/commit/3197fe7db6ea891134350e8cd1b47f63170643cb))
    - add StellarInformationService
  ([1378b3b6](https://github.com/blockchain/My-Wallet-V3-iOS/commit/1378b3b65be339bfb14785e7deb56a731d05d597))
    - show join waitlist onboarding card (IOS-1448, IOS-1504) (#56)
  ([3574db2d](https://github.com/blockchain/My-Wallet-V3-iOS/commit/3574db2dc5761b5f38fe88811691e521fe36497f))
    - sending XLM address to Nabu to register for campaign (IOS-1536) (#55)
  ([6c900fc0](https://github.com/blockchain/My-Wallet-V3-iOS/commit/6c900fc06c464e2ad3affa985f506ac6ea11c3dc))
    - handle tapping on max XLM (IOS-1549). (#53)
  ([8471d60b](https://github.com/blockchain/My-Wallet-V3-iOS/commit/8471d60bd3bcb4f0f032f8b4e8dfc0372537ae99))
    - enforce max spendable amount (IOS-1540, IOS-1513) (#51)
  ([085efc8c](https://github.com/blockchain/My-Wallet-V3-iOS/commit/085efc8c25db5449d33a46670cea7d05f1318cb2))
    - awaiting verifiation page (IOS-1480) (#49)
  ([c433f796](https://github.com/blockchain/My-Wallet-V3-iOS/commit/c433f7960ddbe073967777e9c071282a03448767))
    - persist deeplink and kickstart KYC (IOS-1517) (#48)
  ([bee779a5](https://github.com/blockchain/My-Wallet-V3-iOS/commit/bee779a5b2663fb27986e8e718929d3725044b43))
    - fund unfunded account (IOS=1524). (#41)
  ([aa2a46ea](https://github.com/blockchain/My-Wallet-V3-iOS/commit/aa2a46ea123c864f00a0ca9610eb22e79a4fe6ab))
    - handle sending XLM to funded accounts (IOS-1520).
  ([a440303c](https://github.com/blockchain/My-Wallet-V3-iOS/commit/a440303cef81de97c96a31c3459ba0a980876a1c))
    - reuse prompting for 2nd password (IOS-1503) (#28)
  ([a7aa4629](https://github.com/blockchain/My-Wallet-V3-iOS/commit/a7aa46298b22d2a80fd85269db0b0c4da5f18686))
    - parse SEP-0007 URI with send controller QR scanner
  ([d05ed424](https://github.com/blockchain/My-Wallet-V3-iOS/commit/d05ed4245b983b253533bc98bdbb2c4beb69b472))
    - add StellarURLPayload
  ([22ca26da](https://github.com/blockchain/My-Wallet-V3-iOS/commit/22ca26da43579c158294c1d0a10776ee653d6c22))
    - initialize wallet metadata with XLM account (IOS-1500)
  ([8d553709](https://github.com/blockchain/My-Wallet-V3-iOS/commit/8d55370921cef9285f215cb41b182c23d82ba22f))
    - allow saving a new WalletLumensAccount in wallet metadata.
  ([540735d6](https://github.com/blockchain/My-Wallet-V3-iOS/commit/540735d6918fc61307d98c50d73756b393bd7b8e))

  - **swipetoreceive**
    - implement swipe to receive for XLM (IOS-1445) (#20)
  ([3accedf8](https://github.com/blockchain/My-Wallet-V3-iOS/commit/3accedf80b84ca13f799ad3a5088532a3712ba62))

  - **textfieldinput**
    - create FiatTextFieldDelegate class
  ([f9073b58](https://github.com/blockchain/My-Wallet-V3-iOS/commit/f9073b583bae4bdc6f4bade985956d78ad4c7a5a))

  - **urischeme**
    - add extension for parsing URI
  ([649bba6d](https://github.com/blockchain/My-Wallet-V3-iOS/commit/649bba6d92125cdfe703cde5f01d46012bc13115))

  - **xlm**
    - Adding StellarAccountAPI, StellarTransactionAPI, StellarAccount, and StellarConfiguration
  ([37e12e32](https://github.com/blockchain/My-Wallet-V3-iOS/commit/37e12e3287d3aa16700259e49acec36b47aef68c))




## Documentation

  - **blockchainapi**
    - fix typo [ci skip]
  ([20149db6](https://github.com/blockchain/My-Wallet-V3-iOS/commit/20149db667625c8ae45d2dd6fa67d6b84b000d21))




## Refactor

  - **addresses**
    - make assetType immutable
  ([adab0386](https://github.com/blockchain/My-Wallet-V3-iOS/commit/adab0386e97832f32bf12a2561aaf652ef8ad351))

  - **amounttextfielddelegate**
    - store decimal separators as property
  ([244dc922](https://github.com/blockchain/My-Wallet-V3-iOS/commit/244dc922270e3132863995bf66e332f5f177eed9))
    - add initializer to include max decimal places
  ([9f2f7a86](https://github.com/blockchain/My-Wallet-V3-iOS/commit/9f2f7a86d5f81123e474a07d7a1a3db41ba94020))

  - **assetselectorview**
    - remove if statement since instance of custom cell is guaranteed
  ([542740fd](https://github.com/blockchain/My-Wallet-V3-iOS/commit/542740fd7b611ea994f7f7632d6e094baa163548))

  - **assettypecell**
    - set background color and selected background view in xib
  ([92086db8](https://github.com/blockchain/My-Wallet-V3-iOS/commit/92086db8f21ce7c8c5ce1bc9d320a1f41b98d5e8))

  - **constants**
    - store satoshi constant as Double
  ([99faded6](https://github.com/blockchain/My-Wallet-V3-iOS/commit/99faded60ffc2da9c5493ba8f401fe34d13425f1))
    - fix precision loss warning
  ([cadcccb3](https://github.com/blockchain/My-Wallet-V3-iOS/commit/cadcccb31103d81bf6f595f944ad91126c44e28c))
    - deprecate obj-c definitions of filter indexes in Blockchain-Prefix
  ([de9bd5f7](https://github.com/blockchain/My-Wallet-V3-iOS/commit/de9bd5f78ba364c83223aa4edf93600aa12e7951))

  - **dashboard**
    - rename balance reload method for clarity
  ([eac06655](https://github.com/blockchain/My-Wallet-V3-iOS/commit/eac06655f24eb457f7f6cde81eee7b9e10c0dba6))
    - use CGRectZero
  ([78330d30](https://github.com/blockchain/My-Wallet-V3-iOS/commit/78330d30c7a783180ee6f14cf1c8586d4dc4e835))
    - remove unnecessary empty state
  ([02b403f4](https://github.com/blockchain/My-Wallet-V3-iOS/commit/02b403f4c21672ea7efa3defd7caedbf2f1b0e33))
    - remove call to get XLM balance
  ([3fd6dac8](https://github.com/blockchain/My-Wallet-V3-iOS/commit/3fd6dac8f233412c3c0855b337636dd33a198f62))
    - remove redundant closure parameter
  ([8bbb4292](https://github.com/blockchain/My-Wallet-V3-iOS/commit/8bbb4292858c8afabc9a5e64c88b4363951dae39))
    - Swift implementation of BCPricePreviewView
  ([4069315a](https://github.com/blockchain/My-Wallet-V3-iOS/commit/4069315a2516c838543b67e8b5439cf8778d8d38))
    - use tab bar constant from Navigation struct
  ([0dcb5920](https://github.com/blockchain/My-Wallet-V3-iOS/commit/0dcb5920ae7ba43584adb3bf961ce27aa36d77f9))
    - begin Swift implementation of the dashboard
  ([a2351c22](https://github.com/blockchain/My-Wallet-V3-iOS/commit/a2351c223834221df4a0dd4fe2811eb628b4be4f))
    - disable extension
  ([aebc100a](https://github.com/blockchain/My-Wallet-V3-iOS/commit/aebc100af3ddc1712563f5f542fe71bf084b0659))
    - apply stashed changes
  ([77dd4f08](https://github.com/blockchain/My-Wallet-V3-iOS/commit/77dd4f083b0c6c072a49024566e92e33ae7a5239))

  - **exchangecoordinator**
    - do not store reference to XLMServiceProvider
  ([eeb4b6cd](https://github.com/blockchain/My-Wallet-V3-iOS/commit/eeb4b6cde405771c0bb9f31b1ff2170660ce9175))

  - **numberformatter**
    - change symbol formatting to string extension
  ([88d85480](https://github.com/blockchain/My-Wallet-V3-iOS/commit/88d85480ab00ad2dda35afed34473998540de667))

  - **sendbitcoinviewcontroller**
    - rename transaction type enum
  ([c9bf8b63](https://github.com/blockchain/My-Wallet-V3-iOS/commit/c9bf8b63ffbcf3afbbfdff0575a3f91ac92463f5))

  - **sendlumensviewcontroller**
    - move SFSafariViewController presentation to Application+Helpers
  ([5d79d35d](https://github.com/blockchain/My-Wallet-V3-iOS/commit/5d79d35d94035e70247ad83dbbbf46fe54112050))

  - **sendxlmcoordinator**
    - silence SwiftLint warning by removing literal
  ([8ac908b0](https://github.com/blockchain/My-Wallet-V3-iOS/commit/8ac908b0c577cb6b84eff24125614c2e752a0041))

  - **settings**
    - use currency symbol of device locale if latestMultiAddressResponse is unavailable
  ([397c26f5](https://github.com/blockchain/My-Wallet-V3-iOS/commit/397c26f5028cf4ac1fb2533a2fcd6a49450837fd))

  - **simplelist**
    - pass subclass type to factory method
  ([de801bdd](https://github.com/blockchain/My-Wallet-V3-iOS/commit/de801bdda74bcd57085b626ebd6abd230a8523bb))

  - **simplelistdataprovider**
    - rename data provider
  ([95343380](https://github.com/blockchain/My-Wallet-V3-iOS/commit/95343380ff321fce5ba2a2cfe33d2bdc9bd446a3))

  - **sunriver**
    - return unfunded account if account not found
  ([054a3cd0](https://github.com/blockchain/My-Wallet-V3-iOS/commit/054a3cd01e475162cde3799f90e8451f4b1e2207))
    - prefetch current Stellar account and get current account after initializing in Exchange flow
  ([3830fbc7](https://github.com/blockchain/My-Wallet-V3-iOS/commit/3830fbc75c1b1045fe7e0b84014b6fa1d2073e99))
    - improve readability
  ([00357e59](https://github.com/blockchain/My-Wallet-V3-iOS/commit/00357e595fc1f704938a217d26d8ba1792b99f54))
    - move URIScheme usage to StellarURLPayload to avoid extra import
  ([ee48ad09](https://github.com/blockchain/My-Wallet-V3-iOS/commit/ee48ad09eab8d8ba9e4df18a48ff763fe0bc0996))

  - **transactiondetailviewmodel**
    - make feeInSatoshi private
  ([62c682d2](https://github.com/blockchain/My-Wallet-V3-iOS/commit/62c682d20c0c21cb59c89ca4312981faacb993ab))

  - **transactions**
    - rename XLM files
  ([eec4d4fa](https://github.com/blockchain/My-Wallet-V3-iOS/commit/eec4d4fa66cc4a9796dd42612a4cf38865f2efe2))
    - rename XLM files
  ([642307ef](https://github.com/blockchain/My-Wallet-V3-iOS/commit/642307ef090341819361f3aeacdcac1645114564))

  - **transactiontablecell**
    - reuse txType UI assignment logic
  ([82f82826](https://github.com/blockchain/My-Wallet-V3-iOS/commit/82f82826e686c4cf841361196727e222173517f6))




## Style

  - **dashboard**
    - adjust chart label attributes
  ([59796546](https://github.com/blockchain/My-Wallet-V3-iOS/commit/59796546cfe3d2ad305aaef3ebd587fe35d993f3))




## Chore

  - **amounttextfielddelegate**
    - add ticket
  ([ff2c6ade](https://github.com/blockchain/My-Wallet-V3-iOS/commit/ff2c6ade70b8d1f512a384d108a39e2ca556ffc8))

  - **application+helpers**
    - add comment
  ([ba94cb6c](https://github.com/blockchain/My-Wallet-V3-iOS/commit/ba94cb6c006554509e6176222c9a01968d2589b0))

  - **assets**
    - move symbol assets into AssetType.xcassets
  ([02a38f72](https://github.com/blockchain/My-Wallet-V3-iOS/commit/02a38f72c9a4a2e2915b66829d1b45a240102561))

  - **assettypecell**
    - add docs and use constants
  ([9eafb931](https://github.com/blockchain/My-Wallet-V3-iOS/commit/9eafb93154fd0448cf9f3c36ee0edd55c2b7d4f6))

  - **dashboard**
    - silence function body length violation
  ([434a0a54](https://github.com/blockchain/My-Wallet-V3-iOS/commit/434a0a546b1e9d6db801fe5de566c3ca2fe55b9f))
    - track source files
  ([97acba37](https://github.com/blockchain/My-Wallet-V3-iOS/commit/97acba37afe8b380f13dd0f41549ef625618eec8))

  - **extensions**
    - add comments
  ([e8abb7d8](https://github.com/blockchain/My-Wallet-V3-iOS/commit/e8abb7d87a0d37a7b3cd1f530477823257f53e7d))

  - **homebrew**
    - update copy
  ([f25cb2dc](https://github.com/blockchain/My-Wallet-V3-iOS/commit/f25cb2dc42ede2a64aa3978de88db8f3cbbffdfd))

  - **numberformattertests**
    - add ticket
  ([def123a0](https://github.com/blockchain/My-Wallet-V3-iOS/commit/def123a07e68996b8b41e678ee5b099fec763a6b))

  - **project**
    - update localization strings files
  ([636f601b](https://github.com/blockchain/My-Wallet-V3-iOS/commit/636f601b1d5d12927c40a0002b3dacba81cafa27))
    - update project for Xcode 10 support (#558)
  ([8d14f35a](https://github.com/blockchain/My-Wallet-V3-iOS/commit/8d14f35a146727775e08b5e5cbd78d1ee30d15cd))
    - use renamed assets
  ([5abf6522](https://github.com/blockchain/My-Wallet-V3-iOS/commit/5abf652251ba2d7fded2de79afef54c2de0cd20f))
    - rename asset catalog
  ([00f6e23f](https://github.com/blockchain/My-Wallet-V3-iOS/commit/00f6e23f9201dcac8ee00e28f57fec2888d55d71))
    - apply Xcode suggested changes to validate project settings
  ([3aaadd61](https://github.com/blockchain/My-Wallet-V3-iOS/commit/3aaadd61c05fac96f4e3784ceeb65315d03e5314))
    - disable trailing closure linter rule
  ([3995b1f1](https://github.com/blockchain/My-Wallet-V3-iOS/commit/3995b1f1db7ee4c25f78e65a36750d1630e24f02))
    - disable trailing whitespace linter rule
  ([eaf33ba0](https://github.com/blockchain/My-Wallet-V3-iOS/commit/eaf33ba0b74fdaf71f25c52adda171361d635aa3))
    - disable leading whitespace linter rule
  ([882ea551](https://github.com/blockchain/My-Wallet-V3-iOS/commit/882ea551253a6bae7f00c09fff55bfa2f193b359))
    - clean up rules
  ([9392d175](https://github.com/blockchain/My-Wallet-V3-iOS/commit/9392d175adf1fbce892eb82b59144f734176ab32))
    - update project for Xcode 10 support (#558)
  ([db6804fa](https://github.com/blockchain/My-Wallet-V3-iOS/commit/db6804fa489a478d56a241aec2730c13515eeeab))

  - **sendxlmcoordinator**
    - remove comments
  ([d54cfde1](https://github.com/blockchain/My-Wallet-V3-iOS/commit/d54cfde18f0ba36f803955e51660f2fe230fb644))

  - **simplelist**
    - add note for delegate method
  ([c9c6d124](https://github.com/blockchain/My-Wallet-V3-iOS/commit/c9c6d124680ff7874dd642bc30274571674e12b1))

  - **simpletransactionsviewcontroller**
    - add comment describing filterIndex property
  ([6701742a](https://github.com/blockchain/My-Wallet-V3-iOS/commit/6701742ad3af8670a1b99207400115696860574e))
    - add refactoring ticket
  ([f3a0069c](https://github.com/blockchain/My-Wallet-V3-iOS/commit/f3a0069c083838a44ff7cb04bc533ec50a127b63))

  - **sr**
    - Removing `StellarAccountService` from tests target.
  ([12cc7758](https://github.com/blockchain/My-Wallet-V3-iOS/commit/12cc7758a9ff7dfbdd3ddbdc8740af34fcccf5e0))
    - Fixing project file.
  ([a29fa8c4](https://github.com/blockchain/My-Wallet-V3-iOS/commit/a29fa8c4e4534068a49f641d881971ce3d07ddd7))

  - **stellartransactionserviceapi**
    - add TODOs
  ([0b273611](https://github.com/blockchain/My-Wallet-V3-iOS/commit/0b273611dcf4aed9329574603fabbae983e6288b))

  - **sunriver**
    - iOS-1551 Copy Changes (#61)
  ([384d1326](https://github.com/blockchain/My-Wallet-V3-iOS/commit/384d1326ff61fca6be1c1ef01913463982a1af82))

  - **tradeexecutionservice**
    - add comment for ticket
  ([0df93a9e](https://github.com/blockchain/My-Wallet-V3-iOS/commit/0df93a9e9d58f3cb559211a2eb5a6deba9af6adc))




## Branchs merged
  - Merge branch 'dev' into release
  ([91e51f1e](https://github.com/blockchain/My-Wallet-V3-iOS/commit/91e51f1ec52295b9b8475803a53d277ad71edf5f))
  - Merge branch 'dev' into kevin/1446/xlm_exchange
  ([0f0f74c7](https://github.com/blockchain/My-Wallet-V3-iOS/commit/0f0f74c703f9e7641c8e9806b611e0c42a9a7563))
  - Merge branch 'dev' into release
  ([498e1881](https://github.com/blockchain/My-Wallet-V3-iOS/commit/498e188120cb6f3adaedd79f59e77b614df47685))
  - Merge branch 'dev' of github.com:blockchain/wallet-ios-private into maurice/ios-1440/xlm-balances
  ([8d694c6c](https://github.com/blockchain/My-Wallet-V3-iOS/commit/8d694c6c294d3c9cacb1600066483377c74834b3))
  - Merge branch 'dev' into kevin/1446/xlm_exchange
  ([e937a159](https://github.com/blockchain/My-Wallet-V3-iOS/commit/e937a1598cde6a6d5559230f62fa17d2dc04aaff))
  - Merge branch 'dev' into kevin/number_formatter
  ([be5d3aab](https://github.com/blockchain/My-Wallet-V3-iOS/commit/be5d3aab23f90fd636be85e64038ea0fe20dfa5d))
  - Merge branch 'dev' into kevin/1446/xlm_exchange
  ([2c822dcb](https://github.com/blockchain/My-Wallet-V3-iOS/commit/2c822dcb90e7a69b1668d171168cb7f4f07943ef))
  - Merge branch 'dev' into kevin/1446/xlm_exchange
  ([28b87e16](https://github.com/blockchain/My-Wallet-V3-iOS/commit/28b87e168daadfe6b00315a679abc0e18e69ac5d))
  - Merge branch 'dev' into kevin/1446/xlm_exchange
  ([fd18dca9](https://github.com/blockchain/My-Wallet-V3-iOS/commit/fd18dca910c5efcf986e0a978815afa6aaa2b2c3))
  - Merge branch 'release' of github.com:blockchain/My-Wallet-V3-iOS into release
  ([38aed89c](https://github.com/blockchain/My-Wallet-V3-iOS/commit/38aed89c52b61a5df35625a90850d0bc1c71a85d))
  - Merge branch 'dev' of github.com:blockchain/wallet-ios-private into maurice/ios-1441/xlm-charts
  ([f9be1bdb](https://github.com/blockchain/My-Wallet-V3-iOS/commit/f9be1bdb4631111819121d198c93aad526e56e5b))
  - Merge branch 'dev' into kevin/IOS-1522/auto_convert
  ([5553d027](https://github.com/blockchain/My-Wallet-V3-iOS/commit/5553d0277e1572fa5b77d693f735ba729693b6f6))
  - Merge branch 'dev' into maurice/ios-1441/xlm-charts
  ([d69b3513](https://github.com/blockchain/My-Wallet-V3-iOS/commit/d69b35136bf46cee7224b23cdbfd5350243ab6d0))
  - Merge branch 'dev' into kevin/IOS-1518/qr_format
  ([d0929188](https://github.com/blockchain/My-Wallet-V3-iOS/commit/d0929188165f7c58c168ae97f4ec61d74a2a612f))
  - Merge branch 'dev' into maurice/ios-1441/xlm-charts
  ([c33cc505](https://github.com/blockchain/My-Wallet-V3-iOS/commit/c33cc5051d6b1dc6b1706be2043b302d0509ef57))
  - Merge branch 'dev' into maurice/ios-1297/dashboard-refactor
  ([79256f71](https://github.com/blockchain/My-Wallet-V3-iOS/commit/79256f7173b141090b2979be6e119a3d8725d93b))
  - Merge branch 'dev' into maurice/ios-1297/dashboard-refactor [ci skip]
  ([dc6400c2](https://github.com/blockchain/My-Wallet-V3-iOS/commit/dc6400c220fef0827d05ee3a8a3ed8fe24a6ca16))
  - Merge branch 'dev' into kevin/IOS-1491/tx_list
  ([730744ff](https://github.com/blockchain/My-Wallet-V3-iOS/commit/730744ff002f07a22e7c3ba16772aac2f8504ca0))
  - Merge branch 'dev' into kevin/IOS-1491/tx_list
  ([5d53d13f](https://github.com/blockchain/My-Wallet-V3-iOS/commit/5d53d13f20e00702c9686561381d909fb8008564))
  - Merge branch 'dev' into kevin/IOS-1491/tx_list
  ([25e72366](https://github.com/blockchain/My-Wallet-V3-iOS/commit/25e72366f243eb06fbfd85f1fac3bed75847e7ef))
  - Merge branch 'dev' into maurice/ios-1297/dashboard-refactor [ci skip]
  ([5b0b7357](https://github.com/blockchain/My-Wallet-V3-iOS/commit/5b0b7357e566105ea26da3025a1f0284c397b39c))
  - Merge branch 'dev' into kevin/IOS-1442/assets_dropdown
  ([5d68cb99](https://github.com/blockchain/My-Wallet-V3-iOS/commit/5d68cb993bf13ab98d7d27587afa7c57a1c81345))
  - Merge branch 'dev' into kevin/IOS-1442/assets_dropdown
  ([ab1dd4eb](https://github.com/blockchain/My-Wallet-V3-iOS/commit/ab1dd4eba5c6b0ed7adf879592f6fa94037d3cc8))




## Pull requests merged
  - Merge pull request #68 from blockchain/kevin/fix_tests
  ([f29fc0ba](https://github.com/blockchain/My-Wallet-V3-iOS/commit/f29fc0bafb2d70cc39c02a66aa614e458160f5fd))
  - Merge pull request #67 from blockchain/maurice/ios-1440/xlm-balances-fixes
  ([7a990156](https://github.com/blockchain/My-Wallet-V3-iOS/commit/7a990156cd006bc3f71b0fe8b725eafd4169cf0a))
  - Merge pull request #64 from blockchain/kevin/IOS-1552/xlm_info
  ([1618439b](https://github.com/blockchain/My-Wallet-V3-iOS/commit/1618439b9521dae746b18c2319976ea1b72c34e0))
  - Merge pull request #57 from blockchain/kevin/1446/xlm_exchange
  ([50ba2cdb](https://github.com/blockchain/My-Wallet-V3-iOS/commit/50ba2cdbf00764dd6e7a1b5a481d04cf973d0ab8))
  - Merge pull request #62 from blockchain/chris/ios-1477/sunriver_onboarding_cards
  ([065352ad](https://github.com/blockchain/My-Wallet-V3-iOS/commit/065352adb45ca184551cdc43580d917e84eab96f))
  - Merge pull request #60 from blockchain/maurice/ios-1440/xlm-balances
  ([b9981266](https://github.com/blockchain/My-Wallet-V3-iOS/commit/b9981266e6e1b402579ad90efb97832c55ca6d30))
  - Merge pull request #54 from blockchain/kevin/fix_nil_entry
  ([988f9f51](https://github.com/blockchain/My-Wallet-V3-iOS/commit/988f9f51d3c7c5331a75eb725595fad8b6f8f87f))
  - Merge pull request #43 from blockchain/kevin/number_formatter
  ([55fd8b0c](https://github.com/blockchain/My-Wallet-V3-iOS/commit/55fd8b0cc48261ef3c4ec5ec97664ce30e16f632))
  - Merge pull request #50 from blockchain/release-localization-fix
  ([fec85fab](https://github.com/blockchain/My-Wallet-V3-iOS/commit/fec85fab71ce6032a8528a59fb4e9172ab0e1568))
  - Merge pull request #47 from blockchain/kevin/fix_unrecognized_selector
  ([0258bf2a](https://github.com/blockchain/My-Wallet-V3-iOS/commit/0258bf2a154c9ae886848e3d01540054c7c4862e))
  - Merge pull request #46 from blockchain/kevin/fix_compiler_error
  ([fb52d751](https://github.com/blockchain/My-Wallet-V3-iOS/commit/fb52d7514cedd808e7640be6604b30e0db975a1c))
  - Merge pull request #40 from blockchain/maurice/ios-1441/xlm-charts-fixes
  ([f32c677a](https://github.com/blockchain/My-Wallet-V3-iOS/commit/f32c677a2dd58f74dcd0af760697abbd9c27e943))
  - Merge pull request #31 from blockchain/roberto/firebase
  ([51642dea](https://github.com/blockchain/My-Wallet-V3-iOS/commit/51642deacbb255546a6e1e85248af7791d84499b))
  - Merge pull request #44 from blockchain/maurice/ios-1532/homebrew-copy-release
  ([df39579b](https://github.com/blockchain/My-Wallet-V3-iOS/commit/df39579bb23086816edd844f6f75c364ac24927c))
  - Merge pull request #39 from blockchain/kevin/IOS-972/open_dashboard
  ([a12e3dee](https://github.com/blockchain/My-Wallet-V3-iOS/commit/a12e3dee379ef62551bf8591a10adf880c2c201c))
  - Merge pull request #36 from blockchain/kevin/IOS-1523/confirm_view
  ([c1e8c666](https://github.com/blockchain/My-Wallet-V3-iOS/commit/c1e8c666e81f05f03dc681e34f9333958ea1c846))
  - Merge pull request #38 from blockchain/maurice/ios-1441/xlm-charts
  ([ae820fe4](https://github.com/blockchain/My-Wallet-V3-iOS/commit/ae820fe4bf683d56177f4d2481217df5db8ae94a))
  - Merge pull request #35 from blockchain/chris/ios-1520/send_tx
  ([8c8ebf25](https://github.com/blockchain/My-Wallet-V3-iOS/commit/8c8ebf2563d56bd3f4a02e9847636ccf59e679f6))
  - Merge pull request #34 from blockchain/kevin/IOS-1522/auto_convert
  ([920af7ca](https://github.com/blockchain/My-Wallet-V3-iOS/commit/920af7cad96ed47c2c76bbe02e59d6f3ade9b00b))
  - Merge pull request #32 from blockchain/kevin/IOS-1519/sanitize_input
  ([c52bf662](https://github.com/blockchain/My-Wallet-V3-iOS/commit/c52bf6624e0453ee4f4ca40ca5fb71d782842179))
  - Merge pull request #27 from blockchain/kevin/IOS-1518/qr_format
  ([691bdc8e](https://github.com/blockchain/My-Wallet-V3-iOS/commit/691bdc8ede60073d59a216013e023ea473431edd))
  - Merge pull request #24 from blockchain/kevin/IOS-1491/tx_list
  ([570a0386](https://github.com/blockchain/My-Wallet-V3-iOS/commit/570a038693eeac640ae37d35bb3eebf3fed897c9))
  - Merge pull request #23 from blockchain/roberto/ios-1514
  ([3dffaf9b](https://github.com/blockchain/My-Wallet-V3-iOS/commit/3dffaf9ba70693e54f7c65c63ed6ec59b39a52d0))
  - Merge pull request #18 from blockchain/kevin/IOS-1491/tx_list
  ([21cbcaec](https://github.com/blockchain/My-Wallet-V3-iOS/commit/21cbcaec9f9a2bc484180a5f3c359ef7e0b68a60))
  - Merge pull request #19 from blockchain/maurice/ios-1297/dashboard-refactor
  ([b3569a0e](https://github.com/blockchain/My-Wallet-V3-iOS/commit/b3569a0e873a95425628f71d2f1479784f57cae7))
  - Merge pull request #17 from blockchain/chris/ios-1444/xlm_receive
  ([146f4a6a](https://github.com/blockchain/My-Wallet-V3-iOS/commit/146f4a6a9509459f6cd771bc8ac06e5f1a872fa6))
  - Merge pull request #13 from blockchain/chris/ios-1500/sr_key_pair
  ([f91451f6](https://github.com/blockchain/My-Wallet-V3-iOS/commit/f91451f6359cc6c970147d30fcee9ea7c63658dd))
  - Merge pull request #15 from blockchain/chris/ios-1504/appfeature_stellar
  ([50e55ffa](https://github.com/blockchain/My-Wallet-V3-iOS/commit/50e55ffa5fa11f2703215894ef6a38f063da96cf))
  - Merge pull request #14 from blockchain/chris/ios-1504/appfeature_stellar
  ([0321bc23](https://github.com/blockchain/My-Wallet-V3-iOS/commit/0321bc235c46992460871d1d828ed521b164b9e9))
  - Merge pull request #5 from blockchain/kevin/IOS-1442/assets_dropdown
  ([48ddd8e2](https://github.com/blockchain/My-Wallet-V3-iOS/commit/48ddd8e2f4be746e4cb21200dba3b953af6a7b6c))
  - Merge pull request #4 from blockchain/chris/ios-1471/xlm_wallet_metadata
  ([81d756bd](https://github.com/blockchain/My-Wallet-V3-iOS/commit/81d756bd52d9f6535b2e7fdb73927538c6eff3ba))
  - Merge pull request #9 from blockchain/swiftlint-cocoapods
  ([4da95710](https://github.com/blockchain/My-Wallet-V3-iOS/commit/4da95710d17368a2bafbb6b0a02b82484c70ad18))
  - Merge pull request #8 from blockchain/alex/feature/send-xlm-screen
  ([152b7c04](https://github.com/blockchain/My-Wallet-V3-iOS/commit/152b7c04486e1e480d3507479d2d99ccbb636bf1))
  - Merge pull request #6 from blockchain/alex/feature/xlm-api-integration
  ([481d17f3](https://github.com/blockchain/My-Wallet-V3-iOS/commit/481d17f33a3f160c4fa18bcdbee2be39eb86b6f6))
  - Merge pull request #3 from blockchain/fix-swiftlint
  ([c86589c8](https://github.com/blockchain/My-Wallet-V3-iOS/commit/c86589c858419d7e3edfbfcd5cf22beae0f1c7b1))
  - Merge pull request #2 from blockchain/alex/feature/IOS-1472
  ([f096b911](https://github.com/blockchain/My-Wallet-V3-iOS/commit/f096b911a217992d15373a03ff6b80ac667f79da))
  - Merge pull request #1 from blockchain/kevin/IOS-1463/asset_type
  ([63866fac](https://github.com/blockchain/My-Wallet-V3-iOS/commit/63866facd36b028ca2d844c2cab1b15fe4af3ad4))




## Prototype/Concept

  - **assetaccountrepository**
    - add stellar to asset account repository
  ([d94a920e](https://github.com/blockchain/My-Wallet-V3-iOS/commit/d94a920e0bdd9d890fde45b843e3d73e43b4d9cb))

  - **blockchainapi**
    - add placeholder explorer URL
  ([fb677bc3](https://github.com/blockchain/My-Wallet-V3-iOS/commit/fb677bc34dff4c767920476d4db4958f9083506a))

  - **constants**
    - add transaction types to Constants
  ([61a7b2c1](https://github.com/blockchain/My-Wallet-V3-iOS/commit/61a7b2c1d3f9736dcebdda3f7785d1d1f7fdf4c5))

  - **homebrew-exchange**
    - add optional memo to OrderResult model
  ([5e52ea92](https://github.com/blockchain/My-Wallet-V3-iOS/commit/5e52ea92d5ec31d67d3e8fb23ad7f59487c968d2))
    - fix XLM account fetching
  ([8a09dad0](https://github.com/blockchain/My-Wallet-V3-iOS/commit/8a09dad0899a72a699b0b3bbc8f8c230ad273be4))
    - initialize XLM account if needed and get refund and destination address
  ([0ada4a26](https://github.com/blockchain/My-Wallet-V3-iOS/commit/0ada4a2619c739f4a8867e688518c8514d339dcc))
    - add XLM support to TradeExecutionService
  ([83265314](https://github.com/blockchain/My-Wallet-V3-iOS/commit/8326531415880d40c178d3ba5cbf02ea6303c6f2))

  - **nabuuser**
    - add tags to user
  ([6327653c](https://github.com/blockchain/My-Wallet-V3-iOS/commit/6327653ca242083e8ae128f0528d3914fd72c8af))

  - **sendlumensviewcontroller**
    - add XLM symbol to confirm payment view
  ([7506e62a](https://github.com/blockchain/My-Wallet-V3-iOS/commit/7506e62a243e98cc22c7821fec83cd60a62f403e))
    - format number amounts in confirm payment view
  ([b38b4d5f](https://github.com/blockchain/My-Wallet-V3-iOS/commit/b38b4d5f99ebfb78596a950c1c1935e1ed6158a3))
    - set custom formatter digits and enforce AmountTextFieldDelegate
  ([c9c87332](https://github.com/blockchain/My-Wallet-V3-iOS/commit/c9c87332f5f8935f90930b9c555e750f8e729053))
    - add SendXLMModelInterface and model properties
  ([e33642f0](https://github.com/blockchain/My-Wallet-V3-iOS/commit/e33642f0ac24eb4653dbfd0ee635dc8ee3d055f8))

  - **sendxlmcoordinator**
    - get price on viewDidAppear
  ([d6ee2bf6](https://github.com/blockchain/My-Wallet-V3-iOS/commit/d6ee2bf62e2df9a6bc79249a528488c3c7b687d6))
    - set modelInterface
  ([431ae848](https://github.com/blockchain/My-Wallet-V3-iOS/commit/431ae84839dfcd5893b8d413b7fe689c6574b26d))

  - **simplelist**
    - add Identifiable protocol
  ([960fa2e2](https://github.com/blockchain/My-Wallet-V3-iOS/commit/960fa2e2af25cb66853ae4efd555c0b92f100f63))

  - **simplelistviewcontroller**
    - add interactor, presenter, and related protocols
  ([1eae31d6](https://github.com/blockchain/My-Wallet-V3-iOS/commit/1eae31d6bfdc1e1ca316098ee280bf59b7e2bd8f))

  - **sunriver**
    - add information view controller
  ([b0d60e2e](https://github.com/blockchain/My-Wallet-V3-iOS/commit/b0d60e2ea1c51be99539d333bb6fbec7e80b160b))
    - call error handler when cancelling with second password
  ([20837278](https://github.com/blockchain/My-Wallet-V3-iOS/commit/20837278fab578af4aad9bbd23750740099c7712))

  - **transactions**
    - create SimpleTransactionsViewController (swift version of TransactionsViewController)
  ([396d0dd5](https://github.com/blockchain/My-Wallet-V3-iOS/commit/396d0dd547f373f20d5ea4458e1936acc770d0f4))
    - create RefreshableListDataProvider
  ([ac69838b](https://github.com/blockchain/My-Wallet-V3-iOS/commit/ac69838ba887e8b9b2c0f62ebf5a22d0a419eb12))

  - **transactionslumensviewcontroller**
    - inherit from SimpleListViewController and connect to StellarTransactionService
  ([155f8f24](https://github.com/blockchain/My-Wallet-V3-iOS/commit/155f8f24e84cdfb0bcd86fc3b5fc5a777dfe5a40))

  - **transactiontablecell**
    - configure transaction detail presentation
  ([aaeb3195](https://github.com/blockchain/My-Wallet-V3-iOS/commit/aaeb3195ea363aac1f3538923db57ff5a1fe8ccc))
    - add extensions for XLM
  ([4d1180e5](https://github.com/blockchain/My-Wallet-V3-iOS/commit/4d1180e5d5205878032474d24d189d8122542a86))





---
<sub><sup>*Generated with [git-changelog](https://github.com/rafinskipg/git-changelog). If you have any problems or suggestions, create an issue.* :) **Thanks** </sub></sup>
