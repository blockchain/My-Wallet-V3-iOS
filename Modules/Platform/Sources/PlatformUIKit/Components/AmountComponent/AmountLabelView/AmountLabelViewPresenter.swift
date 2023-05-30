// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

/// A view model for `AmountLabelView` which is able to display a money amount with
/// an `valid` / `invalid` indication.
public final class AmountLabelViewPresenter {

    // MARK: - Types

    public enum CurrencyCodeSide {
        case leading
        case trailing
    }

    public struct Output {

        fileprivate static var empty: Output {
            Output(
                amountLabelContent: .empty,
                currencyCodeSide: .leading
            )
        }

        public var string: NSAttributedString {
            let string = NSMutableAttributedString()
            switch currencyCodeSide {
            case .leading:
                string.append(NSAttributedString(amountLabelContent.currencyCode))
                string.append(.space())
                string.append(amountLabelContent.string)
                return string
            case .trailing:
                string.append(amountLabelContent.string)
                string.append(.space())
                string.append(NSAttributedString(amountLabelContent.currencyCode))
                return string
            }
        }

        public var accessibility: Accessibility {
            amountLabelContent.accessibility
        }

        let amountLabelContent: AmountLabelContent
        let currencyCodeSide: CurrencyCodeSide
    }

    // MARK: - Properties

    /// Streams the amount label content
    var output: Driver<Output> {
        outputRelay.asDriver()
    }

    public let outputRelay = BehaviorRelay<Output>(value: .empty)

    /// The state of the component
    public let inputRelay = BehaviorRelay<MoneyValueInputScanner.Input>(value: .empty)

    // MARK: - Injected

    private let currencyCodeSide: CurrencyCodeSide
    private let interactor: AmountLabelViewInteractor

    private let disposeBag = DisposeBag()

    public init(interactor: AmountLabelViewInteractor, currencyCodeSide: CurrencyCodeSide) {
        self.interactor = interactor
        self.currencyCodeSide = currencyCodeSide

        Observable
            .combineLatest(
                interactor.currency,
                inputRelay
            )
            .map { currency, input in
                AmountLabelContent(
                    input: input,
                    currencyCode: currency.displayCode,
                    currencySymbol: currency.displaySymbol
                )
            }
            .map { labelContent in
                Output(
                    amountLabelContent: labelContent,
                    currencyCodeSide: currencyCodeSide
                )
            }
            .bindAndCatch(to: outputRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - AmountLabelContent

extension AmountLabelViewPresenter {

    // MARK: - Types

    private typealias AccessibilityId = Accessibility.Identifier.AmountLabelView

    struct AmountLabelContent {

        // MARK: - Properties

        fileprivate static var empty: AmountLabelContent {
            .init(input: .empty, currencyCode: "", currencySymbol: "")
        }

        /// Returns the attributed string
        var string: NSAttributedString {
            let string = NSMutableAttributedString()
            string.append(.init(amount))

            if let placeholder {
                string.append(.init(placeholder))
            }

            return string
        }

        let accessibility: Accessibility
        let amount: LabelContent
        let currencyCode: LabelContent
        let placeholder: LabelContent?

        // MARK: - Setup

        init(
            input: MoneyValueInputScanner.Input,
            currencyCode: String,
            currencySymbol: String
        ) {
            var amount = ""
            let formatter = NumberFormatter(
                locale: Locale.current,
                currencyCode: currencyCode,
                maxFractionDigits: 0
            )

            let decimalSeparator = MoneyValueInputScanner.Constant.decimalSeparator
            let amountComponents = input.amount.components(separatedBy: decimalSeparator)

            if let firstComponent = amountComponents.first, let decimal = Decimal(string: firstComponent) {
                amount += formatter.format(major: decimal, includeSymbol: false)
            }

            if amountComponents.count == 2 {
                amount += "\(decimalSeparator)\(amountComponents[1])"
            }

            self.currencyCode = LabelContent(
                text: currencySymbol,
                font: .main(.medium, 48),
                color: .semantic.title
            )

            self.amount = LabelContent(
                text: amount,
                font: .main(.medium, 48),
                color: .semantic.title
            )

            self.accessibility = .init(
                id: AccessibilityId.amountLabel,
                label: amount
            )

            guard let padding = input.padding else {
                self.placeholder = nil
                return
            }

            self.placeholder = LabelContent(
                text: padding,
                font: .main(.medium, 48),
                color: .semantic.muted
            )
        }
    }
}
