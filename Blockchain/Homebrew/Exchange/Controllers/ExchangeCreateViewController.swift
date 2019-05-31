//
//  ExchangeCreateViewController.swift
//  Blockchain
//
//  Created by kevinwu on 8/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit
import PlatformKit
import SafariServices
import RxSwift

protocol ExchangeCreateDelegate: NumberKeypadViewDelegate {
    func onViewDidLoad()
    func onViewWillAppear()
    func onViewDidDisappear()
    func onDisplayRatesTapped()
    func onExchangeButtonTapped()
    func onSwapButtonTapped()
    var rightNavigationCTAType: NavigationCTAType { get }
}

// swiftlint:disable line_length
class ExchangeCreateViewController: UIViewController {
    
    // MARK: Private Static Properties
    
    static let isLargerThan5S: Bool = Constants.Booleans.IsUsingScreenSizeLargerThan5s
    static let primaryFontName: String = Constants.FontNames.montserratMedium
    static let primaryFontSize: CGFloat = isLargerThan5S ? 64.0 : Constants.FontSizes.Gigantic
    static let secondaryFontName: String = Constants.FontNames.montserratRegular
    static let secondaryFontSize: CGFloat = Constants.FontSizes.Huge

    // MARK: - IBOutlets

    @IBOutlet private var tradingPairView: TradingPairView!
    @IBOutlet private var numberKeypadView: NumberKeypadView!

    // Label to be updated when amount is being typed in
    @IBOutlet private var primaryAmountLabel: UILabel!

    // Amount being typed in converted to input crypto or input fiat
    @IBOutlet private var secondaryAmountLabel: UILabel!
    @IBOutlet private var walletBalanceLabel: UILabel!
    @IBOutlet private var conversionRateLabel: UILabel!
    
    fileprivate var trigger: ActionableTrigger?
    @IBOutlet private var exchangeButton: UIButton!
    @IBOutlet private var exchangeButtonBottomConstraint: NSLayoutConstraint!
    
    enum PresentationUpdate {
        case wiggleInputLabels
        case wigglePrimaryLabel
        case updatePrimaryLabel(NSAttributedString?)
        case updateSecondaryLabel(String?)
        case actionableErrorLabelTrigger(ActionableTrigger)
        case loadingIndicator(Visibility)
    }
    
    enum ViewUpdate: Update {
        case exchangeButton(Visibility)
    }
    
    enum TransitionUpdate: Transition {
        case updateConversionRateLabel(NSAttributedString)
        case updateBalanceLabel(NSAttributedString)
        case primaryLabelTextColor(UIColor)
    }

    // MARK: Public Properties

    weak var delegate: ExchangeCreateDelegate?

    // MARK: Private Properties

    fileprivate var presenter: ExchangeCreatePresenter!
    fileprivate var dependencies: ExchangeDependencies = ExchangeServices()
    fileprivate var assetAccountListPresenter: ExchangeAssetAccountListPresenter!
    fileprivate var fromAccount: AssetAccount!
    fileprivate var toAccount: AssetAccount!
    fileprivate let disposables = CompositeDisposable()

    // MARK: Lifecycle
    
