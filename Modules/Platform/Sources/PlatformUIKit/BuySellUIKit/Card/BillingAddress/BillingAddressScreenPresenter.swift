// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import DIKit
import FeatureCardPaymentDomain
import Localization
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class BillingAddressScreenPresenter: RibBridgePresenter {

    // MARK: - Types

    enum CellType: Equatable {
        case selectionView
        case textField(TextFieldType)
        case doubleTextField(TextFieldType, TextFieldType)
    }

    struct PresentationData {
        let cellTypes: [CellType]

        var cellCount: Int {
            cellTypes.count
        }

        init(country: FeatureCardPaymentDomain.Country) {
            var cellTypes: [CellType] = [
                .selectionView,
                .textField(.personFullName),
                .textField(.addressLine(1)),
                .textField(.addressLine(2)),
                .textField(.city)
            ]
            switch country {
            case .US:
                cellTypes += [
                    .doubleTextField(.state, .postcode)
                ]
            default:
                cellTypes += [
                    .textField(.postcode)
                ]
            }
            self.cellTypes = cellTypes
        }

        func row(for cellType: CellType) -> Int {
            cellTypes.enumerated().first { $0.element == cellType }!.offset
        }

        func cellType(for row: Int) -> CellType {
            cellTypes[row]
        }
    }

    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.BillingAddressScreen

    // MARK: - Properties

    let app: AppProtocol
    let title = LocalizedString.title
    let buttonViewModel: ButtonViewModel

    let presentationDataRelay = BehaviorRelay(value: PresentationData(country: .US))

    let selectionButtonViewModel: SelectionButtonViewModel

    var refresh: Signal<Void> {
        refreshRelay.asSignal()
    }

    var isValid: Driver<Bool> {
        isValidRelay.asDriver()
    }

    var textFieldViewModelsMap: [TextFieldType: TextFieldViewModel] {
        textFieldViewModelsMapRelay.value
    }

    var errorTrigger: Signal<Error> {
        errorTriggerRelay.asSignal()
    }

    let textFieldViewModelsMapRelay = BehaviorRelay<[TextFieldType: TextFieldViewModel]>(value: [:])

    private let errorTriggerRelay = PublishRelay<Error>()
    private let isValidRelay = BehaviorRelay(value: false)
    private let refreshRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()

    // MARK: - Injected

    private let interactor: BillingAddressScreenInteractor
    private let countrySelectionRouter: SelectionRouterAPI
    private let loadingViewPresenter: LoadingViewPresenting
    private let eventRecorder: AnalyticsEventRecorderAPI
    private let messageRecorder: MessageRecording
    private let userDataRepository: DataRepositoryAPI

    init(
        app: AppProtocol = resolve(),
        interactor: BillingAddressScreenInteractor,
        countrySelectionRouter: SelectionRouterAPI,
        loadingViewPresenter: LoadingViewPresenting = resolve(),
        eventRecorder: AnalyticsEventRecorderAPI,
        messageRecorder: MessageRecording,
        userDataRepository: DataRepositoryAPI = resolve()
    ) {
        self.app = app
        self.interactor = interactor
        self.countrySelectionRouter = countrySelectionRouter
        self.loadingViewPresenter = loadingViewPresenter
        self.eventRecorder = eventRecorder
        self.messageRecorder = messageRecorder
        self.userDataRepository = userDataRepository

        self.selectionButtonViewModel = SelectionButtonViewModel()
        selectionButtonViewModel.shouldShowSeparatorRelay.accept(true)

        self.buttonViewModel = .primary(with: LocalizedString.button)

        super.init(interactable: interactor)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Country is selected
        // 2. `PresentationData` is regenerated
        // 3. Data is mapped into text field view models
        // 4. A layout refresh is triggered

        interactor.selectedCountry
            .map { .text($0.flag) }
            .bindAndCatch(to: selectionButtonViewModel.leadingContentTypeRelay)
            .disposed(by: disposeBag)

        interactor.selectedCountry
            .map(\.name)
            .bindAndCatch(to: selectionButtonViewModel.titleRelay)
            .disposed(by: disposeBag)

        interactor.selectedCountry
            .map(\.code)
            .bindAndCatch(to: selectionButtonViewModel.subtitleRelay)
            .disposed(by: disposeBag)

        interactor.selectedCountry
            .map { .init(id: $0.code, label: $0.name) }
            .bindAndCatch(to: selectionButtonViewModel.accessibilityContentRelay)
            .disposed(by: disposeBag)

        interactor.selectedCountry
            .map { PresentationData(country: $0) }
            .bindAndCatch(to: presentationDataRelay)
            .disposed(by: disposeBag)

        presentationDataRelay
            .map(weak: self) { (self, data) in
                self.transformPresentationDataIntoViewModels(data)
            }
            .bindAndCatch(to: textFieldViewModelsMapRelay)
            .disposed(by: disposeBag)

        textFieldViewModelsMapRelay
            .mapToVoid()
            .bindAndCatch(to: refreshRelay)
            .disposed(by: disposeBag)

        selectionButtonViewModel.trailingContentRelay.accept(
            .image(
                ImageViewContent(
                    imageResource: .local(name: "icon-disclosure-down-small", bundle: .platformUIKit)
                )
            )
        )

        selectionButtonViewModel.tap
            .emit(onNext: { [unowned self] in
                self.showCountrySelectionScreen()
            })
            .disposed(by: disposeBag)

        let viewModelsObservable = textFieldViewModelsMapRelay
            .map { textFieldMap -> [TextFieldViewModel?] in
                [
                    textFieldMap[.personFullName],
                    textFieldMap[.addressLine(1)],
                    textFieldMap[.addressLine(2)],
                    textFieldMap[.city],
                    textFieldMap[.postcode],
                    textFieldMap[.state]
                ]
            }
            .map { viewModels in
                viewModels.compactMap { $0 }
            }

        Observable.combineLatest(textFieldViewModelsMapRelay, userDataRepository.user.asObservable())
            .subscribe(onNext: { textfields, user in
                textfields[.personFullName]?.textRelay.accept(user.personalDetails.fullName)
                textfields[.addressLine(1)]?.textRelay.accept(user.address?.lineOne ?? "")
                textfields[.addressLine(2)]?.textRelay.accept(user.address?.lineTwo ?? "")
                textfields[.city]?.textRelay.accept(user.address?.city ?? "")
                textfields[.postcode]?.textRelay.accept(user.address?.postalCode ?? "")
                textfields[.state]?.textRelay.accept(user.address?.state ?? "")
            })
            .disposed(by: disposeBag)

        let stateArrayObservable = viewModelsObservable
            .map { viewModels in
                viewModels.map(\.state)
            }
            .flatMap { Observable.combineLatest($0) }

        let statesTuple = stateArrayObservable
            .map { states in
                (
                    name: states[0],
                    addressLine1: states[1],
                    addressLine2: states[2],
                    city: states[3],
                    postcode: states[4],
                    state: states[safe: 5]
                )
            }

        let billingAddress = Observable
            .combineLatest(
                statesTuple,
                interactor.selectedCountry
            )
            .map { payload -> BillingAddress? in
                let states = payload.0
                let country = payload.1
                return BillingAddress(
                    country: country,
                    fullName: states.name.value,
                    addressLine1: states.addressLine1.value,
                    addressLine2: states.addressLine2.value,
                    city: states.city.value,
                    state: states.state?.value ?? "",
                    postCode: states.postcode.value
                )
            }
            .share(replay: 1)

        billingAddress
            .compactMap { $0 }
            .bindAndCatch(to: interactor.billingAddressRelay)
            .disposed(by: disposeBag)

        billingAddress
            .map { $0 != nil }
            .bindAndCatch(to: isValidRelay)
            .disposed(by: disposeBag)

        isValid
            .drive(buttonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        buttonViewModel.tapRelay
            .subscribe(onNext: { [app] in
                app.post(event: blockchain.ux.transaction.payment.method.link.a.card.billing.address.save.my.card.tap)
            })
            .disposed(by: disposeBag)

        buttonViewModel.tapRelay
            .withLatestFrom(interactor.billingAddress)
            .bindAndCatch(weak: self) { (self, billingAddress) in
                self.eventRecorder.record(event: AnalyticsEvent.sbBillingAddressSet)
                self.add(billingAddress: billingAddress)
            }
            .disposed(by: disposeBag)
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        app.post(event: blockchain.ux.transaction.payment.method.link.a.card.billing.address)
    }

    private func add(billingAddress: BillingAddress) {
        interactor
            .add(billingAddress: billingAddress)
            .handleLoaderForLifecycle(
                loader: loadingViewPresenter,
                style: .circle,
                text: LocalizedString.linkingYourCard
            )
            .subscribe(
                onError: { [weak errorTriggerRelay] error in
                    errorTriggerRelay?.accept(error)
                }
            )
            .disposed(by: disposeBag)
    }

    private func transformPresentationDataIntoViewModels(_ data: PresentationData) -> [TextFieldType: TextFieldViewModel] {

        func viewModel(by type: TextFieldType, returnKeyType: UIReturnKeyType) -> TextFieldViewModel {
            TextFieldViewModel(
                with: type,
                returnKeyType: returnKeyType,
                validator: TextValidationFactory.General.notEmpty,
                messageRecorder: messageRecorder
            )
        }

        var viewModelByType: [TextFieldType: TextFieldViewModel] = [:]
        var previousTextFieldViewModel: TextFieldViewModel?
        for (index, cell) in data.cellTypes.enumerated() {
            switch cell {
            case .doubleTextField(let leadingType, let trailingType):
                let leading = viewModel(by: leadingType, returnKeyType: .next)
                let trailing = viewModel(by: trailingType, returnKeyType: .done)

                viewModelByType[leadingType] = leading
                viewModelByType[trailingType] = trailing

                previousTextFieldViewModel?.set(next: leading)
                leading.set(next: trailing)

                previousTextFieldViewModel = trailing
            case .textField(let type):
                let textFieldViewModel = viewModel(
                    by: type,
                    returnKeyType: index == data.cellTypes.count - 1 ? .done : .next
                )

                viewModelByType[type] = textFieldViewModel

                previousTextFieldViewModel?.set(next: textFieldViewModel)

                previousTextFieldViewModel = textFieldViewModel
            case .selectionView:
                break
            }
        }
        return viewModelByType
    }

    private func showCountrySelectionScreen() {
        countrySelectionRouter.showSelectionScreen(
            screenTitle: LocalizationConstants.CountrySelectionScreen.title,
            searchBarPlaceholder: LocalizationConstants.CountrySelectionScreen.searchBarPlaceholder,
            using: interactor.countrySelectionService
        )
    }

    // MARK: - Navigation

    func previous() {
        interactor.previous()
    }
}
