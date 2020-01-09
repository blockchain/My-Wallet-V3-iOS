//
//  DashboardAssetPrice.swift
//  Blockchain
//
//  Created by Daniel Huri on 25/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import LocalizationKit

public struct DashboardAsset {
    
    // MARK: - State Aliases
    
    public struct State {
        
        /// The state of the `AssetPrice` interactor and presenter
        public struct AssetPrice {
            public typealias Interaction = LoadingState<Value.Interaction.AssetPrice>
            public typealias Presentation = LoadingState<Value.Presentation.AssetPrice>
        }
        
        /// The state of the `AssetBalance` interactor and presenter
        public struct AssetBalance {
            public typealias Interaction = LoadingState<Value.Interaction.AssetBalance>
            public typealias Presentation = LoadingState<Value.Presentation.AssetBalance>
        }
    }
    
    // MARK: - Value Namespace
    
    public struct Value {
        
        // MARK: - Interaction
        
        /// The interaction value of dashboard asset
        public struct Interaction {
            
            public struct AssetPrice {
                
                /// Time unit. Can be further customized in future
                /// Each value currently refers to 1 unit
                public enum Time {
                    case hours(Int)
                    case days(Int)
                    case weeks(Int)
                    case months(Int)
                    case years(Int)
                    case timestamp(Date)
                    
                    var string: String {
                        switch self {
                        case .hours(let number):
                            let time = number > 1 ? LocalizationConstants.TimeUnit.Plural.hours : LocalizationConstants.TimeUnit.Singular.hour
                            return "\(number) \(time)"
                        case .days(let number):
                            let time = number > 1 ? LocalizationConstants.TimeUnit.Plural.days : LocalizationConstants.TimeUnit.Singular.day
                            return "\(number) \(time)"
                        case .weeks(let number):
                            let time = number > 1 ? LocalizationConstants.TimeUnit.Plural.weeks : LocalizationConstants.TimeUnit.Singular.week
                            return "\(number) \(time)"
                        case .months(let number):
                            let time = number > 1 ? LocalizationConstants.TimeUnit.Plural.months : LocalizationConstants.TimeUnit.Singular.month
                            return "\(number) \(time)"
                        case .years(let number):
                            switch number > 1 {
                            case true:
                                return  LocalizationConstants.TimeUnit.Plural.allTime
                            case false:
                                return "\(number) \(LocalizationConstants.TimeUnit.Singular.year)"
                            }
                        case .timestamp(let date):
                            return DateFormatter.medium.string(from: date)
                        }
                    }
                }
                
                /// The `Time` for the given `AssetPrice`
                let time: Time
                
                /// The asset price in localized fiat currency
                let fiatValue: FiatValue
                
                /// Percentage of change since a certain time
                let changePercentage: Double
                
                /// The change in fiat value
                let fiatChange: FiatValue
                
                public init(time: Time, fiatValue: FiatValue, changePercentage: Double, fiatChange: FiatValue) {
                    self.time = time
                    self.fiatValue = fiatValue
                    self.changePercentage = changePercentage
                    self.fiatChange = fiatChange
                }
            }
            
            public struct AssetBalance {
                
                /// The wallet's balance in fiat
                let fiatValue: FiatValue
                /// The wallet's balance in crypto
                let cryptoValue: CryptoValue
            }
            
        }
        
        // MARK: - Presentation
        
        public struct Presentation {
            
            /// The presentation model for `AssetBalanceView`
            public struct AssetBalance {
                
                private typealias AccessibilityId = Accessibility.Identifier.Dashboard.AssetCell
                
                // MARK: - Properties
                
                /// The balance in fiat
                let fiatBalance: LabelContent
                
                /// The balance in crypto
                let cryptoBalance: LabelContent
                
                // MARK: - Setup
                
                public init(with value: Interaction.AssetBalance) {
                    fiatBalance = LabelContent(
                        text: value.fiatValue.toDisplayString(includeSymbol: true, locale: .current),
                        font: .mainMedium(16.0),
                        color: .dashboardFiatPriceTitle,
                        accessibility: .init(
                            id: .value("\(AccessibilityId.fiatBalanceLabelFormat)\(value.cryptoValue.currencyCode)")
                            )
                        )
                    
                    cryptoBalance = LabelContent(
                        text: value.cryptoValue.toDisplayString(includeSymbol: true, locale: .current),
                        font: .mainMedium(14.0),
                        color: .mutedText,
                        accessibility: .init(
                            id: .value("\(AccessibilityId.cryptoBalanceLabelFormat)\(value.cryptoValue.currencyCode)")
                            )
                        )
                }
            }
            
            /// The presentation model for `AssetPriceView`
            public struct AssetPrice {
                
                private typealias AccessibilityId = Accessibility.Identifier.Dashboard.AssetCell

                /// Descriptors that allows customized content and style
                public struct Descriptors {
                    
