//
//  HttpHeader.swift
//  Blockchain
//
//  Created by kevinwu on 8/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct HttpHeaderField {
    public static let userAgent = "User-Agent"
    public static let accept = "Accept"
    public static let contentLength = "Content-Length"
    public static let contentType = "Content-Type"
    public static let authorization = "Authorization"
    public static let appVersion = "X-APP-VERSION"
    public static let clientType = "X-CLIENT-TYPE"
    public static let walletGuid = "X-WALLET-GUID"
    public static let walletEmail = "X-WALLET-EMAIL"
    public static let deviceId = "X-DEVICE-ID"
}

public struct HttpHeaderValue {
    public static let json = "application/json"
    public static let formEncoded = "application/x-www-form-urlencoded"
    public static let clientTypeApp = "APP"
}
