// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureCardPaymentDomain
import Localization
import RxRelay
import RxSwift
import ToolKit

public final class CardCVVTextFieldViewModel: TextFieldViewModel {

    // MARK: - Properties

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        validator: TextValidating,
        cardTypeSource: CardTypeSource,
        matchValidator: CVVToCreditCardMatchValidator,
        messageRecorder: MessageRecording
    ) {
        super.init(
            with: .cardCVV,
            validator: validator,
            formatter: TextFormatterFactory.cardCVV,
            textMatcher: matchValidator,
            messageRecorder: messageRecorder
        )

        cardTypeSource.cardType
            .map { type in
                switch type {
                case .mastercard:
                    LocalizationConstants.TextField.Title.Card.cvc
                case .amex, .diners, .discover, .jcb, .unknown, .visa:
                    LocalizationConstants.TextField.Title.Card.cvv
                }
            }
            .bindAndCatch(to: titleRelay)
            .disposed(by: disposeBag)
    }
}
