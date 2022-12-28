// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

protocol LocaleIdentifierServiceAPI {
    var timezoneIana: String { get }
    var acceptLanguage: String { get }
}

final class LocaleIdentifierService: LocaleIdentifierServiceAPI {
    var timezoneIana: String {
        TimeZone.current.identifier
    }

    var acceptLanguage: String {
        Array(Locale.preferredLanguages.prefix(3) + Bundle.main.preferredLocalizations)
            .enumerated()
            .map { index, encoding in
                let quality = 1.0 - (Double(index) * 0.1)
                return "\(encoding);q=\(quality)"
            }
            .joined(separator: ", ")
    }
}
