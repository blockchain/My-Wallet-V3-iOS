// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import ToolKit
import WalletPayloadKit

public enum AutoWalletPairingServiceError: Error {
    case networkError(NetworkError)
    case walletCryptoServiceError(Error)
    case parsingError(SharedKeyParsingServiceError)
    case walletPayloadServiceError(WalletPayloadServiceError)
}

/// A service API for auto pairing
public protocol AutoWalletPairingServiceAPI: AnyObject {

    /// Maps a QR pairing code of a wallet into its password, retrieve and cache the wallet data.
    /// Finally returns the password of the wallet
    /// 1. Receives a pairing code (guid, encrypted shared-key)
    /// 2. Sends the wallet `guid` -> receives a passphrase that can be used to decrypt the shared key.
    /// 3. Decrypt the shared key
    /// 4. Parse the shared key and the password
    /// 5. Request the wallet payload using the wallet GUID and the shared key
    /// 6. Returns the password.
    /// - Parameter pairingData: A pairing code comprises GUID and an encrypted shared key.
    /// - Returns: The wallet password - decrypted and ready for usage.
    func pair(using pairingData: PairingData) -> AnyPublisher<String, AutoWalletPairingServiceError>
    /// Gets encryptionPhrase
    func encryptionPhrase(using guid: String) -> AnyPublisher<String, AutoWalletPairingServiceError>
}

/// A service that is responsible for the auto pairing process
final class AutoWalletPairingService: AutoWalletPairingServiceAPI {

    // MARK: - Properties

    private let walletPairingRepository: AutoWalletPairingRepositoryAPI
    private let walletCryptoService: WalletCryptoServiceAPI
    private let walletPayloadService: WalletPayloadServiceAPI
    private let parsingService: SharedKeyParsingService

    // MARK: - Setup

    init(
        walletPayloadService: WalletPayloadServiceAPI,
        walletPairingRepository: AutoWalletPairingRepositoryAPI,
        walletCryptoService: WalletCryptoServiceAPI,
        parsingService: SharedKeyParsingService
    ) {
        self.walletPayloadService = walletPayloadService
        self.walletPairingRepository = walletPairingRepository
        self.walletCryptoService = walletCryptoService
        self.parsingService = parsingService
    }

    func pair(using pairingData: PairingData) -> AnyPublisher<String, AutoWalletPairingServiceError> {
        walletPairingRepository
            .pair(using: pairingData)
            .map {
                KeyDataPair<String, String>(
                    key: $0,
                    data: pairingData.encryptedSharedKey
                )
            }
            .flatMap { [walletCryptoService] keyDataPair -> AnyPublisher<String, AutoWalletPairingServiceError> in
                walletCryptoService.decrypt(pair: keyDataPair, pbkdf2Iterations: WalletCryptoPBKDF2Iterations.autoPair)
                    .mapError(AutoWalletPairingServiceError.walletCryptoServiceError)
                    .eraseToAnyPublisher()
            }
            .map { [parsingService] pairingCode
                -> Result<KeyDataPair<String, String>, AutoWalletPairingServiceError> in
                parsingService.parse(pairingCode: pairingCode)
                    .mapError(AutoWalletPairingServiceError.parsingError)
            }
            .flatMap { [walletPayloadService] pairResult
                -> AnyPublisher<String, AutoWalletPairingServiceError> in
                switch pairResult {
                case .success(let pair):
                    walletPayloadService.request(
                        guid: pairingData.guid,
                        sharedKey: pair.data
                    )
                    .map { _ in pair.key }
                    .mapError(AutoWalletPairingServiceError.walletCryptoServiceError)
                    .eraseToAnyPublisher()
                case .failure(let error):
                    .failure(error)
                }
            }
            .eraseToAnyPublisher()
    }

    func encryptionPhrase(
        using guid: String
    ) -> AnyPublisher<String, AutoWalletPairingServiceError> {
        walletPairingRepository.encryptionPhrase(using: guid)
    }
}
