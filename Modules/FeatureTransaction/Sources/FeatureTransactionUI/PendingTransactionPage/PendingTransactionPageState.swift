// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit

struct PendingTransactionPageState {

    enum Effect {

        /// Just dismiss the pending screen.
        case close

        /// Do any final procedure and then close the pending screen
        case complete

        /// Do nothing. This is usually only
        /// present when the screen is pending
        /// as opposed to a success or failure state.
        case none
    }

    let title: LabelContent
    let subtitle: LabelContent
    let compositeViewType: CompositeStatusViewType
    let effect: Effect
    let primaryButtonViewModel: ButtonViewModel?
    let secondaryButtonViewModel: ButtonViewModel?
    let action: AssetAction

    static let empty: PendingTransactionPageState = .init(
        title: "",
        subtitle: "",
        action: .buy
    )

    init(
        title: String,
        subtitle: String,
        compositeViewType: CompositeStatusViewType = .none,
        effect: Effect = .none,
        primaryButtonViewModel: ButtonViewModel? = nil,
        secondaryButtonViewModel: ButtonViewModel? = nil,
        action: AssetAction
    ) {
        self.title = .init(
            text: title,
            font: .main(.semibold, 20.0),
            color: .semantic.title,
            alignment: .center,
            accessibility: .init(id: "PendingTransactionTitleLabel")
        )

        self.subtitle = .init(
            text: subtitle,
            font: .main(.medium, 14.0),
            color: .semantic.body,
            alignment: .center,
            accessibility: .init(id: "PendingTransactionSubtitleLabel")
        )

        self.compositeViewType = compositeViewType
        self.primaryButtonViewModel = primaryButtonViewModel
        self.secondaryButtonViewModel = secondaryButtonViewModel
        self.effect = effect
        self.action = action
    }
}

extension PendingTransactionPageState {

    var primaryButtonViewModelVisibility: Visibility {
        primaryButtonViewModel == nil ? .hidden : .visible
    }

    var secondaryButtonViewModelVisibility: Visibility {
        secondaryButtonViewModel == nil ? .hidden : .visible
    }
}
