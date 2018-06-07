//
//  NetworkManager.swift
//  Blockchain
//
//  Created by Maurice A. on 4/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

typealias AuthChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void

/**
 Manages network related tasks such as requests and sessions.
 # Usage
 TBD
 - Author: Maurice Achtenhagen
 - Copyright: Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
 */

@objc
final class NetworkManager: NSObject, URLSessionDelegate {

    // MARK: - Properties

    /// The instance variable used to access functions of the `NetworkManager` class.
    static let shared = NetworkManager()

    // TODO: remove once migration is complete
    /// Objective-C compatible class function
    @objc class func sharedInstance() -> NetworkManager {
        return NetworkManager.shared
    }

    @objc var session: URLSession!

    fileprivate var sessionConfiguration: URLSessionConfiguration!

    // MARK: - Initialization

    //: Prevent outside objects from creating their own instances of this class.
    private override init() {
        super.init()
        sessionConfiguration = URLSessionConfiguration.default
        if let userAgent = NetworkManager.userAgent {
            sessionConfiguration.httpAdditionalHeaders = ["User-Agent": userAgent]
        }
        if #available(iOS 11.0, *) {
            sessionConfiguration.waitsForConnectivity = true
        }
        session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        disableUIWebViewCaching()
        persistServerSessionIDForNewUIWebViews()
    }

    func getWalletOptions(withCompletion success: @escaping (_ response: WalletOptions?) -> Void, error: @escaping(_ error: String?) -> Void) {
        guard
            let walletOptionsUrl = BlockchainAPI.shared.walletOptionsUrl,
            let url = URL(string: walletOptionsUrl) else {
                fatalError("Failed to get wallet options url from Bundle.")
        }
        NetworkManager.shared.session.sessionDescription = url.host
        let task = NetworkManager.shared.session.dataTask(with: url) { data, _, taskError in
            DispatchQueue.main.async {
                guard taskError == nil else {
                    error(LocalizationConstants.Errors.requestFailedCheckConnection)
                    return
                }
                guard let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] else {
                    error(LocalizationConstants.Errors.invalidServerResponse)
                    return
                }
                success(WalletOptions(response: json!))
            }
        }
        task.resume()
    }

    /// Check for maintenance flag in wallet-options.
    ///
    /// - Parameter handler: takes an String argument as a response. If the response is non-nil,
    ///  it is assumed that the user should not proceed due to server maintenance.
    func checkForMaintenance(withCompletion handler: @escaping (_ response: String?) -> Void) {
        getWalletOptions(withCompletion: { walletOptions in
            guard let walletOptions = walletOptions else {
                handler(LocalizationConstants.Errors.invalidServerResponse)
                return
            }
            if walletOptions.downForMaintenance == true {
                guard let message = walletOptions.mobileInfo?.message else {
                    handler(LocalizationConstants.Errors.invalidServerResponse)
                    return
                }
                handler(message)
                return
            }
            handler(nil)
        }, error: handler)
    }

    // MARK: - URLSessionDelegate

    // TODO: find place to put UIApplication.shared.isNetworkActivityIndicatorVisible

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {}

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping AuthChallengeHandler) {
        let host = challenge.protectionSpace.host
        print("Received challenge from \(host)")
        if BlockchainAPI.Endpoints.rawValues.contains(host) ||
            BlockchainAPI.PartnerEndpoints.rawValues.contains(host) {
            completionHandler(.performDefaultHandling, nil)
        } else {
            CertificatePinner.shared.didReceive(challenge, completion: completionHandler)
        }
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {}

    // MARK: - Private Functions

    fileprivate func persistServerSessionIDForNewUIWebViews() {
        let cookieStorage = HTTPCookieStorage.shared
        cookieStorage.cookieAcceptPolicy = .always
    }

    fileprivate func disableUIWebViewCaching() {
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
    }
}
