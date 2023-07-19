// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa

struct YodleePendingContent: Equatable {
    let compositeViewType: CompositeStatusViewType
    let mainTitleContent: LabelContent
    let subtitleTextViewModel: InteractableTextViewModel
    let buttonContent: YodleeButtonsContent?

    var subtitleLinkTap: Signal<TitledLink> {
        subtitleTextViewModel.tap
            .asSignal(onErrorSignalWith: .empty())
    }
}
