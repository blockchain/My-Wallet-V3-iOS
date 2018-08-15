//
//  HttpHeader.swift
//  Blockchain
//
//  Created by kevinwu on 8/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct HttpHeaderField {
    static let userAgent = "User-Agent"
    static let accept = "Accept"
    static let contentLength = "Content-Length"
    static let contentType = "Content-Type"
    static let authorization = "Authorization"
}

struct HttpHeaderValue {
    static let json = "application/json"
    static let formEncoded = "application/x-www-form-urlencoded"
}
