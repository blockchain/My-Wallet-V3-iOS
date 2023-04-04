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

// swiftlint:disable type_name
final class ResubmitDocumentsAfterRecoveryAnnouncement: PersistentAnnouncement, ActionableAnnouncement {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.ResubmitDocumentsAfterRecovery

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizedString.ctaButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self else { return }
                analyticsRecorder.record(event: actionAnalyticsEvent)
                action()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: "card-icon-v", bundle: .main),
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: .edge(40)
            ),
            title: LocalizedString.title,
            description: LocalizedString.description,
            buttons: [button],
            dismissState: .undismissible,
            didAppear: { [weak self] in
                guard let self else { return }
                analyticsRecorder.record(event: didAppearAnalyticsEvent)
            }
        )
    }

    var associatedAppModes: [AppMode] {
        [AppMode.pkw, AppMode.trading, AppMode.universal]
    }

    var shouldShow: Bool {
        needsDocumentResubmission
    }

    let type = AnnouncementType.resubmitDocumentsAfterRecovery
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let action: CardAnnouncementAction

    private let needsDocumentResubmission: Bool
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        needsDocumentResubmission: Bool,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        action: @escaping CardAnnouncementAction
    ) {
        self.needsDocumentResubmission = needsDocumentResubmission
        self.action = action
        self.analyticsRecorder = analyticsRecorder
    }
}

// MARK: SwiftUI Preview

#if DEBUG
// swiftlint:disable type_name
struct ResubmitDocumentsAfterRecoveryAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = ResubmitDocumentsAfterRecoveryAnnouncement(
            needsDocumentResubmission: true,
            action: {}
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

// swiftlint:disable type_name
struct ResubmitDocumentsAfterRecoveryAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ResubmitDocumentsAfterRecoveryAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
#endif