                    /// Options to display content
                    struct ContentOptions: OptionSet {
                        let rawValue: Int
                        init(rawValue: Int) {
                            self.rawValue = rawValue
                        }
                        
                        /// Includes fiat price change
                        static let fiat = ContentOptions(rawValue: 1 << 0)
                        
                        /// Includes percentage price change
                        static let percentage = ContentOptions(rawValue: 2 << 0)
                    }
                    
                    let contentOptions: ContentOptions
                    let priceFontSize: CGFloat
                    let changeFontSize: CGFloat
                    let accessibilityIdSuffix: String
                }
                
                // MARK: - Properties
                
                /// The price of the asset
                let price: LabelContent
                
                /// The change
                let change: NSAttributedString
                
                let changeAccessibility: Accessibility
                
                // MARK: - Setup
                
                public init(with value: Interaction.AssetPrice, descriptors: Descriptors) {
                    let fiatPrice = value.fiatValue.toDisplayString(includeSymbol: true)
                    price = LabelContent(
                        text: fiatPrice,
                        font: .mainSemibold(descriptors.priceFontSize),
                        color: .dashboardAssetTitle,
                        accessibility: .init(
                            id: .value("\(AccessibilityId.fiatBalanceLabelFormat)\(descriptors.accessibilityIdSuffix)")
                        )
                    )
                    
                    let color: UIColor
                    let sign: String
                    
                    if value.fiatChange.isPositive {
                        sign = "+"
                        color = .positivePrice
                    } else if value.fiatChange.isNegative {
                        sign = ""
                        color = .negativePrice
                    } else { // Zero {
                        sign = ""
                        color = .mutedText
                    }
                    
                    let fiatChange: NSAttributedString
                    if descriptors.contentOptions.contains(.fiat) {
                        let fiat = value.fiatChange.toDisplayString(includeSymbol: true)
                        let suffix = descriptors.contentOptions.contains(.percentage) ? " " : ""
                        fiatChange = NSAttributedString(
                            LabelContent(
                                text: "\(sign)\(fiat)\(suffix)",
                                font: .mainMedium(descriptors.changeFontSize),
                                color: color
                            )
                        )
                    } else {
                        fiatChange = NSAttributedString()
                    }
                    
                    let percentageChange: NSAttributedString
                    if descriptors.contentOptions.contains(.percentage) {
                        let prefix: String
                        let suffix: String
                        if descriptors.contentOptions.contains(.fiat) {
                            prefix = "("
                            suffix = ")"
                        } else {
                            prefix = ""
                            suffix = ""
                        }
                        let percentage = value.changePercentage * 100
                        let percentageString = percentage.string(with: 2)
                        percentageChange = NSAttributedString(
                            LabelContent(
                                text: "\(prefix)\(percentageString)%\(suffix)",
                                font: .mainMedium(descriptors.changeFontSize),
                                color: color
                            )
                        )
                    } else {
                        percentageChange = NSAttributedString()
                    }
                    
                    let period = NSAttributedString(
                        LabelContent(
                            text: " \(value.time.string)",
                            font: .mainMedium(descriptors.changeFontSize),
                            color: .mutedText
                        )
                    )
                    change = fiatChange + percentageChange + period
                    changeAccessibility = .init(id: .value("\(AccessibilityId.changeLabelFormat)\(descriptors.accessibilityIdSuffix)"
                    ))
                }
            }
        }
    }
}

extension DashboardAsset.Value.Presentation.AssetPrice.Descriptors {
    
    /// Returns a descriptor for dashboard total balance
    public static var balance: DashboardAsset.Value.Presentation.AssetPrice.Descriptors {
        return .init(
            contentOptions: [.fiat, .percentage],
            priceFontSize: 24,
            changeFontSize: 14,
            accessibilityIdSuffix: Accessibility.Identifier.Dashboard.TotalBalanceCell.valueLabelSuffix
        )
    }
    
    /// Returns a descriptor for dashboard asset price
    public static func assetPrice(accessibilityIdSuffix: String,
                           priceFontSize: CGFloat = 16.0,
                           changeFontSize: CGFloat = 14.0) -> DashboardAsset.Value.Presentation.AssetPrice.Descriptors {
        return .init(
            contentOptions: [.percentage],
            priceFontSize: priceFontSize,
            changeFontSize: changeFontSize,
            accessibilityIdSuffix: accessibilityIdSuffix
        )
    }
}

public extension PriceWindow {

    typealias Time = DashboardAsset.Value.Interaction.AssetPrice.Time

    func time(for currency: CryptoCurrency) -> Time {
        switch self {
        case .all:
            let years = max(1.0, currency.maxStartDate / 31536000)
            return .years(Int(years))
        case .year:
            return .years(1)
        case .month:
            return .months(1)
        case .week:
            return .weeks(1)
        case .day:
            return .hours(24)
        }
    }
}
