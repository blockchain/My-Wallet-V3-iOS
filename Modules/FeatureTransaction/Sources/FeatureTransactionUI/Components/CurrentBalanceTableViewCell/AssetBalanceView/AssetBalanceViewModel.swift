// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitectureExtensions
import Localization
import MoneyKit
import PlatformKit

public enum AssetBalanceViewModel {

    // MARK: - State Aliases

    public enum State {
        /// The state of the `AssetBalance` interactor and presenter
        public typealias Interaction = LoadingState<Value.Interaction>
        public typealias Presentation = LoadingState<Value.Presentation>
    }

    // MARK: - Value Namespace

    public enum Value {

        // MARK: - Interaction

        /// The interaction value of asset
        public struct Interaction {
            /// The wallet's primary balance
            let primaryValue: MoneyValue?
            /// The wallet's secondary balance
            let secondaryValue: MoneyValue?

            init(
                primaryValue: MoneyValue?,
                secondaryValue: MoneyValue?
            ) {
                self.primaryValue = primaryValue
                self.secondaryValue = secondaryValue
            }
        }

        // MARK: - Presentation

        public struct Presentation {

            private typealias AccessibilityId = Accessibility.Identifier.Dashboard.AssetCell

            // MARK: - Properties

            /// The primary balance displayed on top
            public let primaryBalance: LabelContent?

            /// The optional secondary balance displayed on bottom
            public let secondaryBalance: LabelContent?

            /// Descriptors that allows customized content and style
            public struct Descriptors {
                let primaryFont: UIFont
                let primaryTextColor: UIColor
                let primaryAdjustsFontSizeToFitWidth: LabelContent.FontSizeAdjustment
                let primaryAccessibility: Accessibility
                let secondaryFont: UIFont
                let secondaryTextColor: UIColor
                let secondaryAdjustsFontSizeToFitWidth: LabelContent.FontSizeAdjustment
                let secondaryAccessibility: Accessibility

                public init(
                    primaryFont: UIFont,
                    primaryTextColor: UIColor,
                    primaryAdjustsFontSizeToFitWidth: LabelContent.FontSizeAdjustment = .false,
                    primaryAccessibility: Accessibility,
                    secondaryFont: UIFont,
                    secondaryTextColor: UIColor,
                    secondaryAdjustsFontSizeToFitWidth: LabelContent.FontSizeAdjustment = .false,
                    secondaryAccessibility: Accessibility
                ) {
                    self.primaryFont = primaryFont
                    self.primaryTextColor = primaryTextColor
                    self.primaryAdjustsFontSizeToFitWidth = primaryAdjustsFontSizeToFitWidth
                    self.primaryAccessibility = primaryAccessibility
                    self.secondaryFont = secondaryFont
                    self.secondaryTextColor = secondaryTextColor
                    self.secondaryAdjustsFontSizeToFitWidth = secondaryAdjustsFontSizeToFitWidth
                    self.secondaryAccessibility = secondaryAccessibility
                }
            }

            // MARK: - Setup

            public init(with value: Interaction, descriptors: Descriptors) {
                if let primaryValue = value.primaryValue {
                    self.primaryBalance = LabelContent(
                        text: primaryValue.toDisplayString(includeSymbol: true, locale: .current),
                        font: descriptors.primaryFont,
                        color: descriptors.primaryTextColor,
                        alignment: .right,
                        adjustsFontSizeToFitWidth: descriptors.primaryAdjustsFontSizeToFitWidth,
                        accessibility: descriptors.primaryAccessibility.with(idSuffix: primaryValue.code)
                    )
                } else {
                    self.primaryBalance = nil
                }

                if let cryptoValue = value.secondaryValue, value.secondaryValue != value.primaryValue {
                    self.secondaryBalance = LabelContent(
                        text: cryptoValue.toDisplayString(includeSymbol: true, locale: .current),
                        font: descriptors.secondaryFont,
                        color: descriptors.secondaryTextColor,
                        alignment: .right,
                        adjustsFontSizeToFitWidth: descriptors.secondaryAdjustsFontSizeToFitWidth,
                        accessibility: descriptors.secondaryAccessibility.with(idSuffix: cryptoValue.code)
                    )
                } else {
                    self.secondaryBalance = nil
                }
            }
        }
    }
}

extension AssetBalanceViewModel.Value.Presentation.Descriptors {
    public typealias Descriptors = AssetBalanceViewModel.Value.Presentation.Descriptors

    public static func `default`(
        cryptoAccessiblitySuffix: String,
        fiatAccessiblitySuffix: String
    ) -> Descriptors {
        Descriptors(
            primaryFont: .main(.semibold, 14.0),
            primaryTextColor: .semantic.title,
            primaryAccessibility: .id(fiatAccessiblitySuffix),
            secondaryFont: .main(.medium, 12.0),
            secondaryTextColor: .semantic.body,
            secondaryAccessibility: .id(cryptoAccessiblitySuffix)
        )
    }

    public static func muted(
        cryptoAccessiblitySuffix: String,
        fiatAccessiblitySuffix: String,
        primaryAdjustsFontSizeToFitWidth: LabelContent.FontSizeAdjustment = .false,
        secondaryAdjustsFontSizeToFitWidth: LabelContent.FontSizeAdjustment = .false
    ) -> Descriptors {
        Descriptors(
            primaryFont: .main(.medium, 14.0),
            primaryTextColor: .semantic.muted,
            primaryAdjustsFontSizeToFitWidth: primaryAdjustsFontSizeToFitWidth,
            primaryAccessibility: .id(fiatAccessiblitySuffix),
            secondaryFont: .main(.medium, 12.0),
            secondaryTextColor: .semantic.muted,
            secondaryAdjustsFontSizeToFitWidth: secondaryAdjustsFontSizeToFitWidth,
            secondaryAccessibility: .id(cryptoAccessiblitySuffix)
        )
    }

    public static func activity(
        cryptoAccessiblitySuffix: String,
        fiatAccessiblitySuffix: String
    ) -> Descriptors {
        Descriptors(
            primaryFont: .main(.semibold, 14.0),
            primaryTextColor: .semantic.body,
            primaryAdjustsFontSizeToFitWidth: .true(factor: 0.7),
            primaryAccessibility: .id(fiatAccessiblitySuffix),
            secondaryFont: .main(.medium, 12.0),
            secondaryTextColor: .semantic.text,
            secondaryAdjustsFontSizeToFitWidth: .true(factor: 0.7),
            secondaryAccessibility: .id(cryptoAccessiblitySuffix)
        )
    }
}

extension LoadingState where Content == AssetBalanceViewModel.Value.Presentation {
    init(
        with state: LoadingState<AssetBalanceViewModel.Value.Interaction>,
        descriptors: AssetBalanceViewModel.Value.Presentation.Descriptors
    ) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(next: let content):
            self = .loaded(
                next: .init(
                    with: content,
                    descriptors: descriptors
                )
            )
        }
    }
}
