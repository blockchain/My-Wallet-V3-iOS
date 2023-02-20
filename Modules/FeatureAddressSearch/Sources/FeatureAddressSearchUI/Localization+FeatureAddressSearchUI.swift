// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAddressSearchDomain
import Foundation
import Localization

extension LocalizationConstants {
    public enum AddressSearch {

        static let title = NSLocalizedString(
            "Home Address",
            comment: "Address Search: Home Address Title"
        )

        enum Buttons {

            static let next = NSLocalizedString(
                "Next",
                comment: "Address Search: Next Button"
            )

            static let save = NSLocalizedString(
                "Save",
                comment: "Address Search: Save Button"
            )

            static let cancel = NSLocalizedString(
                "Cancel",
                comment: "Address Search: Cancel Button"
            )

            static let edit = NSLocalizedString(
                "Edit",
                comment: "Address Search: Edit Button"
            )
        }
    }
}

extension LocalizationConstants.AddressSearch {

    enum SearchAddress {

        enum SearchBar {

            enum Placeholder {

                static let text = NSLocalizedString(
                    "Home Address",
                    comment: "Address Search: Search Address Placeholder"
                )
            }

            static let invalidCharactersError = NSLocalizedString(
                "Please make sure the search key has no special characters.",
                comment: "Search address search bar no special characters error"
            )
        }

        enum AddressNotFound {

            static let title = NSLocalizedString(
                "Address not found",
                comment: "Address Search: Search Address Address not found"
            )

            enum Buttons {

                static let inputAddressManually = NSLocalizedString(
                    "My address is not here",
                    comment: "Address Search: Input Address Manually"
                )
            }
        }
    }
}

extension LocalizationConstants.AddressSearch {

    enum Form {

        static let addressLine1 = NSLocalizedString(
            "Home Address",
            comment: "Address Search: Form Address Line 1"
        )

        static let addressLine2 = NSLocalizedString(
            "Apt, Suite, Etc",
            comment: "Address Search: Form Address Line 2"
        )

        static let city = NSLocalizedString(
            "City",
            comment: "Address Search: Form City"
        )

        static let state = NSLocalizedString(
            "State",
            comment: "Address Search: Form State"
        )

        static let zip = NSLocalizedString(
            "Zip code",
            comment: "Address Search: Form Zip"
        )

        static let country = NSLocalizedString(
            "Country",
            comment: "Address Search: Form Country"
        )

        enum Placeholder {

            static let line1 = NSLocalizedString(
                "1234 Road Street",
                comment: "Address Search: Form Placeholder"
            )

            static let line2 = NSLocalizedString(
                "Additional Information",
                comment: "Address Search: Form Placeholder"
            )
        }

        public enum Errors {
            public static let genericError = NSLocalizedString(
                "Please check the information you provided and try again.",
                comment: "Generic error message displayed when an error occurs in address form"
            )

            public static let cannotEditStateTitle = NSLocalizedString(
                "You cannot change your State",
                comment: "Title for an alert warning users that they can't change their State if we already have that data"
            )
            public static let cannotEditStateMessage = NSLocalizedString(
                "If you need to change your State, please contact our customer support.",
                comment: "Longer explanation in an alert warning users that they can't change their State if we already have that data. If they need that, they should conact the customer support."
            )
        }
    }
}
