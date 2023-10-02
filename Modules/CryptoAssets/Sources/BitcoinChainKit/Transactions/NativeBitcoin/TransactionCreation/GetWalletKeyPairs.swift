// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit
import ToolKit
import WalletCore
import WalletPayloadKit

func getWalletKeyPairs(
    unspentOutputs: [UnspentOutput],
    accountKeyContext: AccountKeyContextProtocol
) -> [WalletKeyPair] {
    unspentOutputs
        .compactMap { utxo -> (UnspentOutput, WalletCoreKeyPair)? in
            let walletCoreKeyPair = try? walletCoreKeyPair(
                for: utxo,
                context: accountKeyContext
            ).get()
            guard let keyPair = walletCoreKeyPair else {
                return nil
            }
            return (utxo, keyPair)
        }
        .map { utxo, walletCoreKeyPair -> WalletKeyPair in
            WalletKeyPair(
                xpriv: walletCoreKeyPair.xpriv,
                privateKeyData: walletCoreKeyPair.privateKeyData,
                xpub: XPub(
                    address: walletCoreKeyPair.xpub,
                    derivationType: utxo.isSegwit ? .bech32 : .legacy
                )
            )
        }
}

public struct WalletCoreKeyPair {

    public var privateKeyData: Data {
        privateKey.data
    }

    public let privateKey: WalletCore.PrivateKey
    public let xpriv: String
    public let xpub: String

    public init(
        privateKey: PrivateKey,
        xpriv: String,
        xpub: String
    ) {
        self.privateKey = privateKey
        self.xpriv = xpriv
        self.xpub = xpub
    }
}

private func walletCoreKeyPair(
    for unspentOutput: UnspentOutput,
    context: AccountKeyContextProtocol
) -> Result<WalletCoreKeyPair, GetWalletKeysError> {
    derivationPathComponents(for: unspentOutput)
        .map { childKeyPath -> WalletCoreKeyPair in
            let derivation = context.derivations.all
                .first(where: { derivation in
                    derivation.xpub == unspentOutput.xpub?.m
                })!
            return WalletCoreKeyPair(
                privateKey: derivation.childKey(with: childKeyPath),
                xpriv: derivation.xpriv,
                xpub: derivation.xpub
            )
        }
}

enum GetWalletKeysError: Error {
    case failedToReadDerivationPath
}

func derivationPathComponents(
    for unspentOutput: UnspentOutput
) -> Result<[WalletCore.DerivationPath.Index], GetWalletKeysError> {
    guard let xpub = unspentOutput.xpub else {
        return .failure(.failedToReadDerivationPath)
    }
    return .success(xpub.walletCoreComponents)
}

extension UnspentOutput.XPub {
    fileprivate var walletCoreComponents: [WalletCore.DerivationPath.Index] {
        path
            .removing(prefix: "M/")
            .components(separatedBy: "/")
            .compactMap(UInt32.init)
            .map { intValue in
                WalletCore.DerivationPath.Index(intValue, hardened: false)
            }
    }
}
