//
//  KYCAuthenticationAPI.swift
//  Blockchain
//
//  Created by kevinwu on 8/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class KYCAuthenticationAPI {

    private struct Keys {
        static let email = "email"
        static let guid = "walletGuid"
        static let userId = "userId"
    }

    static func createUser(
        email: String,
        guid: String,
        success: @escaping (String) -> Void,
        error: @escaping (HTTPRequestError) -> Void
    ) {
        let taskSuccess: (Data) -> Void = { data in
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? JSON else {
                    Logger.shared.error("Could not create JSON from data")
                    return
                }
                guard let userId = json[Keys.userId] as? String else {
                    Logger.shared.error("Could not get userId from data")
                    return
                }
                success(userId)
            } catch {
                Logger.shared.error("Could not create JSON from data")
            }
        }
        KYCNetworkRequest(
            post: KYCNetworkRequest.KYCEndpoints.POST.registerUser,
            parameters: [Keys.email: email, Keys.guid: guid],
            taskSuccess: taskSuccess,
            taskFailure: error
        )
    }

    static func getApiKey(
        userId: String,
        success: @escaping (Data) -> Void,
        error: @escaping (HTTPRequestError) -> Void
    ) {
        KYCNetworkRequest(
            post: KYCNetworkRequest.KYCEndpoints.POST.apiKey,
            parameters: [Keys.userId: userId],
            taskSuccess: success,
            taskFailure: error
        )
    }

    static func getSessionToken(
        userId: String,
        success: @escaping (Data) -> Void,
        error: @escaping (HTTPRequestError) -> Void
        ) {
        KYCNetworkRequest(
            post: KYCNetworkRequest.KYCEndpoints.POST.sessionToken,
            parameters: [Keys.userId: userId],
            taskSuccess: success,
            taskFailure: error
        )
    }
}
