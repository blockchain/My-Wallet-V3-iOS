// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import FeatureWalletConnectDomain
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

final class QRCodeScannerOverlayViewModel {

    /// The visibility of the camera roll button
    var cameraRollButtonVisibility: AnyPublisher<Visibility, Never> {
        cameraRollButtonVisibilityRelay.eraseToAnyPublisher()
    }

    var titleLabelContent: AnyPublisher<LabelContent, Never> {
        titleLabelContentRelay.eraseToAnyPublisher()
    }

    var subtitleLabelContent: AnyPublisher<LabelContent, Never> {
        subtitleLabelContentRelay.eraseToAnyPublisher()
    }

    /// Is the flash enabled
    var flashEnabled: AnyPublisher<Bool, Never> {
        qrCodeFlashService.isEnabled.eraseToAnyPublisher()
    }

    /// Streams events when a scan was successful
    let scanSuccess = PassthroughSubject<Result<Bool, Error>, Never>()

    /// Streams events when the flash button is tapped
    let flashTapRelay = PassthroughSubject<Void, Never>()

    /// Streams events when the camera button is tapped
    let cameraTapRelay = PassthroughSubject<Void, Never>()

    /// Closure for handling camera tap events
    var cameraButtonTapped: (() -> Void)?


    private let analyticsEventRecorder: AnalyticsEventRecorderAPI
    private let qrCodeFlashService = QRCodeScannerFlashService()
    private let cameraRollButtonVisibilityRelay = CurrentValueSubject<Visibility, Never>(.hidden)
    private let titleLabelContentRelay = CurrentValueSubject<LabelContent, Never>(.empty)
    private let subtitleLabelContentRelay = CurrentValueSubject<LabelContent, Never>(.empty)
    private var cancellables = [AnyCancellable]()

    init(
        supportsCameraRoll: Bool,
        titleText: String?,
        subtitleText: String? = nil,
        featureFlagsService: FeatureFlagsServiceAPI,
        analyticsEventRecorder: AnalyticsEventRecorderAPI
    ) {
        self.analyticsEventRecorder = analyticsEventRecorder
        cameraRollButtonVisibilityRelay.send(.init(boolValue: supportsCameraRoll))
        if let subtitleText {
            let labelContent = LabelContent(
                text: subtitleText,
                font: .main(.medium, 14),
                color: .white,
                alignment: .left
            )
            subtitleLabelContentRelay.send(labelContent)
        }
        if let titleText {
            let titleContent = LabelContent(
                text: titleText,
                font: .main(.semibold, 16),
                color: .white,
                alignment: .center
            )
            titleLabelContentRelay.send(titleContent)
        }
        flashTapRelay
            .sink { [weak self] _ in
                self?.toggleFlash()
            }
            .store(in: &cancellables)

        cameraTapRelay
            .sink { [weak self] in
                self?.cameraButtonTapped?()
            }
            .store(in: &cancellables)
    }

    private func toggleFlash() {
        qrCodeFlashService.toggleFlash()
    }
}
