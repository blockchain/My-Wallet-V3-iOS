// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class EthereumActivityDetailsPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.Activity.Details
    private typealias AccessibilityId = Accessibility.Identifier.Activity.Details

    // MARK: - DetailsScreenPresenterAPI

    let buttons: [ButtonViewModel]

    var cells: [DetailsScreen.CellType] = []

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    let navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .defaultDark

    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default

    let reloadRelay: PublishRelay<Void> = .init()

    // MARK: - Private Properties

    private let event: TransactionalActivityItemEvent
    private let router: ActivityRouterAPI
    private let interactor: EthereumActivityDetailsInteractor
    private let alertViewPresenter: AlertViewPresenterAPI
    private let loadingViewPresenter: LoadingViewPresenting
    private let disposeBag = DisposeBag()
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Private Properties (Model Relay)

    private let cellRelay: PublishRelay<[DetailsScreen.CellType]> = .init()
    private let itemRelay: BehaviorRelay<EthereumActivityDetailsViewModel?> = .init(value: nil)

    // MARK: Private Properties (LabelContentPresenting)

    private let cryptoAmountLabelPresenter: LabelContentPresenting

    // MARK: Private Properties (Badge)

    private let badgesModel = MultiBadgeViewModel()
    private let statusBadge: DefaultBadgeAssetPresenter = .init()
    private let confirmingBadge: DefaultBadgeAssetPresenter = .init()
    private let badgeCircleModel: BadgeCircleViewModel = .init()

    // MARK: Private Properties (LineItemCellPresenting)

    private let orderIDPresenter: LineItemCellPresenting
    private let dateCreatedPresenter: LineItemCellPresenting
    private let totalPresenter: LineItemCellPresenting
    private let gasForPresenter: LineItemCellPresenting
    private let networkFeePresenter: LineItemCellPresenting
    private let toPresenter: LineItemCellPresenting
    private let fromPresenter: LineItemCellPresenting

    // MARK: Private Properties (TextFieldViewModel)

    private let noteModel: TextFieldViewModel

    // MARK: Private Properties (Explorer Button)

    private let explorerButton: ButtonViewModel

    // MARK: - Init

    init(
        event: TransactionalActivityItemEvent,
        router: ActivityRouterAPI,
        interactor: EthereumActivityDetailsInteractor,
        alertViewPresenter: AlertViewPresenterAPI = resolve(),
        loadingViewPresenter: LoadingViewPresenting = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        messageRecorder: MessageRecording = resolve()
    ) {
        self.event = event
        self.router = router
        self.interactor = interactor
        self.alertViewPresenter = alertViewPresenter
        self.loadingViewPresenter = loadingViewPresenter

        self.cryptoAmountLabelPresenter = DefaultLabelContentPresenter(
            descriptors: .h1(accessibilityIdPrefix: AccessibilityId.cryptoAmountPrefix)
        )

        self.orderIDPresenter = TransactionalLineItem.orderId(event.identifier).defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        self.dateCreatedPresenter = TransactionalLineItem.date().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        self.totalPresenter = TransactionalLineItem.total().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        self.networkFeePresenter = TransactionalLineItem.networkFee().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        self.gasForPresenter = TransactionalLineItem.gasFor().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        self.toPresenter = TransactionalLineItem.to().defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        self.fromPresenter = TransactionalLineItem.from().defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        self.noteModel = TextFieldViewModel(
            with: .description,
            validator: TextValidationFactory.General.alwaysValid,
            messageRecorder: messageRecorder
        )

        self.explorerButton = .secondary(with: LocalizedString.Button.viewOnExplorer)

        switch event.type {
        case .receive:
            self.buttons = []
        case .send:
            self.buttons = [explorerButton]
        }

        bindAll(event: event)
    }

    func viewDidLoad() {
        interactor
            .details(event: event)
            .handleEvents(
                receiveOutput: { [weak self] model in
                    self?.itemRelay.accept(model)
                },
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure:
                        self?.alertViewPresenter.error(in: nil, action: nil)
                    }
                }
            )
            .subscribe()
            .store(in: &cancellables)
    }

    func bindAll(event: TransactionalActivityItemEvent) {
        itemRelay
            .compactMap { $0?.amounts.isGas }
            .distinctUntilChanged()
            .map {
                switch (event.type, $0) {
                case (.send, true):
                    return LocalizedString.Title.gas
                case (.send, _):
                    return LocalizedString.Title.send
                case (.receive, _):
                    return LocalizedString.Title.receive
                }
            }
            .map { Screen.Style.TitleView.text(value: $0) }
            .bindAndCatch(to: titleViewRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.amounts.isGas == true ? $0?.amounts.fee.cryptoAmount : $0?.amounts.trade.cryptoAmount }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: cryptoAmountLabelPresenter.interactor.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .compactMap { $0?.confirmation.statusBadge }
            .map { .loaded(next: $0) }
            .bindAndCatch(to: statusBadge.interactor.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .compactMap { $0?.confirmation.factor }
            .bindAndCatch(to: badgeCircleModel.fillRatioRelay)
            .disposed(by: disposeBag)

        itemRelay
            .compactMap { $0?.confirmation.title }
            .distinctUntilChanged()
            .map(weak: self) { (self, confirmation) in
                .loaded(next: .init(type: .progress(self.badgeCircleModel), description: confirmation))
            }
            .bindAndCatch(to: confirmingBadge.interactor.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .compactMap { $0?.confirmation.needConfirmation }
            .distinctUntilChanged()
            .map(weak: self) { (self, needConfirmation) in
                needConfirmation ? [self.statusBadge, self.confirmingBadge] : [self.statusBadge]
            }
            .bindAndCatch(to: badgesModel.badgesRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.dateCreated }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: dateCreatedPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.amounts.isGas == true ? $0?.amounts.fee.value : $0?.amounts.trade.value }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: totalPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.amounts.gasFor?.cryptoAmount }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: gasForPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.fee }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: networkFeePresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.to }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: toPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.from }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: fromPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.note ?? "" }
            .bindAndCatch(to: noteModel.originalTextRelay)
            .disposed(by: disposeBag)

        noteModel
            .focusRelay
            .filter { $0 == .off(.endEditing) }
            .mapToVoid()
            .withLatestFrom(noteModel.textRelay)
            .withLatestFrom(noteModel.originalTextRelay) { text, originalText in
                text != originalText ? text : nil
            }
            .compactMap { $0 }
            .distinctUntilChanged()
            .show(loader: loadingViewPresenter, style: .circle)
            .delay(.milliseconds(200), scheduler: MainScheduler.asyncInstance)
            .flatMap(weak: self) { (self, note) in
                self.interactor
                    .updateNote(for: self.event.identifier, to: note)
                    .hide(loader: self.loadingViewPresenter)
                    .asObservable()
            }
            .subscribe(
                onError: { [alertViewPresenter, loadingViewPresenter] _ in
                    loadingViewPresenter.hide()
                    alertViewPresenter.error(in: nil, action: nil)
                }
            )
            .disposed(by: disposeBag)

        explorerButton
            .tapRelay
            .bind { [weak self] in
                self?.router.showBlockchainExplorer(for: event)
            }
            .disposed(by: disposeBag)

        Observable
            .combineLatest(cellRelay, itemRelay)
            .mapToVoid()
            .throttle(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
            .bind(to: reloadRelay)
            .disposed(by: disposeBag)

        cellRelay
            .bindAndCatch(weak: self) { (self, cells) in
                self.cells = cells
            }
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.amounts.isGas ?? false }
            .map(weak: self) { (self, isGas) in
                self.baseCells(eventType: event.type, isGas: isGas)
            }
            .bindAndCatch(to: cellRelay)
            .disposed(by: disposeBag)
    }

    private func baseCells(
        eventType: TransactionalActivityItemEvent.EventType,
        isGas: Bool
    ) -> [DetailsScreen.CellType] {
        switch eventType {
        case .receive:
            return [
                .label(cryptoAmountLabelPresenter),
                .badges(badgesModel),
                .separator,
                .lineItem(orderIDPresenter),
                .separator,
                .lineItem(dateCreatedPresenter),
                .separator,
                .lineItem(totalPresenter),
                .separator,
                .lineItem(isGas ? gasForPresenter : networkFeePresenter),
                .separator,
                .lineItem(toPresenter),
                .separator,
                .lineItem(fromPresenter)
            ]
        case .send:
            return [
                .label(cryptoAmountLabelPresenter),
                .badges(badgesModel),
                .separator,
                .lineItem(orderIDPresenter),
                .separator,
                .lineItem(dateCreatedPresenter),
                .separator,
                .lineItem(totalPresenter),
                .separator,
                .lineItem(isGas ? gasForPresenter : networkFeePresenter),
                .separator,
                .lineItem(toPresenter),
                .separator,
                .lineItem(fromPresenter),
                .separator,
                .textField(noteModel)
            ]
        }
    }

    deinit {
        loadingViewPresenter.hide()
    }
}
