// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyData
import DelegatedSelfCustodyDomain
import DIKit
import FeatureAuthenticationDomain
import MoneyKit
import PlatformKit
import WalletCore
import WalletPayloadKit

// MARK: - Blockchain Module

extension DependencyContainer {

    static var blockchainDelegatedSelfCustody = module {
        factory { () -> DelegatedCustodyDerivationServiceAPI in
            DelegatedCustodyDerivationService(mnemonicAccess: DIKit.resolve())
        }
        factory { () -> DelegatedCustodyFiatCurrencyServiceAPI in
            DelegatedCustodyFiatCurrencyService(service: DIKit.resolve())
        }
        factory { () -> DelegatedCustodyGuidServiceAPI in
            DelegatedCustodyGuidService(service: DIKit.resolve())
        }
        factory { () -> DelegatedCustodySharedKeyServiceAPI in
            DelegatedCustodySharedKeyService(service: DIKit.resolve())
        }
        factory { () -> DelegatedCustodySigningServiceAPI in
            DelegatedCustodySigningService()
        }
    }
}

final class DelegatedCustodyFiatCurrencyService: DelegatedCustodyFiatCurrencyServiceAPI {

    private let service: FiatCurrencyServiceAPI

    init(service: FiatCurrencyServiceAPI) {
        self.service = service
    }

    var fiatCurrency: AnyPublisher<FiatCurrency, Never> {
        service.displayCurrencyPublisher
    }
}

final class DelegatedCustodyGuidService: DelegatedCustodyGuidServiceAPI {

    private let service: GuidRepositoryAPI

    init(service: GuidRepositoryAPI) {
        self.service = service
    }

    var guid: AnyPublisher<String?, Never> {
        service.guid
    }
}

final class DelegatedCustodySharedKeyService: DelegatedCustodySharedKeyServiceAPI {

    private let service: SharedKeyRepositoryAPI

    init(service: SharedKeyRepositoryAPI) {
        self.service = service
    }

    var sharedKey: AnyPublisher<String?, Never> {
        service.sharedKey
    }
}

enum DelegatedCustodyDerivationServiceError: Error {
    case failed
}

final class DelegatedCustodyDerivationService: DelegatedCustodyDerivationServiceAPI {

    private let mnemonicAccess: MnemonicAccessAPI

    init(mnemonicAccess: MnemonicAccessAPI) {
        self.mnemonicAccess = mnemonicAccess
    }

    func getKeys(
        path: String
    ) -> AnyPublisher<(publicKey: Data, privateKey: Data), Error> {
        let mnemonic: AnyPublisher<WalletPayloadKit.Mnemonic, MnemonicAccessError> = mnemonicAccess.mnemonic
        return mnemonic
            .map { mnemonic -> (publicKey: Data, privateKey: Data)? in
                guard let wallet = WalletCore.HDWallet(mnemonic: mnemonic, passphrase: "") else {
                    return nil
                }
                let privateKey = wallet.getKey(coin: .bitcoin, derivationPath: path)
                let publicKey = privateKey.getPublicKeySecp256k1(compressed: true)
                return (publicKey: publicKey.data, privateKey: privateKey.data)
            }
            .eraseError()
            .onNil(DelegatedCustodyDerivationServiceError.failed)
            .eraseError()
            .eraseToAnyPublisher()
    }
}

final class DelegatedCustodySigningService: DelegatedCustodySigningServiceAPI {

    func sign(
        data: Data,
        privateKey: Data,
        algorithm: DelegatedCustodySignatureAlgorithm
    ) -> Result<Data, DelegatedCustodySigningError> {
        switch algorithm {
        case .secp256k1:
            return signSecp256k1(data: data, privateKey: privateKey)
        }
    }

    private func signSecp256k1(
        data: Data,
        privateKey: Data
    ) -> Result<Data, DelegatedCustodySigningError> {
        guard let pk = WalletCore.PrivateKey(data: privateKey) else {
            return .failure(.failed)
        }
        guard let signed = pk.sign(digest: data, curve: .secp256k1) else {
            return .failure(.failed)
        }
        return .success(signed)
    }
}
