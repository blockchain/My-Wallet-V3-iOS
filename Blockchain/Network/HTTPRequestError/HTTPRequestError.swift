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

// TODO: add more specific client errors based on the error returned by URLSession data task
// NOTE: the description argument refers to the localized description returned by URLSession data task.
enum HTTPRequestClientError: HTTPRequestError {
    case failedRequest(description: String)
    var debugDescription: String {
        switch self {
        case .failedRequest(let description): return description
        }
    }
}
enum HTTPRequestServerError: HTTPRequestError {
    case badResponse, badStatusCode(code: Int, error: Error?)
    var debugDescription: String {
        switch self {
        case .badResponse: return "Bad response."
        case .badStatusCode(let code, _): return "The server returned a bad response: \(code)."
        }
    }
}

// NOTE: in future cases, we may want to allow empty payloads, but this is currently not applicable for the KYC flow.
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
