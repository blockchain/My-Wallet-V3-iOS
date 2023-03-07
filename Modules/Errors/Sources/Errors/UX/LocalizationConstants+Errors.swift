import Foundation
import Localization

// swiftlint:disable type_name
extension LocalizationConstants {

    public enum UX {
        public enum Error {

            public static let ok = NSLocalizedString("OK", comment: "Error Screen: OK CTA")
            public static let copy = NSLocalizedString("Copy", comment: "Error Screen: Copy Context Menu")

            public static let icon = (
                accessibility: NSLocalizedString("Icon, Error", comment: "Error Screen: Default Icon accessibility description"), ()
            )

            public static let networkError = (
                title: NSLocalizedString("Network Error", comment: "Error Screen: Nabu network error title"), ()
            )

            public static let id = NSLocalizedString("ID", comment: "Error Screen: Nabu error id")
            public static let request = NSLocalizedString("Request", comment: "Error Screen: Nabu request id")
            public static let session = NSLocalizedString("Session", comment: "Error Screen: Nabu session id")

            public static let oops = (
                title: NSLocalizedString("Oops! Something Went Wrong.", comment: "Error Screen: Oops! Title"),
                message: NSLocalizedString("Don’t worry. Your crypto is safe. Please try again or contact our Support Team for help.", comment: "Error Screen: Oops! Message")
            )
        }
    }
}
