// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum FeatureCryptoDomain {}
}

extension LocalizationConstants.FeatureCryptoDomain {

    // MARK: - Claim Introduction Screen

    public enum ClaimIntroduction {
        public static let title = NSLocalizedString(
            "Claim Your Domain",
            comment: "Claim Introduction view navigation title"
        )
        public enum Header {
            public static let title = NSLocalizedString(
                "How It Works",
                comment: "Claim Introduction header title"
            )
            public static let description = NSLocalizedString(
                "Get your free .blockchain domain through Unstoppable Domains in three easy steps.",
                comment: "Claim Introduction view header description"
            )
        }

        public enum ListView {
            public enum ChooseDomain {
                public static let title = NSLocalizedString(
                    "Search available domains",
                    comment: "Claim Introduction choose domain row title"
                )
                public static let description = NSLocalizedString(
                    "Choose from thousands of options.",
                    comment: "Claim Introduction choose domain row description"
                )
            }

            public enum ClaimDomain {
                public static let title = NSLocalizedString(
                    "Claim your domain",
                    comment: "Claim Introduction chaim domain row title"
                )
                public static let description = NSLocalizedString(
                    "Your domain is yours forever.",
                    comment: "Claim Introduction chaim domain row description"
                )
            }

            public enum ReceiveCrypto {
                public static let title = NSLocalizedString(
                    "Use your domain",
                    comment: "Claim Introduction receive crypto row title"
                )
                public static let description = NSLocalizedString(
                    "Receive crypto directly to your domain.",
                    comment: "Claim Introduction receive crypto row description"
                )
            }
        }

        public static let promptButton = NSLocalizedString(
            "What’s a Blockchain Domain?",
            comment: "What’s a Crypto Domain? prompt button text"
        )
        public static let instruction = NSLocalizedString(
            "*Free domains must be a minimum of 7 characters long and not a protected domain. (e.g. nike.blockchain)",
            comment: "Claim instruction"
        )
        public static let goButton = NSLocalizedString(
            "Let's Go",
            comment: "Let's go button text"
        )
    }

    // MARK: - Claim Benefits Screen

    public enum ClaimBenefits {
        public enum Header {
            public static let title = NSLocalizedString(
                "Why use a blockchain domain?",
                comment: "Why use a blockchain domain header title"
            )
            public static let description = NSLocalizedString(
                "A blockchain domain is an easy to use address for sending and receiving crypto.",
                comment: "Why use a blockchain domain header description"
            )
        }

        public enum BenefitsList {
            public enum SimplifyTransaction {
                public static let title = NSLocalizedString(
                    "Simplify crypto transactions",
                    comment: "Simplify Transaction benefit title"
                )
                public static let description = NSLocalizedString(
                    "Replace long, complicated wallet addresses with a simple domain name.",
                    comment: "Simplify Transaction benefit description"
                )
            }

            public enum MultiNetwork {
                public static let title = NSLocalizedString(
                    "Multiple tokens and networks",
                    comment: "MultiNetwork benefit title"
                )
                public static let description = NSLocalizedString(
                    "Receive 275+ assets across multiple blockchain networks with your domain.",
                    comment: "MultiNetwork benefit description"
                )
            }

            public enum Ownership {
                public static let title = NSLocalizedString(
                    "Ownership for life",
                    comment: "Ownership benefit title"
                )
                public static let description = NSLocalizedString(
                    "Unlike traditional domains, you never have to renew. Claim once, own forever!",
                    comment: "Ownership benefit description"
                )
            }

            public enum MuchMore {
                public static let title = NSLocalizedString(
                    "And much more",
                    comment: "Much more benefit title"
                )
                public static let description = NSLocalizedString(
                    "Use your domain to log in to web3 apps, create and host websites, and showcase your NFT galleries.",
                    comment: "Much more beneift description"
                )
            }
        }

        public static let claimButton = NSLocalizedString(
            "Claim Domain",
            comment: "Claim domain CTA button"
        )
    }

    // MARK: - Search Domain Screen

