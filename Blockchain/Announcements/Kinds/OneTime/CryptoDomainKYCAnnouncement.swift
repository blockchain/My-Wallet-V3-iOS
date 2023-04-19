// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import ToolKit

/// Crypto Domain KYC Announcement
final class CryptoDomainKYCAnnouncement: OneTimeAnnouncement, ActionableAnnouncement {

    // MARK: - Internal Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.ClaimFreeDomainKYC.button
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self else { return }
                analyticsRecorder.record(event: actionAnalyticsEvent)
                markRemoved()
                action()
                dismiss()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: "card-icon-cart", bundle: .main),
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: .edge(40)
            ),
            title: LocalizationConstants.AnnouncementCards.ClaimFreeDomainKYC.title,
            description: LocalizationConstants.AnnouncementCards.ClaimFreeDomainKYC.description,
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
        userCanCompleteVerified
            && !isDismissed
    }

    let type = AnnouncementType.claimFreeCryptoDomainKYC
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    let action: CardAnnouncementAction

    // MARK: - Private Properties

    private let userCanCompleteVerified: Bool
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        userCanCompleteVerified: Bool,
        cacheSuite: CacheSuite = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        dismiss: @escaping CardAnnouncementAction,
        action: @escaping CardAnnouncementAction
    ) {
        self.userCanCompleteVerified = userCanCompleteVerified
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct CryptoDomainKYCAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = CryptoDomainKYCAnnouncement(
            userCanCompleteVerified: true,
            dismiss: {},
            action: {}
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct CryptoDomainKYCAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CryptoDomainKYCAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
#endif
