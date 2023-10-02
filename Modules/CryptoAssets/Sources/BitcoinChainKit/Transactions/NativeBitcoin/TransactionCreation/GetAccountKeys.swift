// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MetadataHDWalletKit
import ToolKit
import WalletCore

struct BitcoinChainAccount: Identifiable {
    var id: String {
        "\(coin)-\(index)"
    }

    var index: Int32
    var coin: BitcoinChainCoin

    var xpub: XPub?
    var importedPrivateKey: String?
    let isImported: Bool

    init(index: Int32, coin: BitcoinChainCoin, xpub: XPub? = nil, importedPrivateKey: String? = nil, isImported: Bool = false) {
        self.index = index
        self.coin = coin
        self.xpub = xpub
        self.importedPrivateKey = importedPrivateKey
        self.isImported = isImported
    }
}

public struct Mnemonic {
    let words: String

    public init(words: String) {
        self.words = words
    }
}

protocol AccountKeyContextProtocol {
    var coin: UInt32 { get }
    var accountIndex: UInt32 { get }
    var xpubs: [XPub] { get }

    var derivations: AccountKeyContextDerivationsProtocol { get }

    func defaultDerivation(coin: BitcoinChainCoin) -> AccountKeyContextDerivationProtocol
}

protocol AccountKeyContextDerivationProtocol {
    var type: BitcoinChainKit.DerivationType { get }
    var xpriv: String { get }
    var xpub: String { get }

    func accountPrivateKey() -> WalletCore.PrivateKey

    func receivePrivateKey(
        receiveIndex: UInt32
    ) -> WalletCore.PrivateKey

    func changePrivateKey(
        changeIndex: UInt32
    ) -> WalletCore.PrivateKey

    func childKey(
        with childPath: [WalletCore.DerivationPath.Index]
    ) -> WalletCore.PrivateKey
}

protocol AccountKeyContextDerivationsProtocol {
    var all: [AccountKeyContextDerivationProtocol] { get }
    var segWit: AccountKeyContextDerivationProtocol { get }
    var legacy: AccountKeyContextDerivationProtocol { get }
}

struct ImportedAccountKeyContext: AccountKeyContextProtocol {
    let coin: UInt32
    let accountIndex: UInt32
    var xpubs: [XPub]
    let priv: String

    private let xpub: XPub

    var derivations: AccountKeyContextDerivationsProtocol {
        ImportedAccountKeyContextDerivations(
            legacy: ImportedAccountKeyContextDerivation(
                xPub: xpub.address,
                priv: priv
            )
        )
    }

    func defaultDerivation(coin: BitcoinChainCoin) -> AccountKeyContextDerivationProtocol {
        // same for bitcoin and bitcoinCash
        ImportedAccountKeyContextDerivation(
            xPub: xpub.address,
            priv: priv
        )
    }

    init(coin: UInt32, accountIndex: UInt32, xPub: XPub, priv: String) {
        self.coin = coin
        self.accountIndex = accountIndex
        self.xpubs = [xPub]
        self.priv = priv
        self.xpub = xPub
    }
}

struct AccountKeyContext: AccountKeyContextProtocol {

    fileprivate typealias GetKey = (String) -> WalletCore.PrivateKey

    fileprivate typealias GetXPriv = (WalletCore.Purpose) -> String

    fileprivate typealias GetXPub = (WalletCore.Purpose) -> String

    var xpubs: [XPub] {
        derivations.all
            .map { derivation in
                XPub(
                    address: derivation.xpub,
                    derivationType: derivation.type
                )
            }
    }

    func defaultDerivation(coin: BitcoinChainCoin) -> AccountKeyContextDerivationProtocol {
        switch coin {
        case .bitcoin:
            return derivations.segWit
        case .bitcoinCash:
            return derivations.legacy
        }
    }

    let wallet: WalletCore.HDWallet
    let coin: UInt32
    let accountIndex: UInt32
    let derivations: AccountKeyContextDerivationsProtocol

