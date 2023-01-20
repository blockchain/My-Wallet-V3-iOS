// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class ReceiveScreenPresenter {

    // MARK: Types

    private typealias LocalizedString = LocalizationConstants.Receive
    private typealias AccessibilityID = Accessibility.Identifier.Receive
    typealias AlertContent = (title: String, subtitle: String)

    // MARK: Properties

    let alertContentRelay = BehaviorRelay<AlertContent?>(value: nil)
    let nameLabelContentPresenting: LabelContentPresenting
    let balanceLabelContentPresenting: LabelContentPresenting
    let domainLabelContentPresenting: LabelContentPresenting
    let addressLabelContentPresenting: LabelContentPresenting
    let memoLabelContentPresenting: LabelContentPresenting
    let walletDomainLabelContent: LabelContent
    let walletAddressLabelContent: LabelContent
    let memoLabelContent: LabelContent
    let memoNoteViewModel: InteractableTextViewModel
    let copyButton: ButtonViewModel
    let shareButton: ButtonViewModel
    private(set) lazy var title = "\(LocalizedString.Text.receive) \(interactor.account.currencyType.displayCode)"
    var assetImage: Driver<BadgeImageViewModel> {
        let theme = BadgeImageViewModel.Theme(
            backgroundColor: .background,
            cornerRadius: .round,
            imageViewContent: ImageViewContent(
                imageResource: interactor.account.currencyType.logoResource
            ),
            marginOffset: 0
        )
        return .just(BadgeImageViewModel(theme: theme))
    }

    var qrCode: Driver<UIImage?> {
        qrCodeRelay.asDriver()
    }

    let webViewLaunchRelay = PublishRelay<URL>()

    // MARK: Private Properties

    private var eventsRecorder: AnalyticsEventRecorderAPI
    private let qrCodeRelay = BehaviorRelay<UIImage?>(value: nil)
    private let interactor: ReceiveScreenInteractor
    private let disposeBag = DisposeBag()

    // MARK: Setup

    // swiftlint:disable function_body_length
    init(
        pasteboard: Pasteboarding = resolve(),
        eventsRecorder: AnalyticsEventRecorderAPI = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        interactor: ReceiveScreenInteractor
    ) {
        self.interactor = interactor
        self.eventsRecorder = eventsRecorder
        self.walletDomainLabelContent = LabelContent(
            text: LocalizedString.Text.domainName,
            font: .main(.semibold, 12),
            color: .titleText
        )
        self.walletAddressLabelContent = LabelContent(
            text: LocalizedString.Text.walletAddress,
            font: .main(.semibold, 12),
            color: .titleText
        )
        self.memoLabelContent = LabelContent(
            text: LocalizedString.Text.memo,
            font: .main(.semibold, 12),
            color: .titleText
        )
        self.memoNoteViewModel = InteractableTextViewModel(
            inputs: [
                .text(string: LocalizedString.Text.memoNote),
                .url(string: LocalizedString.Text.learnMore, url: Constants.Url.stellarMemo)
            ],
            textStyle: .init(color: .descriptionText, font: .main(.semibold, 12)),
            linkStyle: .init(color: .linkableText, font: .main(.semibold, 12))
        )
        self.nameLabelContentPresenting = DefaultLabelContentPresenter(
            knownValue: interactor.account.label,
            descriptors: .init(
                fontWeight: .semibold,
                contentColor: .textFieldText,
                fontSize: 16,
                accessibility: .id(AccessibilityID.walletNameLabel)
            )
        )
        self.balanceLabelContentPresenting = DefaultLabelContentPresenter(
            knownValue: "  ",
            descriptors: .init(
                fontWeight: .medium,
                contentColor: .descriptionText,
                fontSize: 14,
                accessibility: .id(AccessibilityID.balanceLabel)
            )
        )
        self.domainLabelContentPresenting = DefaultLabelContentPresenter(
            knownValue: "",
            descriptors: .init(
                fontWeight: .medium,
                contentColor: .darkTitleText,
                fontSize: 14,
                accessibility: .id(AccessibilityID.domainLabel)
            )
        )
        self.addressLabelContentPresenting = DefaultLabelContentPresenter(
            knownValue: "  ",
            descriptors: .init(
                fontWeight: .medium,
                contentColor: .darkTitleText,
                fontSize: 14,
                accessibility: .id(AccessibilityID.addressLabel)
            )
        )
        self.memoLabelContentPresenting = DefaultLabelContentPresenter(
            knownValue: "",
            descriptors: .init(
                fontWeight: .medium,
                contentColor: .darkTitleText,
                fontSize: 14,
                accessibility: .id(AccessibilityID.memoLabel)
            )
        )
        self.copyButton = .secondary(with: LocalizedString.Button.copy)
        self.shareButton = .primary(with: LocalizedString.Button.share)

        let state = interactor.state
            .asObservable()
            .share(replay: 1)

        state
            .map { [enabledCurrenciesService] state -> AlertContent? in
                guard let state else {
                    return nil
                }
                let currency = state.currency
                guard let erc20ParentChain: String = currency
                    .cryptoCurrency?
                    .assetModel
                    .kind
                    .erc20ParentChain
                else {
                    return nil
                }
                let networkName: String? = enabledCurrenciesService.allEnabledEVMNetworks
                    .first(where: { $0.networkConfig.networkTicker == erc20ParentChain })?
                    .networkConfig
                    .shortName

                let title = LocalizedString.Text.alertTitle(
                    displayCode: currency.displayCode,
                    networkName: networkName ?? erc20ParentChain
                )
                let subtitle = LocalizedString.Text.alertBody(
                    displayCode: currency.displayCode,
                    networkName: networkName ?? erc20ParentChain
                )
                return (title: title, subtitle: subtitle)
            }
            .bind(to: alertContentRelay)
            .disposed(by: disposeBag)

        let qrCodeMetadata = state
            .map { state in
                state?.qrCodeMetadata
            }

        qrCodeMetadata
            .map { metadata -> UIImage? in
                guard let content = metadata?.content else {
                    return nil
                }
                return QRCode(string: content)?.image
            }
            .bindAndCatch(to: qrCodeRelay)
            .disposed(by: disposeBag)

        qrCodeMetadata
            .map { metadata -> String in
                metadata?.title ?? ""
            }
            .map { LabelContent.Value.Interaction.Content(text: $0) }
            .map { .loaded(next: $0) }
            .bindAndCatch(to: addressLabelContentPresenting.interactor.stateRelay)
            .disposed(by: disposeBag)

        interactor.account
            .balance
            .map(\.displayString)
            .asObservable()
            .mapToLabelContentStateInteraction()
            .catchAndReturn(.loading)
            .bindAndCatch(to: balanceLabelContentPresenting.interactor.stateRelay)
            .disposed(by: disposeBag)

        state
            .map { state -> String? in
                state?.memo ?? nil
            }
            .compactMap { $0 }
            .map { LabelContent.Value.Interaction.Content(text: $0) }
            .map { .loaded(next: $0) }
            .bindAndCatch(to: memoLabelContentPresenting.interactor.stateRelay)
            .disposed(by: disposeBag)

        state
            .map { state -> String? in
                state?.domainNames.first
            }
            .compactMap { $0 }
            .map { LabelContent.Value.Interaction.Content(text: $0) }
            .map { .loaded(next: $0) }
            .bindAndCatch(to: domainLabelContentPresenting.interactor.stateRelay)
            .disposed(by: disposeBag)

        memoNoteViewModel.tap
            .map(\.url)
            .bindAndCatch(to: webViewLaunchRelay)
            .disposed(by: disposeBag)

        // MARK: - Copy

        copyButton.tapRelay
            .bind { [eventsRecorder, account = interactor.account] in
                eventsRecorder.record(event:
                    AnalyticsEvents.New.Receive.receiveDetailsCopied(
                        accountType: .init(account as? CryptoAccount),
                        currency: account.currencyType.code
                    )
                )
            }
            .disposed(by: disposeBag)

        copyButton.tapRelay
            .withLatestFrom(qrCodeMetadata.compactMap(\.wrapped).map(\.title))
            .bind { pasteboard.string = $0 }
            .disposed(by: disposeBag)

        copyButton.tapRelay
            .bind(onNext: { _ in
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred()
            })
            .disposed(by: disposeBag)

        copyButton.tapRelay
            .map { _ in
                ButtonViewModel.Theme(
                    backgroundColor: .successButton,
                    contentColor: .white,
                    text: LocalizedString.Button.copied
                )
            }
            .bind(onNext: { [copyButton] theme in
                copyButton.animate(theme: theme)
            })
            .disposed(by: disposeBag)

        copyButton.tapRelay
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .map { _ in
                ButtonViewModel.secondary(
                    with: LocalizedString.Button.copy
                ).theme
            }
            .bind(onNext: { [copyButton] theme in
                copyButton.animate(theme: theme)
            })
            .disposed(by: disposeBag)

        // MARK: - Share

        shareButton.tapRelay
            .withLatestFrom(qrCodeMetadata)
            .subscribe(onNext: { [weak self] metadata in
                guard let self else {
                    return
                }
                guard let metadata else {
                    return
                }
                let currencyType = self.interactor.account.currencyType
                self.interactor.receiveRouter.shareDetails(
                    for: metadata,
                    currencyType: currencyType
                )
            })
            .disposed(by: disposeBag)
    }
}
