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
        static let guid = "guid"
        static let userId = "userId"
    }

    static func createUser(
        email: String,
        guid: String,
        success: @escaping (String, String) -> Void,
        error: @escaping (HTTPRequestError) -> Void
    ) {
        let taskSuccess: (Data) -> Void = { data in
            // get the userId and lifetime token from the data
            success("userId", "lifetimeToken")
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
