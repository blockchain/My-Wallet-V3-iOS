// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A special enum that is useful for cases where you need
/// a `Void` value but also want to conform to `Equatable`
public enum EmptyValue: Equatable, Codable {
    case noValue
}
