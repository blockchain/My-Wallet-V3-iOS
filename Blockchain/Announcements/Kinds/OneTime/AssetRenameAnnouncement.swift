// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxSwift
import SwiftUI
import ToolKit

/// This is a generic announcement that introduces change in the name of a crypto currency.
final class AssetRenameAnnouncement: OneTimeAnnouncement, ActionableAnnouncement {

    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.AssetRename

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {

        let title = String(format: LocalizedString.title, data!.oldTicker)
        let description = String(format: LocalizedString.description, data!.oldTicker, data!.asset.displayCode)
        let buttonTitle = String(format: LocalizedString.ctaButton, data!.asset.displayCode)

        let button = ButtonViewModel.primary(
            with: buttonTitle,
            background: .primaryButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self else { return }
                analyticsRecorder.record(
                    event: actionAnalyticsEvent
                )
                markRemoved()
                action()
                dismiss()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: data!.asset.logoResource,
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .round,
                size: .edge(40)
            ),
            title: title,
            description: description,
            buttons: [button],
            dismissState: .dismissible { [weak self] in
                guard let self else { return }
                analyticsRecorder.record(event: dismissAnalyticsEvent)
                markRemoved()
                dismiss()
            },
            didAppear: { [weak self] in
                guard let self else { return }
                analyticsRecorder.record(event: didAppearAnalyticsEvent)
            }
        )
    }

    var associatedAppModes: [AppMode] {
        [AppMode.trading, AppMode.universal]
    }

    var shouldShow: Bool {
        data != nil
            && !isDismissed
            && data?.balance.isPositive == true
    }

    var key: AnnouncementRecord.Key {
        .assetRename(code: data?.asset.code ?? "")
    }

    let type = AnnouncementType.assetRename
    let analyticsRecorder: AnalyticsEventRecorderAPI

    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    let action: CardAnnouncementAction

    private let data: AnnouncementPreliminaryData.AssetRename?
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        data: AnnouncementPreliminaryData.AssetRename?,
        cacheSuite: CacheSuite = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        dismiss: @escaping CardAnnouncementAction,
        action: @escaping CardAnnouncementAction
    ) {
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.data = data
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct AssetRenameAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = AssetRenameAnnouncement(
            data: .init(
                asset: .bitcoin,
                oldTicker: "OLD",
                balance: .one(currency: .bitcoin)
            ),
            dismiss: {},
            action: {}
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct AssetRenameAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AssetRenameAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
#endif
