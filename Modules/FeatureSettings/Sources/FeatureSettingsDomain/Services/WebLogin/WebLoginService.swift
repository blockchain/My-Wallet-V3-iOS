// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit
import DIKit
import FeatureAuthenticationDomain
import NetworkKit
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit
import WalletPayloadKit

public protocol WebLoginQRCodeServiceAPI: AnyObject {
    var qrCode: Single<String> { get }
}

public final class WebLoginQRCodeService: WebLoginQRCodeServiceAPI {

    // MARK: - Types

    enum ServiceError: Error {
        case missingPassword
    }

    // MARK: - Public Properties

    public var qrCode: Single<String> {
        guid
            .flatMap(weak: self) { (self, guid) -> Single<String> in
                self.qrCode(guid: guid)
            }
    }

    // MARK: - Private Properties

    private let autoPairingService: AutoWalletPairingServiceAPI
    private let walletCryptoService: WalletCryptoServiceAPI
    private let credentialsRepository: CredentialsRepositoryAPI
    private let passwordRepository: PasswordRepositoryAPI

    // MARK: - Setup

    public init(
        autoPairingService: AutoWalletPairingServiceAPI = resolve(),
        walletCryptoService: WalletCryptoServiceAPI = resolve(),
        credentialsRepository: CredentialsRepositoryAPI = resolve(),
        passwordRepository: PasswordRepositoryAPI = resolve()
    ) {
        self.autoPairingService = autoPairingService
        self.walletCryptoService = walletCryptoService
        self.credentialsRepository = credentialsRepository
        self.passwordRepository = passwordRepository
    }

    private var guid: Single<String> {
        credentialsRepository
            .guid
            .asSingle()
            .map {
                guard let guid = $0 else {
                    throw MissingCredentialsError.guid
                }
                return guid
            }
    }

    private func qrCode(guid: String) -> Single<String> {
        autoPairingService
            .encryptionPhrase(using: guid)
            .asSingle()
            .flatMap(weak: self) { (self, encryptionPhrase) -> Single<String> in
                self.encrypteWalletData(with: encryptionPhrase)
            }
            .map { "1|\(guid)|\($0)" }
    }

    private func encrypteWalletData(with encryptionPhrase: String) -> Single<String> {
        Single
            .zip(
                passwordRepository.password.asSingle(),
                credentialsRepository.sharedKey.asSingle()
            )
            .map { password, sharedKey -> (String, String) in
                guard let password else {
                    throw ServiceError.missingPassword
                }
                guard let sharedKey else {
                    throw MissingCredentialsError.sharedKey
                }
                return (password, sharedKey)
            }
            .map { password, sharedKey -> String in
                guard let hexPassword = password.data(using: .utf8)?.hexValue else {
                    throw ServiceError.missingPassword
                }
                return "\(sharedKey)|\(hexPassword)"
            }
            .flatMap(weak: self) { (self, data) in
                self.walletCryptoService.encrypt(
                    pair: KeyDataPair(key: encryptionPhrase, data: data),
                    pbkdf2Iterations: WalletCryptoPBKDF2Iterations.autoPair
                )
                .asObservable()
                .take(1)
                .asSingle()
            }
    }
}
