// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol AnalyticsEvent {
    var timestamp: Date? { get }
    var name: String { get }
    var params: [String: Any]? { get }
    var type: AnalyticsEventType { get }
}

extension AnalyticsEvent {
    public var type: AnalyticsEventType {
        .firebase
    }

    public var timestamp: Date? {
        nil
    }

    public var name: String {
        defaultName
    }

    public var defaultName: String {
        (Mirror(reflecting: self).children.first?.label ?? String(describing: self)).camelCaseToSpaceCase()
    }

    public var params: [String: Any]? {
        guard type == .nabu else {
            return nil
        }
        var params = [String: Any]()
        let reflection = Mirror(reflecting: self)
        guard reflection.displayStyle == .enum, let associated = reflection.children.first else {
            return params
        }
        Mirror(reflecting: associated.value).children
            .forEach {
                if let encodable = $0.value as? AnalyticsEventParameters {
                    do {
                        try params.merge(encodable.encode(), uniquingKeysWith: { $1 })
                    } catch {
                        assertionFailure("Failed to encode parameters: \(error)")
                    }
                } else if let label = $0.label?.camelCaseToSnakeCase() {
                    if let value = $0.value as? StringRawRepresentable {
                        params[label] = value.rawValue
                    } else {
                        params[label] = $0.value
                    }
                }
            }
        return params
    }
}

public protocol StringRawRepresentable {
    var rawValue: String { get }
}

public protocol AnalyticsEventParameters: Encodable {}

enum AnalyticsEventParameterEncodingError: Error {
    case typeMismatch(expected: Any.Type, actual: Any.Type)
}

extension AnalyticsEventParameters {

    func encode(
        using encoder: JSONEncoder = JSONEncoder(keyEncodingStrategy: .convertToSnakeCase)
    ) throws -> [String: Any] {
        let data = try encoder.encode(self)
        let json = try JSONSerialization.jsonObject(with: data)
        guard let paramaters = json as? [String: Any] else {
            throw AnalyticsEventParameterEncodingError.typeMismatch(
                expected: [String: Any].self,
                actual: type(of: json)
            )
        }
        return paramaters
    }
}

extension JSONEncoder {

    convenience init(keyEncodingStrategy: KeyEncodingStrategy) {
        self.init()
        self.keyEncodingStrategy = keyEncodingStrategy
    }
}

extension String {
    private var acronymPattern: String {
        "([A-Z]+)([A-Z][a-z]|[0-9])"
    }

    private var fullWordsPattern: String {
        "([a-z])([A-Z]|[0-9])"
    }

    private var digitsFirstPattern: String {
        "([0-9])([A-Z])"
    }

    fileprivate func camelCaseToSnakeCase() -> String {
        let template = "$1_$2"
        return processCamelCaseRegex(pattern: acronymPattern, withTemplate: template)?
            .processCamelCaseRegex(pattern: fullWordsPattern, withTemplate: template)?
            .processCamelCaseRegex(pattern: digitsFirstPattern, withTemplate: template)?
            .lowercased() ?? lowercased()
    }

    fileprivate func camelCaseToSpaceCase() -> String {
        let template = "$1 $2"
        return capitalizingFirstLetter()
            .processCamelCaseRegex(pattern: acronymPattern, withTemplate: template)?
            .processCamelCaseRegex(pattern: fullWordsPattern, withTemplate: template)?
            .processCamelCaseRegex(pattern: digitsFirstPattern, withTemplate: template) ?? self
    }

    private func processCamelCaseRegex(pattern: String, withTemplate: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: withTemplate)
    }

    private func capitalizingFirstLetter() -> String {
        prefix(1).capitalized + dropFirst()
    }
}
