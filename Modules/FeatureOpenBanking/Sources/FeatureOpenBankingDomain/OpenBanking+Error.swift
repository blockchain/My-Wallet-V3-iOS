// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain

extension OpenBanking {

    public enum Error: Swift.Error, Equatable, Hashable {
        case message(String)
        case code(String)
        case ux(UX.Dialog)
        case namespace(FetchResult.Error)
        case other(Swift.Error)
        case timeout
    }
}

extension OpenBanking.Error: ExpressibleByError, CustomStringConvertible {

    public init(_ error: some Error) {
        switch error {
        case let error as OpenBanking.Error:
            self = error
        case let error as UX.Dialog:
            self = .ux(error)
        case let error as FetchResult.Error:
            self = .namespace(error)
        case let error:
            self = .other(error)
        }
    }

    public var any: Error {
        switch self {
        case .message, .code, .timeout, .ux:
            self
        case .namespace(let error):
            error
        case .other(let error):
            error
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: any))
    }

    public static func == (lhs: OpenBanking.Error, rhs: OpenBanking.Error) -> Bool {
        String(describing: lhs.any) == String(describing: rhs.any)
    }

    public var code: String? {
        switch self {
        case .timeout, .message, .namespace, .other, .ux:
            nil
        case .code(let code):
            code
        }
    }

    public var description: String {
        switch self {
        case .timeout:
            "timeout"
        case .ux(let error):
            """
            \(error.title)
            \(error.message)
            """
        case .message(let description), .code(let description):
            description
        case .namespace(let error):
            String(describing: error)
        case .other(let error):
            switch error {
            case let error as CustomStringConvertible:
                error.description
            default:
                "\(error)"
            }
        }
    }

    public var localizedDescription: String { description }
}

extension OpenBanking.Error: Codable {

    public init(from decoder: Decoder) throws {
        do {
            self = try .ux(UX.Dialog(from: decoder))
        } catch {
            self = try .code(String(from: decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .ux(let ux):
            try ux.encode(to: encoder)
        case .code(let code):
            try code.encode(to: encoder)
        default:
            throw EncodingError.invalidValue(
                self,
                .init(
                    codingPath: encoder.codingPath,
                    debugDescription: "Cannot encode error of type \(String(describing: self))"
                )
            )
        }
    }
}

extension OpenBanking.Error: TimeoutFailure {}