    public enum SearchDomain {
        public static let title = NSLocalizedString(
            "Search Domains",
            comment: "Search Domains list view navigation title"
        )
        public enum Description {
            public static let title = NSLocalizedString(
                "Free domain requirements",
                comment: "Search Domains list view description title"
            )
            public static let body = NSLocalizedString(
                "Free domains must be greater than seven characters and not marked as a premium domain.",
                comment: "Search Domains list view description body"
            )
        }

        public enum SearchBar {
            public static let error = NSLocalizedString(
                "Please make sure the search key has no special characters.",
                comment: "Search domains search bar error"
            )
        }

        public enum ListView {
            public static let freeDomain = NSLocalizedString(
                "Free domain",
                comment: "Search Domains list view free domain status"
            )
            public static let premiumDomain = NSLocalizedString(
                "Paid domain",
                comment: "Search Domains list view paid domain status"
            )
            public static let free = NSLocalizedString(
                "Free",
                comment: "Search Domains list view availability status (free)"
            )
            public static let unavailable = NSLocalizedString(
                "Unavailable",
                comment: "Search Domains list view availability status (unavailable)"
            )
        }
    }

    // MARK: - Buy Domain Action Screen

    public enum BuyDomain {
        public static let header = NSLocalizedString(
            "%@ is a paid domain.",
            comment: "Buy domain bottom action view header"
        )
        public static let prompt = NSLocalizedString(
            "Would you like to purchase it on unstoppabledomains.com?",
            comment: "Buy domain bottom action view prompt"
        )
        public enum Button {
            public static let buyDomain = NSLocalizedString(
                "Buy Domain",
                comment: "Buy domain bottom action view buy button"
            )
            public static let noThanks = NSLocalizedString(
                "No Thanks",
                comment: "Buy domain buttom action view cancel button"
            )
        }
    }

    // MARK: - Domain Checkout Screen

    public enum DomainCheckout {
        public static let navigationTitle = NSLocalizedString(
            "Cart",
            comment: "Domain checkout navigation title"
        )
        public static let terms = NSLocalizedString(
            "I understand that my %@ addresses will be publicly associated with %@.",
            comment: "Domain checkout terms, first placeholder replaced by Defi Wallet"
        )
        public static let button = NSLocalizedString(
            "Claim",
            comment: "Domain checkout button"
        )
        public static let emptyTitle = NSLocalizedString(
            "Your Cart is Empty",
            comment: "Domain checkout empty state title"
        )
        public static let emptyInstruction = NSLocalizedString(
            "Add a domain to your cart.",
            comment: "Domain checkout empty state instruction"
        )
        public static let browseButton = NSLocalizedString(
            "Browse Domains",
            comment: "Browse domain button"
        )
        public enum RemoveDomain {
            public static let removeTitle = NSLocalizedString(
                "Remove %@ from your cart?",
                comment: "Remove domain title"
            )
            public static let removeButton = NSLocalizedString(
                "Remove",
                comment: "Remove CTA button"
            )
            public static let nevermindButton = NSLocalizedString(
                "Nevermind",
                comment: "Nevermind CTA button"
            )
        }
    }

    // MARK: - Checkout confirmation screen

    public enum CheckoutConfirmation {
        public enum Success {
            public static let title = NSLocalizedString(
                "%@ is now yours!",
                comment: "Success checkout confirmation title"
            )
            public static let description = NSLocalizedString(
                "You can now share your domain to receive crypto instead of sharing your wallet addresses.",
                comment: "Success checkout confirmation description"
            )
            public static let learnMore = NSLocalizedString(
                "Learn More",
                comment: "Success learn more button"
            )
            public static let okayButton = NSLocalizedString(
                "Okay",
                comment: "Success okay button"
            )
        }

        public enum Error {
            public static let title = NSLocalizedString(
                "Failed to claim %@",
                comment: "Error checkout confirmation title"
            )
            public static let description = NSLocalizedString(
                "Looks like there was an error claiming your domain. Don’t worry, nobody stole it.",
                comment: "Error checkout confirmation description"
            )
            public static let tryAgainButton = NSLocalizedString(
                "Try Again",
                comment: "Error try again button"
            )
        }
    }
}