    fileprivate init(
        wallet: WalletCore.HDWallet,
        coin: UInt32,
        accountIndex: UInt32
    ) {
        self.wallet = wallet
        self.coin = coin
        self.accountIndex = accountIndex
        self.derivations = AccountKeyContextDerivations.create(
            wallet: wallet,
            coin: coin,
            accountIndex: accountIndex,
            getKey: Self.getKey(wallet: wallet, coin: coin),
            getXPriv: Self.getXPriv(wallet: wallet, coin: coin, accountIndex: accountIndex),
            getXPub: Self.getXPub(wallet: wallet, coin: coin, accountIndex: accountIndex)
        )
    }

    private static func getKey(
        wallet: WalletCore.HDWallet,
        coin: UInt32
    ) -> GetKey {
        { derivationPath in
            wallet.getKey(
                coin: CoinType(rawValue: coin)!,
                derivationPath: derivationPath
            )
        }
    }

    private static func getXPriv(
        wallet: WalletCore.HDWallet,
        coin: UInt32,
        accountIndex: UInt32
    ) -> GetXPriv {
        { purpose in
            getHDWalletPK(
                wallet: wallet,
                coin: coin,
                purpose: purpose.rawValue,
                accountIndex: accountIndex
            ).extended()
        }
    }

    private static func getXPub(
        wallet: WalletCore.HDWallet,
        coin: UInt32,
        accountIndex: UInt32
    ) -> GetXPub {
        { purpose in
            getHDWalletPK(
                wallet: wallet,
                coin: coin,
                purpose: purpose.rawValue,
                accountIndex: accountIndex
            ).extendedPublic()
        }
    }

    private static func getHDWalletPK(
        wallet: WalletCore.HDWallet,
        coin: UInt32,
        purpose: UInt32,
        accountIndex: UInt32
    ) -> MetadataHDWalletKit.PrivateKey {
        let masterKey = MetadataHDWalletKit.PrivateKey(seed: wallet.seed, coin: .bitcoin)
        return masterKey
            .derived(at: .hardened(purpose))
            .derived(at: .hardened(coin))
            .derived(at: .hardened(accountIndex))
    }
}

struct ImportedAccountKeyContextDerivation: AccountKeyContextDerivationProtocol {
    var type: DerivationType { .legacy }
    let xpriv: String
    let xpub: String

    init(xPub: String, priv: String) {
        self.xpub = xPub
        self.xpriv = priv
    }

    func accountPrivateKey() -> WalletCore.PrivateKey {
        let privKey = WalletCore.Base58.decodeNoCheck(string: xpriv) ?? Data()
        return WalletCore.PrivateKey(data: privKey)!
    }

    func receivePrivateKey(receiveIndex: UInt32) -> WalletCore.PrivateKey {
        // there's no receiveIndex on imported account
        accountPrivateKey()
    }

    func changePrivateKey(changeIndex: UInt32) -> WalletCore.PrivateKey {
        // there's no changeIndex on imported account
        accountPrivateKey()
    }

    func childKey(with childPath: [WalletCore.DerivationPath.Index]) -> WalletCore.PrivateKey {
        // there's no childKey on imported account
        accountPrivateKey()
    }
}

struct AccountKeyContextDerivation: AccountKeyContextDerivationProtocol {

    private enum Chains {
        static let receive: UInt32 = 0
        static let change: UInt32 = 1
    }

    var xpriv: String {
        getXPriv(type.walletCorePurpose)
    }

    var xpub: String {
        getXPub(type.walletCorePurpose)
    }

    private var purpose: UInt32 {
        type.purpose
    }

    let type: BitcoinChainKit.DerivationType
    let coin: UInt32
    let accountIndex: UInt32

    private let getKey: AccountKeyContext.GetKey
    private let getXPriv: AccountKeyContext.GetXPriv
    private let getXPub: AccountKeyContext.GetXPub

    fileprivate init(
        type: BitcoinChainKit.DerivationType,
        coin: UInt32,
        accountIndex: UInt32,
        getKey: @escaping AccountKeyContext.GetKey,
        getXPriv: @escaping AccountKeyContext.GetXPriv,
        getXPub: @escaping AccountKeyContext.GetXPub
    ) {
        self.type = type
        self.coin = coin
        self.accountIndex = accountIndex
        self.getKey = getKey
        self.getXPriv = getXPriv
        self.getXPub = getXPub
    }

