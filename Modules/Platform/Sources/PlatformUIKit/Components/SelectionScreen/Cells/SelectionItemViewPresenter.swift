// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class SelectionItemViewPresenter {

    // MARK: - Types

    private typealias AccessibilityId = Accessibility.Identifier.SelectionScreen

    // MARK: - Exposed Properties

    let thumb: ViewContent
    let title: LabelContent
    let description: LabelContent

    let accessibility: Accessibility

    var selectionImage: Observable<ImageViewContent> {
        selectionImageRelay.asObservable()
    }

    var data: SelectionItemViewModel {
        interactor.item
    }

    let tapRelay = PublishRelay<Void>()

    var isSelected: Observable<Bool> {
        interactor.isSelectedRelay.distinctUntilChanged()
    }

    // MARK: - Private Properties

    private let selectionImageRelay = BehaviorRelay(value: ImageViewContent.empty)
    private let isSelectedRelay = BehaviorRelay(value: false)
    private let interactor: SelectionItemViewInteractor
    private let disposeBag = DisposeBag()

    init(interactor: SelectionItemViewInteractor) {
        self.interactor = interactor
        let item = interactor.item
        self.accessibility = .id("\(AccessibilityId.selectionCellPrefix)\(item.id)")
        switch item.thumb {
        case .image(let imageResource):
            self.thumb = .image(
                ImageViewContent(
                    imageResource: imageResource,
                    accessibility: .id("\(AccessibilityId.imageViewPrefix)\(item.accessibilityId)")
                )
            )
        case .emoji(let value):
            self.thumb = .label(
                LabelContent(
                    text: value,
                    font: .main(.medium, 30),
                    color: .black,
                    accessibility: .id("\(AccessibilityId.imageViewPrefix)\(item.accessibilityId)")
                )
            )
        case .none:
            self.thumb = .none
        }

        self.title = LabelContent(
            text: item.title,
            font: .main(.semibold, 16),
            color: .semantic.title,
            accessibility: .id("\(AccessibilityId.titleLabelPrefix)\(item.accessibilityId)")
        )
        self.description = LabelContent(
            text: item.subtitle,
            font: .main(.medium, 14),
            color: .semantic.text,
            accessibility: .id("\(AccessibilityId.descriptionLabelPrefix)\(item.accessibilityId)")
        )

        isSelectedRelay
            .bindAndCatch(to: interactor.isSelectedRelay)
            .disposed(by: disposeBag)

        isSelected
            .map(weak: self) { (self, isSelected) -> ImageViewContent in
                guard isSelected else { return .empty }
                let item = self.interactor.item
                return ImageViewContent(
                    imageResource: .local(name: "v-selection-icon", bundle: .platformUIKit),
                    accessibility: .id("\(AccessibilityId.selectionImageViewPrefix)\(item.accessibilityId)")
                )
            }
            .bindAndCatch(to: selectionImageRelay)
            .disposed(by: disposeBag)

        tapRelay
            .withLatestFrom(isSelectedRelay)
            .filter { !$0 }
            .map { !$0 }
            .bindAndCatch(to: isSelectedRelay)
            .disposed(by: disposeBag)
    }

    func setup(selectionEvent: @escaping () -> Void) {
        isSelected
            .filter { $0 }
            .mapToVoid()
            .bind(onNext: selectionEvent)
            .disposed(by: disposeBag)
    }

    /// An accessor for text pattern search
    func contains(text: String) -> Bool {
        title.text.lowercased().contains(text) || description.text.lowercased().contains(text)
    }

    func deselect() {
        isSelectedRelay.accept(false)
    }

    func select() {
        isSelectedRelay.accept(true)
    }
}

// MARK: - Equatable

extension SelectionItemViewPresenter: Equatable, Hashable {
    public static func == (lhs: SelectionItemViewPresenter, rhs: SelectionItemViewPresenter) -> Bool {
        lhs.interactor == rhs.interactor
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(interactor)
    }
}