    deinit {
        disposables.dispose()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.Swap.swap
        exchangeButton.accessibilityIdentifier = AccessibilityIdentifiers.ExchangeScreen.exchangeButton
        let disposable = dependenciesSetup()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in
                guard let self = self else { return }
                self.viewsSetup()
                self.delegate?.onViewDidLoad()
            })
        disposables.insertWithDiscardableResult(disposable)
        exchangeButton.isExclusiveTouch = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.onViewWillAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.onViewDidDisappear()
    }

    // MARK: Private

    private func viewsSetup() {
        [primaryAmountLabel, secondaryAmountLabel].forEach {
            $0?.textColor = UIColor.brandPrimary
        }
        
        [walletBalanceLabel, conversionRateLabel].forEach {
            let font = Font(.branded(.montserratMedium), size: .custom(12.0)).result
            $0?.attributedText = NSAttributedString(string: "\n\n", attributes: [.font: font])
        }
        
        tradingPairView.delegate = self

        exchangeButton.layer.cornerRadius = Constants.Measurements.buttonCornerRadius

        exchangeButton.setTitle(LocalizationConstants.Swap.exchange, for: .normal)
        
        let isAboveSE = UIDevice.current.type.isAbove(.iPhoneSE)
        exchangeButtonBottomConstraint.constant = isAboveSE ? 16.0 : 0.0
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    fileprivate func dependenciesSetup() -> Completable {
        return Completable.create(subscribe: { [weak self] observer -> Disposable in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }
            let btcAccount = self.dependencies.assetAccountRepository.accounts(for: .bitcoin)
            let ethAccount = self.dependencies.assetAccountRepository.accounts(for: .ethereum)
            
            let disposable = Maybe.zip(btcAccount, ethAccount)
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] (bitcoin, ethereum) in
                    guard let self = self else { return }
                    guard let bitcoinAccount = bitcoin.first else { return }
                    guard let ethereumAccount = ethereum.first else { return }
                    self.fromAccount = bitcoinAccount
                    self.toAccount = ethereumAccount
                    // DEBUG - ideally add an .empty state for a blank/loading state for MarketsModel here.
                    let interactor = ExchangeCreateInteractor(
                        dependencies: self.dependencies,
                        model: MarketsModel(
                            marketPair: MarketPair(fromAccount: self.fromAccount, toAccount: self.toAccount),
                            fiatCurrencyCode: BlockchainSettings.sharedAppInstance().fiatCurrencyCode ?? "USD",
                            fiatCurrencySymbol: BlockchainSettings.App.shared.fiatCurrencySymbol,
                            fix: .baseInFiat,
                            volume: "0"
                        )
                    )
                    self.assetAccountListPresenter = ExchangeAssetAccountListPresenter(view: self)
                    self.numberKeypadView.delegate = self
                    self.presenter = ExchangeCreatePresenter(interactor: interactor)
                    self.presenter.interface = self
                    interactor.output = self.presenter
                    self.delegate = self.presenter
                    observer(.completed)
                })
            self.disposables.insertWithDiscardableResult(disposable)
            return Disposables.create()
        })
    }
    
    fileprivate func presentURL(_ url: URL) {
        let viewController = SFSafariViewController(url: url)
        guard let controller = AppCoordinator.shared.tabControllerManager.tabViewController else { return }
        viewController.modalPresentationStyle = .overCurrentContext
        controller.present(viewController, animated: true, completion: nil)
    }
    
    // MARK: - IBActions

    @IBAction private func ratesViewTapped(_ sender: UITapGestureRecognizer) {
        delegate?.onDisplayRatesTapped()
    }
    
    @IBAction private func exchangeButtonTapped(_ sender: Any) {
        delegate?.onExchangeButtonTapped()
    }
}

// MARK: - Styling
extension ExchangeCreateViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    private func addStyleToView(_ viewToEdit: UIView) {
        viewToEdit.layer.cornerRadius = 4.0
        viewToEdit.layer.borderWidth = 1.0
        viewToEdit.layer.borderColor = UIColor.brandPrimary.cgColor
    }
}

extension ExchangeCreateViewController: NumberKeypadViewDelegate {
    func onDelimiterTapped() {
        delegate?.onDelimiterTapped()
    }
    
    func onAddInputTapped(value: String) {
        delegate?.onAddInputTapped(value: value)
    }

    func onBackspaceTapped() {
        delegate?.onBackspaceTapped()
    }
}

extension ExchangeCreateViewController: ExchangeCreateInterface {
    
    func exchangeStatusUpdated() {
        guard let navController = navigationController as? BaseNavigationController else { return }
        navController.update()
        
    }
    
    func showTiers() {
        let disposable = KYCTiersViewController.routeToTiers(
            fromViewController: self
        )
        disposables.insertWithDiscardableResult(disposable)
    }
    
    func apply(transitionPresentation: TransitionPresentationUpdate<ExchangeCreateInterface.TransitionUpdate>) {
        transitionPresentation.transitionType.perform(with: view, animations: { [weak self] in
            guard let this = self else { return }
            transitionPresentation.transitions.forEach({ this.apply(transition: $0) })
        })
    }
    
    func apply(transitionUpdateGroup: ExchangeCreateInterface.TransitionUpdateGroup) {
        let completion: () -> Void = {
            transitionUpdateGroup.finish()
        }
        transitionUpdateGroup.preparations.forEach({ apply(transition: $0) })
        transitionUpdateGroup.transitionType.perform(with: view, animations: { [weak self] in
            transitionUpdateGroup.transitions.forEach({ self?.apply(transition: $0) })
        }, completion: completion)
    }
    
    func apply(presentationUpdateGroup: ExchangeCreateInterface.PresentationUpdateGroup) {
        let completion: () -> Void = {
            presentationUpdateGroup.finish()
        }
        presentationUpdateGroup.preparations.forEach({ apply(update: $0) })
        presentationUpdateGroup.animationType.perform(animations: { [weak self] in
            presentationUpdateGroup.animations.forEach({ self?.apply(update: $0) })
        }, completion: completion)
    }
    
    func apply(presentationUpdates: [ExchangeCreateInterface.PresentationUpdate]) {
        presentationUpdates.forEach({ apply(presentationUpdate: $0) })
    }
    
    func apply(animatedUpdate: ExchangeCreateInterface.AnimatedUpdate) {
        animatedUpdate.animationType.perform(animations: { [weak self] in
            guard let this = self else { return }
            animatedUpdate.animations.forEach({ this.apply(update: $0) })
        })
    }
    
