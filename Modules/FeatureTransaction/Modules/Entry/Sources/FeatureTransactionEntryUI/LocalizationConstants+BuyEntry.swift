import Localization

extension LocalizationConstants {

    enum BuyEntry {
        static let title = NSLocalizedString("Select a Token", comment: "Select a Token")
        static let cancel = NSLocalizedString("Cancel", comment: "Cancel")
        static let search = NSLocalizedString("Search Coin", comment: "Search Coin")
        static let mostPopular = NSLocalizedString("Most popular", comment: "Most popular")
        static let otherTokens = NSLocalizedString("Other tokens", comment: "Other tokens")
        static let searching = NSLocalizedString("Search results", comment: "Search results")
    }

    enum SellEntry {
        static let title = NSLocalizedString("Sell", comment: "Sell")
        static let lookingToBuy = NSLocalizedString("Looking to buy?", comment: "Looking to buy?")
        static let emptyTitle = NSLocalizedString("No available assets", comment: "Sell Empty Title")
        static let emptyMessage = NSLocalizedString("You don't have any balance in a crypto that we support selling.", comment: "Sell Empty Message")
        static let availableToSell = NSLocalizedString("Available to sell", comment: "Sell Subheader")
    }
}
