// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

/// Accessibility construct that to support multiple accessibility assignments at once
public struct Accessibility {

    /// The accessibility identifier
    public let id: String?

    /// The accessibility label
    public let label: String?

    /// The accessibility hint
    public let hint: String?

    /// The accessibility traits of the view
    public let traits: UIAccessibilityTraits

    /// Is accessibility element
    public let isAccessible: Bool

    /// Initializes inner properties by defaulting all parameters to `nil`.
    public init(
        id: String? = .none,
        label: String? = .none,
        hint: String? = .none,
        traits: UIAccessibilityTraits = .none,
        isAccessible: Bool = true
    ) {
        self.id = id
        self.label = label
        self.hint = hint
        self.traits = traits
        self.isAccessible = isAccessible
    }

    public func with(idSuffix: String) -> Accessibility {
        Accessibility(
            id: id == nil ? nil : "\(id.printable)\(idSuffix)",
            label: label,
            hint: hint,
            traits: traits,
            isAccessible: isAccessible
        )
    }

    public func copy(
        id: String? = nil,
        label: String? = nil,
        hint: String? = nil,
        traits: UIAccessibilityTraits? = nil
    ) -> Accessibility {
        Accessibility(
            id: id != nil ? id : self.id,
            label: label != nil ? label : self.label,
            hint: hint != nil ? hint : self.hint,
            traits: traits != nil ? traits ?? .none : self.traits
        )
    }
}

// MARK: - Conveniences

extension Accessibility {
    public static func id(_ rawValue: String) -> Accessibility {
        .init(id: rawValue)
    }

    public static func label(_ rawValue: String) -> Accessibility {
        .init(label: rawValue)
    }

    /// `.none` represents an inaccessible element
    public static var none: Accessibility {
        Accessibility(isAccessible: false)
    }
}

extension Accessibility: Equatable {
    public static func == (lhs: Accessibility, rhs: Accessibility) -> Bool {
        lhs.id == rhs.id
    }
}

extension Optional {
    public var printable: Any {
        switch self {
        case .none:
            return ""
        case .some(let value):
            return value
        }
    }
}
