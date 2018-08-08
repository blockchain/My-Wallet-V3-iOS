//
//  SocketMessage.swift
//  Blockchain
//
//  Created by kevinwu on 8/3/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum SocketType: String {
    case unassigned
    case exchange
    case bitcoin
    case ether
    case bitcoinCash
}

struct SocketMessage {
    let type: SocketType
    let JSONMessage: Codable
}

protocol SocketMessageCodable: Codable {
    associatedtype JSONType: Codable
    static func tryToDecode(
        data: Data,
        onSuccess: (SocketMessage) -> Void,
        onError: () -> Void
    )
}

extension SocketMessageCodable {
    static func tryToDecode(
        data: Data,
        onSuccess: (SocketMessage) -> Void,
        onError: () -> Void
    ) {
        do {
            let decoded = try JSONType.decode(data: data)
            let socketMessage = SocketMessage(type: .unassigned, JSONMessage: decoded)
            onSuccess(socketMessage)
            return
        } catch {
            onError()
        }
    }
}

// TODO: consider separate files when other socket types are added
// TODO: add tests when parameters are figured out
struct Quote: SocketMessageCodable {
    typealias JSONType = Quote

    let parameterOne: String

    private enum CodingKeys: String, CodingKey {
        case parameterOne
    }
}

struct Rate: SocketMessageCodable {
    typealias JSONType = Rate

    let parameterOne: String

    private enum CodingKeys: String, CodingKey {
        case parameterOne
    }
}
