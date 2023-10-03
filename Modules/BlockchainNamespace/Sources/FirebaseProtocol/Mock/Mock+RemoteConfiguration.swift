// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Mock {

    public struct RemoteConfiguration: RemoteConfiguration_p {

        public let data: [RemoteConfigurationSource: [String: RemoteConfigurationValue]]

        public init(
            _ data: [RemoteConfigurationSource: [String: RemoteConfigurationValue]] = [:]
        ) {
            self.data = data
        }

        private var __data: [String: RemoteConfigurationValue] {
            data.values.reduce(into: [:]) { sum, next in
                sum.merge(next, uniquingKeysWith: { $1 })
            }
        }

        public func fetch(
            withExpirationDuration expirationDuration: TimeInterval,
            completionHandler: ((RemoteConfigurationFetchStatus, Error?) -> Void)?
        ) {
            completionHandler?(.success, nil)
        }

        public func activate(completion: ((Bool, Error?) -> Void)?) {
            DispatchQueue.global().async {
                completion?(true, nil)
            }
        }

        public func allKeys(from source: RemoteConfigurationSource) -> [String] {
            Array(data[source, default: [:]].keys)
        }

        public subscript(key: String) -> RemoteConfigurationValue {
            __data[key] ?? .init(dataValue: Data())
        }

        public func addOnConfigUpdateListener(
            remoteConfigUpdateCompletion listener: @escaping (RemoteConfigUpdate?, Error?) -> Void
        ) -> ConfigUpdateListenerRegistration {
            return ConfigUpdateListenerRegistration()
        }
    }

    public struct RemoteConfigUpdate: RemoteConfigUpdate_p {
        public var updatedKeys: Set<String>
    }

    public class ConfigUpdateListenerRegistration: ConfigUpdateListenerRegistration_p {
        public func remove() { }
    }

    public struct RemoteConfigurationValue: RemoteConfigurationValue_p {
        public init(dataValue: Data) {
            self.dataValue = dataValue
        }

        public var dataValue: Data
    }

    public enum RemoteConfigurationSource: RemoteConfigurationSource_p {
        case remote
        case `default`
        case `static`
    }

    public enum RemoteConfigurationFetchStatus: RemoteConfigurationFetchStatus_p {
        case noFetchYet
        case success
        case failure
        case throttled
    }
}

// swiftlint:disable force_try

extension Mock.RemoteConfigurationValue: ExpressibleByBooleanLiteral {

    public init(booleanLiteral value: Bool) {
        dataValue = try! JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed)
    }
}

extension Mock.RemoteConfigurationValue: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        dataValue = try! JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed)
    }
}

extension Mock.RemoteConfigurationValue: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: Any...) {
        dataValue = try! JSONSerialization.data(withJSONObject: elements)
    }
}

extension Mock.RemoteConfigurationValue: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        dataValue = try! JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed)
    }
}

extension Mock.RemoteConfigurationValue: ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: (String, Any)...) {
        dataValue = try! JSONSerialization.data(withJSONObject: Dictionary(uniqueKeysWithValues: elements))
    }
}

extension Mock.RemoteConfigurationValue: ExpressibleByFloatLiteral {

    public init(floatLiteral value: Double) {
        dataValue = try! JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed)
    }
}
