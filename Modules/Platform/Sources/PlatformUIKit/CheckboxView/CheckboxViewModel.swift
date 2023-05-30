// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import RxCocoa
import RxDataSources
import RxSwift
import ToolKit

public final class CheckboxViewModel: IdentifiableType {

    // MARK: - Public Properties

    public typealias Inputs = [InteractableTextViewModel.Input]

    public let image: Driver<UIImage?>

    public var textViewViewModel: Driver<InteractableTextViewModel> {
        .just(interactableTextViewModel)
    }

    public var tapRelay: Signal<TitledLink> {
        titledLinkRelay
            .asSignal()
    }

    public let selectedRelay = BehaviorRelay<Bool>(value: false)

    // MARK: - RxDataSources

    public var identity: AnyHashable {
        interactableTextViewModel
            .identifier
    }

    // MARK: - Private Properties

    private let interactableTextViewModel: InteractableTextViewModel
    private let disposeBag = DisposeBag()
    private let titledLinkRelay = PublishRelay<TitledLink>()

    // MARK: - Init

    public init(inputs: Inputs = []) {
        self.interactableTextViewModel = .init(
            inputs: inputs,
            textStyle: .init(
                color: .semantic.body,
                font: .main(.medium, 12.0)
            ),
            linkStyle: .init(
                color: .semantic.primary,
                font: .main(.medium, 12.0)
            )
        )

        self.image = selectedRelay
            .asObservable()
            .map { $0 ? "checkbox-on" : "checkbox-off" }
            .asDriver(onErrorJustReturn: nil)
            .map { name in
                if let name {
                    return UIImage(named: name, in: .UIComponents, compatibleWith: nil)
                }
                return nil
            }

        interactableTextViewModel
            .tap
            .bindAndCatch(to: titledLinkRelay)
            .disposed(by: disposeBag)
    }
}

extension CheckboxViewModel: Equatable {
    public static func == (lhs: CheckboxViewModel, rhs: CheckboxViewModel) -> Bool {
        lhs.identity == rhs.identity &&
            lhs.selectedRelay.value == rhs.selectedRelay.value
    }
}
