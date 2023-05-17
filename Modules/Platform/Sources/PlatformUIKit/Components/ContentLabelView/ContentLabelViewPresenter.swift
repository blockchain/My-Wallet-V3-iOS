// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import PlatformKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit

/// Presenter for `ContentLabelView`.
final class ContentLabelViewPresenter {

    // MARK: - Types

    private typealias AccessibilityId = Accessibility.Identifier.ContentLabelView

    // MARK: - Title LabelContent

    /// An input relay for the title.
    let titleRelay: BehaviorRelay<String>

    /// Driver emitting the title `LabelContent`.
    let titleLabelContent: Driver<LabelContent>

    // MARK: - Description LabelContent

    let descriptionLabelContent: Driver<LabelContent>

    var containsDescription: Driver<Bool> {
        interactor.contentCalculationState
            .map(\.isValue)
            .asDriver(onErrorJustReturn: false)
    }

    // MARK: - Tap Interaction

    var tap: Signal<Void> {
        tapRelay.asSignal()
    }

    let tapRelay = PublishRelay<Void>()

    // MARK: - Interactor

    private let interactor: ContentLabelViewInteractorAPI

    // MARK: - Init

    init(
        title: String,
        alignment: NSTextAlignment,
        adjustsFontSizeToFitWidth: LabelContent.FontSizeAdjustment = .false,
        interactor: ContentLabelViewInteractorAPI,
        accessibilityPrefix: String
    ) {
        self.interactor = interactor
        self.titleRelay = BehaviorRelay<String>(value: title)
        self.titleLabelContent = titleRelay
            .asDriver()
            .map { title in
                LabelContent(
                    text: title,
                    font: .main(.medium, 12),
                    color: .semantic.primary,
                    alignment: alignment,
                    adjustsFontSizeToFitWidth: adjustsFontSizeToFitWidth,
                    accessibility: .id("\(accessibilityPrefix).\(Accessibility.Identifier.ContentLabelView.title)")
                )
            }
        self.descriptionLabelContent = interactor.contentCalculationState
            .compactMap(\.value)
            .map {
                LabelContent(
                    text: $0,
                    font: .main(.semibold, 14),
                    color: .semantic.body,
                    alignment: alignment,
                    adjustsFontSizeToFitWidth: adjustsFontSizeToFitWidth,
                    accessibility: .id("\(accessibilityPrefix).\(AccessibilityId.description)")
                )
            }
            .asDriver(onErrorJustReturn: .empty)
    }
}