    func apply(viewUpdates: [ExchangeCreateInterface.ViewUpdate]) {
        viewUpdates.forEach({ apply(update: $0) })
    }
    
    func apply(transition: TransitionUpdate) {
        switch transition {
        case .primaryLabelTextColor(let color):
            primaryAmountLabel.textColor = color
        case .updateConversionRateLabel(let attributedString):
            conversionRateLabel.attributedText = attributedString
        case .updateBalanceLabel(let attributedString):
            walletBalanceLabel.attributedText = attributedString
        }
    }
    
    func apply(update: ViewUpdate) {
        switch update {
        case .exchangeButton(let visibility):
            exchangeButton.alpha = visibility.defaultAlpha
        }
    }
    
    func apply(presentationUpdate: PresentationUpdate) {
        switch presentationUpdate {
        case .loadingIndicator(let visibility):
            switch visibility {
            case .visible:
                LoadingViewPresenter.shared.showBusyView(
                    withLoadingText: LocalizationConstants.Exchange.confirming
                )
            case .hidden:
                LoadingViewPresenter.shared.hideBusyView()
            default:
                Logger.shared.warning("Visibility not handled")
            }
        case .updatePrimaryLabel(let value):
            primaryAmountLabel.attributedText = value
        case .updateSecondaryLabel(let value):
            secondaryAmountLabel.text = value
        case .wiggleInputLabels:
            primaryAmountLabel.wiggle()
            secondaryAmountLabel.wiggle()
        case .wigglePrimaryLabel:
            primaryAmountLabel.wiggle()
        case .actionableErrorLabelTrigger(let trigger):
            break
        }
    }

    func updateTradingPairView(pair: TradingPair, fix: Fix) {
        let fromAsset = pair.from
        let toAsset = pair.to

        let transitionUpdate = TradingPairView.TradingTransitionUpdate(
            transitions: [
                .images(left: fromAsset.whiteImageSmall, right: toAsset.whiteImageSmall),
                .titles(left: "", right: "")
            ],
            transition: .crossFade(duration: 0.2)
        )

        let presentationUpdate = TradingPairView.TradingPresentationUpdate(
            animations: [
                .backgroundColors(left: fromAsset.brandColor, right: toAsset.brandColor),
                .swapTintColor(#colorLiteral(red: 0, green: 0.2901960784, blue: 0.4862745098, alpha: 1)),
                .titleColor(#colorLiteral(red: 0, green: 0.2901960784, blue: 0.4862745098, alpha: 1))
            ],
            animation: .none
        )
        let model = TradingPairView.Model(
            transitionUpdate: transitionUpdate,
            presentationUpdate: presentationUpdate
        )
        tradingPairView.apply(model: model)
    }

    func updateTradingPairViewValues(left: String, right: String) {
        let transitionUpdate = TradingPairView.TradingTransitionUpdate(
            transitions: [.titles(left: left, right: right)],
            transition: .none
        )
        tradingPairView.apply(transitionUpdate: transitionUpdate)
    }
    
    func exchangeButtonEnabled(_ enabled: Bool) {
        exchangeButton.isEnabled = enabled
        exchangeButton.alpha = enabled ? 1.0 : 0.5
    }

    func isExchangeButtonEnabled() -> Bool {
        return exchangeButton.isEnabled
    }
    
    func showSummary(orderTransaction: OrderTransaction, conversion: Conversion) {
        let model = ExchangeDetailPageModel(type: .confirm(orderTransaction, conversion))
        let confirmController = ExchangeDetailViewController.make(with: model, dependencies: ExchangeServices())
        navigationController?.pushViewController(confirmController, animated: true)
    }
}

// MARK: - TradingPairViewDelegate

extension ExchangeCreateViewController: TradingPairViewDelegate {
    func onLeftButtonTapped(_ view: TradingPairView, title: String) {
        assetAccountListPresenter.presentPicker(excludingAccount: fromAccount, for: .exchanging)
    }

    func onRightButtonTapped(_ view: TradingPairView, title: String) {
        assetAccountListPresenter.presentPicker(excludingAccount: toAccount, for: .receiving)
    }

    func onSwapButtonTapped(_ view: TradingPairView) {
        // TICKET: https://blockchain.atlassian.net/browse/IOS-1350
    }
}

// MARK: - ExchangeAssetAccountListView

extension ExchangeCreateViewController: ExchangeAssetAccountListView {
    func showPicker(for assetAccounts: [AssetAccount], action: ExchangeAction) {
        let actionSheetController = UIAlertController(title: action.title, message: nil, preferredStyle: .actionSheet)

        // Insert actions
        assetAccounts.forEach { account in
            let alertAction = UIAlertAction(title: account.name, style: .default, handler: { [unowned self] _ in
                Logger.shared.debug("Selected account titled: '\(account.name)' of type: '\(account.address.assetType.symbol)'")
                
                /// Note: Users should not be able to exchange between
                /// accounts with the same assetType.
                switch action {
                case .exchanging:
                    if account.address.assetType == self.toAccount.address.assetType {
                        self.toAccount = self.fromAccount
                    }
                    
                    self.fromAccount = account
                case .receiving:
                    if account.address.assetType == self.fromAccount.address.assetType {
                        self.fromAccount = self.toAccount
                    }
                    self.toAccount = account
                }
                self.onTradingPairChanged()
            })
            actionSheetController.addAction(alertAction)
        }
        actionSheetController.addAction(
            UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        )
        
        present(actionSheetController, animated: true)
    }

    private func onTradingPairChanged() {
        presenter.changeMarketPair(
            marketPair: MarketPair(
                fromAccount: fromAccount,
                toAccount: toAccount
            )
        )
    }
}

extension ExchangeCreateViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalAnimator(operation: .dismiss, duration: 0.4)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalAnimator(operation: .present, duration: 0.4)
    }
}

