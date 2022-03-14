// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

public final class DefaultLineItemCellInteractor: LineItemCellInteracting {
    public let title: LabelContentInteracting
    public let description: LabelContentInteracting

    public init(
        title: LabelContentInteracting = DefaultLabelContentInteractor(),
        description: LabelContentInteracting = DefaultLabelContentInteractor()
    ) {
        self.title = title
        self.description = description
    }
}

public final class DefaultLineItemCellPresenter: LineItemCellPresenting {

    // MARK: - Properties

    public let identifier: String

    public lazy var image: Driver<UIImage?> = imageRelay.asDriver()

    public lazy var imageWidth: Driver<CGFloat> = imageWidthRelay
        .asDriver()

    /// The image relay
    public let imageRelay = BehaviorRelay<UIImage?>(value: nil)
    /// The image width relay
    public let imageWidthRelay = BehaviorRelay<CGFloat>(value: 22)

    public lazy var backgroundColor: Driver<UIColor> = backgroundColorRelay.asDriver()

    /// Accepts tap from a view
    public let tapRelay: PublishRelay<Void> = .init()

    /// The background color relay
    let backgroundColorRelay = BehaviorRelay<UIColor>(value: .clear)

    public let titleLabelContentPresenter: LabelContentPresenting
    public let descriptionLabelContentPresenter: LabelContentPresenting

    // MARK: - Injected

    public let interactor: LineItemCellInteracting

    // MARK: - Init

    public init(
        interactor: DefaultLineItemCellInteractor,
        accessibilityIdPrefix: String,
        identifier: String = ""
    ) {
        self.identifier = identifier
        self.interactor = interactor
        titleLabelContentPresenter = DefaultLabelContentPresenter(
            interactor: interactor.title,
            descriptors: .lineItemTitle(accessibilityIdPrefix: accessibilityIdPrefix)
        )
        descriptionLabelContentPresenter = DefaultLabelContentPresenter(
            interactor: interactor.description,
            descriptors: .lineItemDescription(accessibilityIdPrefix: accessibilityIdPrefix)
        )
    }
}
