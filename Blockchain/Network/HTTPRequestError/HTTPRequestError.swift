//
//  HTTPRequestError.swift
//  Blockchain
//
//  Created by Maurice A. on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol HTTPRequestError: Error {
    var debugDescription: String { get }
}

protocol HTTPRequestErrorDelegate: class {
    func handleClientError(_ error: Error)
    func handleServerError(_ error: HTTPURLResponseError)
    func handlePayloadError(_ error: HTTPRequestPayloadError)
}

enum HTTPURLResponseError: HTTPRequestError {
    case badResponse, badStatusCode(code: Int)
    var debugDescription: String {
        switch self {
        case .badResponse: return "Bad response."
        case .badStatusCode(let code): return "The server returned a bad response: \(code)."
        }
    }
}

// TODO: use protocol extension to add KYC specific error codes 💭
enum HTTPRequestPayloadError: HTTPRequestError {
    case badData, emptyData, invalidMimeType(type: String)
    var debugDescription: String {
        switch self {
        case .badData: return "The data returned by the server was bad."
        case .emptyData: return "The data returned by the server was empty."
        case .invalidMimeType(let type): return "The server returned an invalid MIME type: \(type)."
        }
    }
}