    func accountPrivateKey() -> WalletCore.PrivateKey {
        let purpose = type.purpose
        let path = "m/\(purpose)'/\(coin)'/\(accountIndex)'/"
        return getKey(path)
    }

    func receivePrivateKey(
        receiveIndex: UInt32
    ) -> WalletCore.PrivateKey {
        let purpose = type.purpose
        let path = "m/\(purpose)'/\(coin)'/\(accountIndex)'/\(Chains.receive)/\(receiveIndex)/"
        return getKey(path)
    }

    func changePrivateKey(
        changeIndex: UInt32
    ) -> WalletCore.PrivateKey {
        let purpose = type.purpose
        let path = "m/\(purpose)'/\(coin)'/\(accountIndex)'/\(Chains.change)/\(changeIndex)/"
        return getKey(path)
    }

    func childKey(
        with childPath: [WalletCore.DerivationPath.Index]
    ) -> WalletCore.PrivateKey {
        let purpose = type.purpose

        let accountPath: [WalletCore.DerivationPath.Index] = [
            .init(purpose, hardened: true),
            .init(coin, hardened: true),
            .init(accountIndex, hardened: true)
        ]

        let pathComponents = accountPath + childPath

        let path = pathComponents.reduce(into: "m/") { path, component in
            path += "\(component.description)/"
        }

        return getKey(path)
    }
}

struct ImportedAccountKeyContextDerivations: AccountKeyContextDerivationsProtocol {
    var all: [AccountKeyContextDerivationProtocol] {
        [legacy]
    }

    var segWit: AccountKeyContextDerivationProtocol {
        fatalError("imported address does not have bech32 derivation")
    }

    let legacy: AccountKeyContextDerivationProtocol

    init(legacy: ImportedAccountKeyContextDerivation) {
        self.legacy = legacy
    }
}

struct AccountKeyContextDerivations: AccountKeyContextDerivationsProtocol {

    var all: [AccountKeyContextDerivationProtocol] {
        [legacy, segWit]
    }

    let segWit: AccountKeyContextDerivationProtocol
    let legacy: AccountKeyContextDerivationProtocol

    private init(segWit: AccountKeyContextDerivation, legacy: AccountKeyContextDerivation) {
        self.segWit = segWit
        self.legacy = legacy
    }

    // swiftlint:disable function_parameter_count
    fileprivate static func create(
        wallet: WalletCore.HDWallet,
        coin: UInt32,
        accountIndex: UInt32,
        getKey: @escaping AccountKeyContext.GetKey,
        getXPriv: @escaping AccountKeyContext.GetXPriv,
        getXPub: @escaping AccountKeyContext.GetXPub
    ) -> Self {
        Self(
            segWit: AccountKeyContextDerivation(
                type: .bech32,
                coin: coin,
                accountIndex: accountIndex,
                getKey: getKey,
                getXPriv: getXPriv,
                getXPub: getXPub
            ),
            legacy: AccountKeyContextDerivation(
                type: .legacy,
                coin: coin,
                accountIndex: accountIndex,
                getKey: getKey,
                getXPriv: getXPriv,
                getXPub: getXPub
            )
        )
    }
}

extension DerivationType {

    var walletCorePurpose: WalletCore.Purpose {
        switch self {
        case .legacy:
            return .bip44
        case .bech32:
            return .bip84
        }
    }
}

public typealias WalletMnemonicProvider = () -> AnyPublisher<Mnemonic, Error>

func getAccountKeys(
    for account: BitcoinChainAccount,
    walletMnemonicProvider: WalletMnemonicProvider
) -> AnyPublisher<AccountKeyContextProtocol, Error> {
    walletMnemonicProvider()
        .map { mnemonic in
            getAccountKeyContext(for: account, mnemonic: mnemonic)
        }
        .eraseToAnyPublisher()
}

func getAccountKeyContext(
    for account: BitcoinChainAccount,
    mnemonic: Mnemonic
) -> AccountKeyContextProtocol {
    guard let wallet = WalletCore.HDWallet(mnemonic: mnemonic.words, passphrase: "") else {
        fatalError("Invalid Mnemonic")
    }
    return AccountKeyContext(
        wallet: wallet,
        coin: account.coin.derivationCoinType,
        accountIndex: UInt32(account.index)
    )
}
