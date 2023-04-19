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

/// This is a generic announcement that introduces a new crypto currency.
final class NewAssetAnnouncement: OneTimeAnnouncement, ActionableAnnouncement {

    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.NewAsset

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {

        let title = String(format: LocalizedString.title, cryptoCurrency!.name, cryptoCurrency!.displayCode)
        let description = String(format: LocalizedString.description, cryptoCurrency!.displayCode)
        let buttonTitle = String(format: LocalizedString.ctaButton, cryptoCurrency!.displayCode)

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
                image: cryptoCurrency!.logoResource,
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
        cryptoCurrency != nil && !isDismissed
    }

    var key: AnnouncementRecord.Key {
        .newAsset(code: cryptoCurrency?.code ?? "")
    }

    let type = AnnouncementType.newAsset
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let cryptoCurrency: CryptoCurrency?

    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    let action: CardAnnouncementAction

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        cryptoCurrency: CryptoCurrency?,
        cacheSuite: CacheSuite = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        dismiss: @escaping CardAnnouncementAction,
        action: @escaping CardAnnouncementAction
    ) {
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.cryptoCurrency = cryptoCurrency
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct NewAssetAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = NewAssetAnnouncement(
            cryptoCurrency: .bitcoin,
            dismiss: {},
            action: {}
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct NewAssetAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NewAssetAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
#endif
