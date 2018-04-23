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
        if #available(iOS 11.0, *) {
            sessionConfiguration.waitsForConnectivity = true
        }
        session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
    }

    // MARK: - URLSessionDelegate

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {}

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping AuthChallengeHandler) {
        let host = challenge.protectionSpace.host
        print("Received challenge from \(host)")
        if API.Endpoints.rawValues.contains(host) {
            completionHandler(.performDefaultHandling, nil)
        } else {
            CertificatePinner.shared.didReceive(challenge, completion: completionHandler)
        }
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {}
}
