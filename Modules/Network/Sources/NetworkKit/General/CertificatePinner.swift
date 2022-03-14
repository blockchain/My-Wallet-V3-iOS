// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import ToolKit

protocol CertificateProviderAPI: AnyObject {

    var certificateData: Data? { get }
}

final class CertificateProvider: CertificateProviderAPI {
    var certificateData: Data? {
        guard let certificateURL = localCertificateURL else {
            return nil
        }
        return try? Data(contentsOf: certificateURL)
    }

    /// Path to the local certificate file
    private lazy var localCertificateURL: URL? = MainBundleProvider.mainBundle.url(forResource: "blockchain", withExtension: "der")
}

public protocol CertificatePinnerAPI: AnyObject {

    func pinCertificateIfNeeded()

    func didReceive(_ challenge: URLAuthenticationChallenge, completion: @escaping AuthChallengeHandler)
}

final class CertificatePinner: CertificatePinnerAPI {

    // MARK: - Types

    private enum CertificatePinnerError: Error {
        case failedPreValidation
        case certificatesNotEqual
    }

    // MARK: - Properties

    /// Certificate Data

    private let blockchainAPI: BlockchainAPI
    private let certificateProvider: CertificateProviderAPI
    private let session: URLSession

    // MARK: - Initialization

    init(
        session: URLSession = resolve(),
        blockchainAPI: BlockchainAPI = resolve(),
        certificateProvider: CertificateProviderAPI = resolve()
    ) {
        self.blockchainAPI = blockchainAPI
        self.certificateProvider = certificateProvider
        self.session = session
    }

    func pinCertificateIfNeeded() {
        guard blockchainAPI.shouldPinCertificate else {
            return
        }
        let walletUrl = blockchainAPI.walletUrl
        guard let url = URL(string: walletUrl) else {
            fatalError("Failed to get wallet url from Bundle.")
        }
        session.sessionDescription = url.host
        // TODO: inject NetworkCommunicator
        let task = session.dataTask(with: url) { _, _, _ in }
        task.resume()
    }

    func didReceive(_ challenge: URLAuthenticationChallenge, completion: @escaping AuthChallengeHandler) {
        respond(to: challenge, completion: completion)
    }

    private func respond(to challenge: URLAuthenticationChallenge, completion: AuthChallengeHandler) {
        let policy = SecPolicyCreateBasicX509()
        var localTrust: SecTrust?

        guard
            let serverTrust = challenge.protectionSpace.serverTrust,
            let certificateData = certificateProvider.certificateData,
            let localCertificate = SecCertificateCreateWithData(kCFAllocatorDefault, certificateData as NSData),
            SecTrustCreateWithCertificates(localCertificate, policy, &localTrust) == errSecSuccess
        else {
            Logger.shared.error(CertificatePinnerError.failedPreValidation)
            completion(.cancelAuthenticationChallenge, nil)
            return
        }

        let localPublicKey = SecTrustCopyKey(localTrust!)
        let serverPublicKey = SecTrustCopyKey(serverTrust)
        if (localPublicKey as AnyObject).isEqual(serverPublicKey as AnyObject) {
            let credential = URLCredential(trust: serverTrust)
            completion(.useCredential, credential)
        } else {
            Logger.shared.error(CertificatePinnerError.certificatesNotEqual)
            completion(.cancelAuthenticationChallenge, nil)
        }
    }
}
