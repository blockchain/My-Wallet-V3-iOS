import Foundation

enum L10n {}

extension L10n { enum Tooltip {} }

extension L10n.Tooltip {

    static let gotIt = NSLocalizedString(
        "Got it",
        comment: "Dex: Main"
    )
}
