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
            let primaryValue: MoneyValue
            /// The wallet's secondary balance
            let secondaryValue: MoneyValue?
            /// The wallet's pending balance
            let pendingValue: MoneyValue?

            init(
                primaryValue: MoneyValue,
                secondaryValue: MoneyValue?,
                pendingValue: MoneyValue?
            ) {
                self.primaryValue = primaryValue
                self.secondaryValue = secondaryValue
                self.pendingValue = pendingValue
            }
        }

        // MARK: - Presentation

        public struct Presentation {

            private typealias AccessibilityId = Accessibility.Identifier.Dashboard.AssetCell

            // MARK: - Properties

            /// The primary balance displayed on top
            public let primaryBalance: LabelContent

            /// The optional secondary balance displayed on bottom
            public let secondaryBalance: LabelContent

            /// The visibility state of the `Pending` balance
            let pendingBalanceVisibility: Visibility

            /// The pending balance in crypto. This value is `.none`
            /// should the user's pending balance be `.zero`
            public let pendingBalance: LabelContent

            /// Descriptors that allows customized content and style
            public struct Descriptors {
                let primaryFont: UIFont
                let primaryTextColor: UIColor
                let primaryAdjustsFontSizeToFitWidth: LabelContent.FontSizeAdjustment
                let primaryAccessibility: Accessibility
                let secondaryFont: UIFont
                let secondaryTextColor: UIColor
                let secondaryAdjustsFontSizeToFitWidth: LabelContent.FontSizeAdjustment
                let pendingTextColor: UIColor
                let secondaryAccessibility: Accessibility

                public init(
                    primaryFont: UIFont,
                    primaryTextColor: UIColor,
                    primaryAdjustsFontSizeToFitWidth: LabelContent.FontSizeAdjustment = .false,
                    primaryAccessibility: Accessibility,
                    secondaryFont: UIFont,
                    secondaryTextColor: UIColor,
                    secondaryAdjustsFontSizeToFitWidth: LabelContent.FontSizeAdjustment = .false,
                    pendingTextColor: UIColor = .mutedText,
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
                    self.pendingTextColor = pendingTextColor
                }
            }

            // MARK: - Setup

            public init(with value: Interaction, alignment: UIStackView.Alignment, descriptors: Descriptors) {
                let textAlignment: NSTextAlignment
                switch alignment {
                case .leading:
                    textAlignment = .left
                case .trailing:
                    textAlignment = .right
                default:
                    textAlignment = .natural
                }
                self.primaryBalance = LabelContent(
                    text: value.primaryValue.toDisplayString(includeSymbol: true, locale: .current),
                    font: descriptors.primaryFont,
                    color: descriptors.primaryTextColor,
                    alignment: textAlignment,
                    adjustsFontSizeToFitWidth: descriptors.primaryAdjustsFontSizeToFitWidth,
                    accessibility: descriptors.primaryAccessibility.with(idSuffix: value.primaryValue.code)
                )

                if let cryptoValue = value.secondaryValue, value.secondaryValue != value.primaryValue {
                    self.secondaryBalance = LabelContent(
                        text: cryptoValue.toDisplayString(includeSymbol: true, locale: .current),
                        font: descriptors.secondaryFont,
                        color: descriptors.secondaryTextColor,
                        alignment: textAlignment,
                        adjustsFontSizeToFitWidth: descriptors.secondaryAdjustsFontSizeToFitWidth,
                        accessibility: descriptors.secondaryAccessibility.with(idSuffix: cryptoValue.code)
                    )
                } else {
                    self.secondaryBalance = .empty
                }

                if let pendingValue = value.pendingValue, !pendingValue.isZero {
                    self.pendingBalanceVisibility = .visible
                    self.pendingBalance = LabelContent(
                        text: pendingValue.toDisplayString(includeSymbol: true, locale: .current),
                        font: descriptors.secondaryFont,
                        color: descriptors.pendingTextColor,
                        alignment: textAlignment,
                        accessibility: descriptors.secondaryAccessibility.with(idSuffix: pendingValue.code)
                    )
                } else {
                    self.pendingBalanceVisibility = .hidden
                    self.pendingBalance = .empty
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
        alignment: UIStackView.Alignment,
        descriptors: AssetBalanceViewModel.Value.Presentation.Descriptors
    ) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(next: let content):
            self = .loaded(
                next: .init(
                    with: content,
                    alignment: alignment,
                    descriptors: descriptors
                )
            )
        }
    }
}
