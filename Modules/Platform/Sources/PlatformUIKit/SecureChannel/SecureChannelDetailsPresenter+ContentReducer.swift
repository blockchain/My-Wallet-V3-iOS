// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import PlatformKit
import RxCocoa
import RxSwift

extension SecureChannelDetailsPresenter {
    class ContentReducer {
        private typealias LocalizedString = LocalizationConstants.SecureChannel.ConfirmationSheet

        let cells: [DetailsScreen.CellType]
        let headers: [Int: HeaderBuilder]
        var buttons: [ButtonViewModel] {
            [approveButton, denyButton]
        }

        var approveTapped: PublishRelay<Void> {
            approveButton.tapRelay
        }

        var denyTapped: PublishRelay<Void> {
            denyButton.tapRelay
        }

        private let approveButton: ButtonViewModel
        private let denyButton: ButtonViewModel

        init(candidate: SecureChannelConnectionCandidate) {

            // MARK: Buttons

            self.denyButton = ButtonViewModel.cancel(with: LocalizedString.CTA.deny)
            self.approveButton = ButtonViewModel.primary(with: LocalizedString.CTA.approve)

            // MARK: Header

            let title: String, subtitle: String
            if candidate.isAuthorized {
                title = LocalizedString.Authorized.title
                subtitle = LocalizedString.Authorized.subtitle
            } else {
                title = LocalizedString.New.title
                subtitle = LocalizedString.New.subtitle
            }
            let image = ImageViewContent(
                imageResource: .local(name: "icon-laptop", bundle: .platformUIKit),
                accessibility: .none,
                renderingMode: .normal
            )
            let model = AccountPickerHeaderModel(
                imageContent: image,
                switchable: false,
                subtitle: subtitle,
                tableTitle: nil,
                title: title
            )
            self.headers = [
                0: AccountPickerHeaderBuilder(headerType: .default(model))
            ]

            // MARK: Cells

            let locationPresenter = DefaultLineItemCellPresenter(
                interactor: DefaultLineItemCellInteractor(
                    title: DefaultLabelContentInteractor(knownValue: LocalizedString.Fields.location),
                    description: DefaultLabelContentInteractor(knownValue: candidate.details.originCountry)
                ),
                accessibilityIdPrefix: ""
            )
            let ipPresenter = DefaultLineItemCellPresenter(
                interactor: DefaultLineItemCellInteractor(
                    title: DefaultLabelContentInteractor(knownValue: LocalizedString.Fields.ipAddress),
                    description: DefaultLabelContentInteractor(knownValue: candidate.details.originIP)
                ),
                accessibilityIdPrefix: ""
            )
            let browserPresenter = DefaultLineItemCellPresenter(
                interactor: DefaultLineItemCellInteractor(
                    title: DefaultLabelContentInteractor(knownValue: LocalizedString.Fields.browser),
                    description: DefaultLabelContentInteractor(knownValue: candidate.details.originBrowser)
                ),
                accessibilityIdPrefix: ""
            )
            let datePresenter = DefaultLineItemCellPresenter(
                interactor: DefaultLineItemCellInteractor(
                    title: DefaultLabelContentInteractor(knownValue: LocalizedString.Fields.date),
                    description: DefaultLabelContentInteractor(
                        knownValue: DateFormatter.elegantDateFormatter.string(from: candidate.timestamp)
                    )
                ),
                accessibilityIdPrefix: ""
            )
            let lastSeen: String
            if let lastUsed = candidate.lastUsed {
                lastSeen = "\(lastUsed)"
            } else {
                lastSeen = LocalizedString.Fields.never
            }
            let lastSeenPresenter = DefaultLineItemCellPresenter(
                interactor: DefaultLineItemCellInteractor(
                    title: DefaultLabelContentInteractor(knownValue: LocalizedString.Fields.lastSeen),
                    description: DefaultLabelContentInteractor(
                        knownValue: lastSeen
                    )
                ),
                accessibilityIdPrefix: ""
            )

            let labelPresenter = DefaultLabelContentPresenter(
                knownValue: LocalizedString.Text.warning,
                descriptors: .body(accessibilityId: "")
            )

            var baseCells: [DetailsScreen.CellType] = [
                .separator,
                .lineItem(locationPresenter),
                .separator,
                .lineItem(ipPresenter),
                .separator,
                .lineItem(browserPresenter),
                .separator,
                .lineItem(datePresenter)
            ]
            if candidate.isAuthorized {
                baseCells += [
                    .separator,
                    .lineItem(lastSeenPresenter)
                ]
            }
            baseCells += [
                .separator,
                .label(labelPresenter)
            ]
            self.cells = baseCells
        }
    }
}
