//
//  CertificatePinner.swift
//  Blockchain
//
//  Created by Maurice A. on 4/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/**
 Handles certificate pinning for connections to blockchain.info.
 # Usage
 TBD
 - Author: Maurice Achtenhagen
 - Copyright: Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
 */
@objc
final class CertificatePinner: NSObject {

    // MARK: - Properties

    /// The instance variable used to access functions of the `CertificatePinner` class.
    static let shared = CertificatePinner()

    // TODO: remove once migration is complete
    /// Objective-C compatible class function
    @objc class func sharedInstance() -> CertificatePinner {
        return CertificatePinner.shared
    }

    /// Path to the local certificate file
    @objc var localCertificatePath: String? {
        guard
            let infoDictionary = Bundle.main.infoDictionary,
            let certificateFile = infoDictionary["LOCAL_CERTIFICATE_FILE"] as? String,
            let path = Bundle.main.path(forResource: certificateFile, ofType: "der", inDirectory: "Cert") else {
                return nil
        }
        return path
    }

    // MARK: - Initialization

    //: Prevent outside objects from creating their own instances of this class.
    private override init() {
        super.init()
    }

    func pinCertificate() {
        guard
            let walletUrl = BlockchainAPI.shared.walletUrl,
            let url = URL(string: walletUrl) else {
                fatalError("Failed to get wallet url from Bundle.")
        }
        NetworkManager.shared.session.sessionDescription = url.host
        let task = NetworkManager.shared.session.dataTask(with: url) { data, response, error in
            if let transportError = error {
                self.handleClientError(transportError)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    self.handleServerError(response!)
                    return
            }
        }
        task.resume()
    }

    private func handleClientError(_ error: Error) {

    }

    private func handleServerError(_ response: URLResponse) {

    }

    @objc
    func didReceive(_ challenge: URLAuthenticationChallenge, completion: @escaping AuthChallengeHandler) {
        respond(to: challenge, completion: completion)
    }

    private func respond(to challenge: URLAuthenticationChallenge, completion: AuthChallengeHandler) {
        var localTrust: SecTrust?
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completion(.cancelAuthenticationChallenge, nil)
            return
        }

        guard
            let certificatePath = localCertificatePath,
            let certificateData = NSData(contentsOfFile: certificatePath),
            let localCertificate = SecCertificateCreateWithData(kCFAllocatorDefault, certificateData) else {
                completion(.cancelAuthenticationChallenge, nil)
                return
        }

        let policy = SecPolicyCreateBasicX509()

        // Public key pinning check
        if SecTrustCreateWithCertificates(localCertificate, policy, &localTrust) == errSecSuccess {
            let localPublicKey = SecTrustCopyPublicKey(localTrust!)
            let serverPublicKey = SecTrustCopyPublicKey(serverTrust)
            if (localPublicKey as AnyObject).isEqual(serverPublicKey as AnyObject) {
                let credential = URLCredential(trust: serverTrust)
                completion(.useCredential, credential)
            } else {
                didFailToValidate()
                completion(.cancelAuthenticationChallenge, nil)
            }
        }
    }

    // TODO: implement when required changes are merged into `swift` branch.
    func didFailToValidate() {

    }
}
