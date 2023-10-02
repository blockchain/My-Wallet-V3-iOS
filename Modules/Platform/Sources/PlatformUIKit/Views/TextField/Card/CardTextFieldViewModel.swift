// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Errors
import FeatureCardPaymentDomain
import PlatformKit
import RxSwift
import ToolKit
import UIComponentsKit

public protocol CardTypeSource: AnyObject {
    var cardType: Observable<CardType> { get }
}

public final class CardTextFieldViewModel: TextFieldViewModel {

    // MARK: - Properties

    /// Streams the card thumbnail image view content. determined by the card type
    var cardThumbnailBadgeImageViewModel: Observable<BadgeImageViewModel?> {
        Observable
            .combineLatest(
                cardNumberValidator.cardType,
                cardNumberValidator.validationState
            )
            .map { type, validationState in
                /// The card is a valid entry thus far but
                /// there is a non-zero possibility the card
                /// will not work.
                let isConceivable = validationState.isConceivable
                /// The card is a valid entry thus far but
                /// it will not work.
                let isBlocked = validationState.isBlocked
                /// Show the disclaimer icon should either of the above be true.
                if isBlocked || isConceivable {
                    let content = ImageViewContent(
                        imageResource: ImageLocation.local(name: "disclaimer-icon", bundle: .platformUIKit),
                        renderingMode: .template(isBlocked ? .destructive : .warning)
                    )
                    let theme = BadgeImageViewModel.Theme(
                        backgroundColor: .background,
                        cornerRadius: .round,
                        imageViewContent: content,
                        marginOffset: 0,
                        sizingType: .constant(CGSize(width: 16, height: 16))
                    )
                    return BadgeImageViewModel(theme: theme)
                }

                guard type.isKnown else { return nil }
                let content = ImageViewContent(
                    imageResource: type.thumbnail,
                    accessibility: .id(type.name)
                )
                let theme = BadgeImageViewModel.Theme(
                    backgroundColor: .background,
                    cornerRadius: .roundedLow,
                    imageViewContent: content,
                    marginOffset: 0,
                    sizingType: .constant(CGSize(width: 32, height: 20))
                )
                return BadgeImageViewModel(theme: theme)
            }
    }

    private let cardNumberValidator: CardNumberValidator
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        validator: CardNumberValidator,
        messageRecorder: MessageRecording
    ) {
        self.cardNumberValidator = validator
        super.init(
            with: .cardNumber,
            returnKeyType: .default,
            validator: validator,
            formatter: TextFormatterFactory.cardNumber,
            messageRecorder: messageRecorder
        )

        cardThumbnailBadgeImageViewModel
            .map { viewModel in
                if let viewModel {
                    return .badgeImageView(viewModel)
                } else {
                    return .empty
                }
            }
            .bindAndCatch(to: accessoryContentTypeRelay)
            .disposed(by: disposeBag)
    }
}