extension ExchangeCreateViewController: ActionableLabelDelegate {
    func targetRange(_ label: ActionableLabel) -> NSRange? {
        return trigger?.actionRange()
    }

    func actionRequestingExecution(label: ActionableLabel) {
        guard let trigger = trigger else { return }
        trigger.execute()
    }
}

extension ExchangeCreateViewController: NavigatableView {
    var leftCTATintColor: UIColor {
        return .white
    }
    
    var rightCTATintColor: UIColor {
        guard let presenter = presenter else { return .white }
        if case .error(let value) = presenter.status {
            return value == .noVolumeProvided ? .white : .pending
        }
        
        return .white
    }
    
    var leftNavControllerCTAType: NavigationCTAType {
        return .menu
    }
    
    var rightNavControllerCTAType: NavigationCTAType {
        return delegate?.rightNavigationCTAType ?? .help
    }
    
    var navigationDisplayMode: NavigationBarDisplayMode {
        return .dark
    }
    
    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        if case let .error(value) = presenter.status, value != .noVolumeProvided {
            
            let action = AlertAction(style: .default(LocalizationConstants.Exchange.done))
            var actions = [action]
            if let url = value.url {
                let learnMore = AlertAction(
                    style: .confirm(LocalizationConstants.Exchange.learnMore),
                    metadata: .url(url)
                )
                actions.append(learnMore)
            }
            let model = AlertModel(
                headline: value.title,
                body: value.description,
                actions: actions,
                image: value.image,
                style: .sheet
            )
            let alert = AlertView.make(with: model) { [weak self] action in
                guard let self = self else { return }
                guard let data = action.metadata else { return }
                guard case let .url(url) = data else { return }
                self.presentURL(url)
            }
            alert.show()
            return
        }
        
        guard let endpoint = URL(string: "https://blockchain.zendesk.com/") else { return }
        guard let url = URL.endpoint(
            endpoint,
            pathComponents: ["hc", "en-us", "requests", "new"],
            queryParameters: ["ticket_form_id" : "360000180551"]
            ) else { return }
        
        let orderHistory = BottomSheetAction(title: LocalizationConstants.Swap.orderHistory, metadata: .block({
            guard let root = UIApplication.shared.keyWindow?.rootViewController else {
                Logger.shared.error("No navigation controller found")
                return
            }
            let controller = ExchangeListViewController.make(with: self.dependencies)
            let navController = BaseNavigationController(rootViewController: controller)
            navController.modalTransitionStyle = .coverVertical
            root.present(navController, animated: true, completion: nil)
        }))
        let viewLimits = BottomSheetAction(title: LocalizationConstants.Swap.viewMySwapLimit, metadata: .block({
            _ = KYCTiersViewController.routeToTiers(fromViewController: self)
        }))
        let contactSupport = BottomSheetAction(title: LocalizationConstants.KYC.contactSupport, metadata: .url(url))
        let model = BottomSheet(
            title: LocalizationConstants.Swap.swapInfo,
            dismissalTitle: LocalizationConstants.Swap.close,
            actions: [orderHistory, contactSupport, viewLimits]
        )
        let sheet = BottomSheetView.make(with: model) { [weak self] action in
            guard let this = self else { return }
            guard let value = action.metadata else { return }
            
            switch value {
            case .url(let url):
                this.presentURL(url)
            case .block(let block):
                block()
            case .pop:
                this.navigationController?.popViewController(animated: true)
            case .dismiss:
                this.dismiss(animated: true, completion: nil)
            case .payload:
                break
            }
        }
        sheet.show()
    }
    
    func navControllerLeftBarButtonTapped(_ navController: UINavigationController) {
        AppCoordinator.shared.toggleSideMenu()
    }
}
