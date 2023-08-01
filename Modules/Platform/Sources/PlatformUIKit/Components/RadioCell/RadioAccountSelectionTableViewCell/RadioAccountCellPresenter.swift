// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import PlatformKit
import RxCocoa
import RxDataSources
import RxSwift

public final class RadioAccountCellPresenter: IdentifiableType {

    // MARK: - Public Properties

    /// Streams the image content
    public let imageContent: Driver<ImageViewContent>

    // MARK: - RxDataSources

    public let identity: AnyHashable

    // MARK: - Internal

    /// The `viewModel` for the `WalletView`
    let viewModel: Driver<WalletViewViewModel>

    // MARK: - Init

    public init(
        interactor: RadioAccountCellInteractor,
        accessibilityPrefix: String = ""
    ) {
        let model = WalletViewViewModel(
            account: interactor.account,
            descriptor: .init(
                accessibilityPrefix: accessibilityPrefix
            )
        )
        self.viewModel = .just(model)
        self.identity = model.identifier

        self.imageContent = interactor
            .isSelected
            .map { $0 ? "checkbox-selected" : "checkbox-empty" }
            .asDriver(onErrorJustReturn: nil)
            .compactMap { name -> ImageViewContent? in
                guard let name else {
                    return nil
                }
                return ImageViewContent(
                    imageResource: .local(name: name, bundle: .platformUIKit),
                    accessibility: .id("\(accessibilityPrefix)\(name)"),
                    renderingMode: .normal
                )
            }
    }
}

extension RadioAccountCellPresenter: Equatable {
    public static func == (lhs: RadioAccountCellPresenter, rhs: RadioAccountCellPresenter) -> Bool {
        lhs.identity == rhs.identity
    }
}
