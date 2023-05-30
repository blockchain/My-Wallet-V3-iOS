// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitectureExtensions
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class UpdateMobileScreenPresenter {

    // MARK: - Types

    typealias BadgeItem = BadgeAsset.Value.Presentation.BadgeItem
    private typealias AccessibilityIDs = Accessibility.Identifier.Settings.UpdateMobile
    private typealias LocalizationIDs = LocalizationConstants.Settings.UpdateMobile

    // MARK: - Properties

    let leadingButton: Screen.Style.LeadingButton = .back

    var titleView: Screen.Style.TitleView {
        .text(value: LocalizationIDs.title)
    }

    var barStyle: Screen.Style.Bar {
        .darkContent()
    }

    var badgeState: Observable<LoadingState<BadgeItem>> {
        badgeRelay.asObservable()
    }

    var continueVisibility: Driver<PlatformUIKit.Visibility> {
        continueVisibilityRelay.asDriver()
    }

    var disable2FASMSVisibility: Driver<PlatformUIKit.Visibility> {
        disable2FASMSVisibilityRelay.asDriver()
    }

    var updateVisibility: Driver<PlatformUIKit.Visibility> {
        updateVisibilityRelay.asDriver()
    }

    let textFieldViewModel: TextFieldViewModel
    let descriptionLabel: LabelContent
    let disable2FALabel: LabelContent
    let continueButtonViewModel: ButtonViewModel
    let updateButtonViewModel: ButtonViewModel

    private let disable2FASMSVisibilityRelay = BehaviorRelay<PlatformUIKit.Visibility>(value: .hidden)
    private let continueVisibilityRelay = BehaviorRelay<PlatformUIKit.Visibility>(value: .hidden)
    private let updateVisibilityRelay = BehaviorRelay<PlatformUIKit.Visibility>(value: .hidden)
    private let badgeRelay = BehaviorRelay<LoadingState<BadgeItem>>(value: .loading)
    private let setupInteractor: UpdateMobileScreenSetupInteractor
    private let submissionInteractor: UpdateMobileScreenInteractor
    private unowned let stateService: UpdateMobileStateServiceAPI
    private let disposeBag = DisposeBag()

    init(
        stateService: UpdateMobileStateServiceAPI,
        settingsAPI: MobileSettingsServiceAPI = resolve(),
        loadingViewPresenting: LoadingViewPresenting = resolve()
    ) {
        self.stateService = stateService
        self.textFieldViewModel = .init(
            with: .mobile,
            validator: TextValidationFactory.Info.mobile,
            formatter: TextFormatterFactory.mobile,
            messageRecorder: resolve()
        )

        self.descriptionLabel = .init(
            text: LocalizationIDs.description,
            font: .main(.medium, 14.0),
            color: .semantic.text,
            accessibility: .id(AccessibilityIDs.descriptionLabel)
        )

        self.disable2FALabel = .init(
            text: LocalizationIDs.disableSMS2FA,
            font: .main(.medium, 14.0),
            color: .semantic.text,
            accessibility: .id(AccessibilityIDs.disable2FALabel)
        )

        self.continueButtonViewModel = .primary(with: "Continue", accessibilityId: AccessibilityIDs.continueButton)
        self.updateButtonViewModel = .primary(with: "Update", accessibilityId: AccessibilityIDs.updateButton)

        self.submissionInteractor = UpdateMobileScreenInteractor(service: settingsAPI)
        self.setupInteractor = UpdateMobileScreenSetupInteractor(service: settingsAPI)

        textFieldViewModel.state
            .compactMap(\.value)
            .bindAndCatch(to: submissionInteractor.contentRelay)
            .disposed(by: disposeBag)

        setupInteractor.state
            .compactMap(\.value)
            .map { $0.isSMSVerified ? .visible : .hidden }
            .bindAndCatch(to: updateVisibilityRelay)
            .disposed(by: disposeBag)

        setupInteractor.state
            .compactMap(\.value)
            .map { $0.is2FAEnabled ? .visible : .hidden }
            .bindAndCatch(to: disable2FASMSVisibilityRelay)
            .disposed(by: disposeBag)

        setupInteractor.state
            .compactMap(\.value)
            .map { !$0.is2FAEnabled }
            .bindAndCatch(to: textFieldViewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        setupInteractor.state
            .compactMap(\.value)
            .map { !$0.isSMSVerified ? .visible : .hidden }
            .bindAndCatch(to: continueVisibilityRelay)
            .disposed(by: disposeBag)

        setupInteractor.state
            .map { !$0.isLoading }
            .bindAndCatch(to: textFieldViewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        setupInteractor.state
            .map { !$0.isLoading }
            .bindAndCatch(
                to:
                continueButtonViewModel.isEnabledRelay,
                updateButtonViewModel.isEnabledRelay
            )
            .disposed(by: disposeBag)

        setupInteractor.state
            .compactMap { $0.value?.mobileNumber }
            .bindAndCatch(to: textFieldViewModel.textRelay)
            .disposed(by: disposeBag)

        setupInteractor.state
            .map { .init(with: $0) }
            .bindAndCatch(to: badgeRelay)
            .disposed(by: disposeBag)

        Observable.combineLatest(textFieldViewModel.state, setupInteractor.state)
            .compactMap { ($0.0, $0.1.value) }
            .map { $0.0.isValid && $0.1?.is2FAEnabled == false }
            .bindAndCatch(
                to:
                continueButtonViewModel.isEnabledRelay,
                updateButtonViewModel.isEnabledRelay
            )
            .disposed(by: disposeBag)

        continueButtonViewModel.tapRelay
            .bindAndCatch(to: submissionInteractor.triggerRelay)
            .disposed(by: disposeBag)

        updateButtonViewModel.tapRelay
            .bindAndCatch(to: submissionInteractor.triggerRelay)
            .disposed(by: disposeBag)

        submissionInteractor.interactionState
            .map { $0 != .updating }
            .bindAndCatch(to: continueButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        submissionInteractor.interactionState
            .bindAndCatch(weak: self, onNext: { (self, state) in
                switch state {
                case .ready:
                    loadingViewPresenting.hide()
                case .updating:
                    loadingViewPresenting.show(with: .circle, text: nil)
                case .complete:
                    loadingViewPresenting.hide()
                    stateService.nextRelay.accept(())
                case .failed:
                    self.setupInteractor.setupTrigger.accept(())
                    loadingViewPresenting.hide()
                }
            })
            .disposed(by: disposeBag)
    }
}

extension LoadingState where Content == BadgeAsset.Value.Presentation.BadgeItem {
    init(with state: LoadingState<UpdateMobileScreenSetupInteractor.InteractionModel>) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(next: let content):
            self = .loaded(
                next: .init(
                    with: content.badgeItem
                )
            )
        }
    }
}
