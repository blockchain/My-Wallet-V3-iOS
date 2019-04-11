//
//  DashboardController.swift
//  Blockchain
//
//  Created by Maurice A. on 9/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import Charts
import PlatformKit
import RxSwift

@objc
final class DashboardController: UIViewController {

    // MARK: - Properties

    // TICKET: IOS-1511 - Do not store assetType in DashboardController
    var assetType: LegacyAssetType? {
        didSet {
            reload()
        }
    }

    // MARK: - Private Properties

    private let horizontalPadding: CGFloat = 15
    private let priceChartPadding: CGFloat = 20
    private let pricePreviewViewSpacing: CGFloat = 16
    private let wallet: Wallet
    private let tabControllerManager: TabControllerManager
    private let stellarAccountService: StellarAccountAPI
    private var lastBtcExchangeRate: FiatValue
    private var lastBchExchangeRate: FiatValue
    private var lastEthExchangeRate: FiatValue
    private var lastXlmExchangeRate: FiatValue
    private var defaultContentHeight: CGFloat = 0
    private var disposable: Disposable?
    private var priceChartContainerView: UIView?
    private var bitcoinPricePreviewView,
                etherPricePreviewView,
                bitcoinCashPricePreviewView,
                stellarPricePreviewView: PricePreviewView?

    // TICKET: IOS-1512 - Move formatters to a global formatter pool

    private lazy var numberFormatter: NumberFormatter = {
        NumberFormatter()
    }()

    private lazy var dateFormatter: DateFormatter = {
        DateFormatter()
    }()

    private lazy var chartContainerViewController: BCPriceChartContainerViewController = {
        let theViewController = BCPriceChartContainerViewController()
        theViewController.modalPresentationStyle = .overCurrentContext
        theViewController.delegate = self
        return theViewController
    }()

    // TICKET: IOS-1249 - Refactor CardsViewController

    private lazy var cardsViewController: CardsViewController = {
        let theViewController = CardsViewController()
        theViewController.dashboardContentView = self.contentView
        theViewController.dashboardScrollView = self.scrollView
        return theViewController
    }()

    private lazy var balancesChartView: BCBalancesChartView = {
        let balancesChartViewFrame = CGRect(
            x: horizontalPadding,
            y: 16,
            width: view.frame.size.width - (horizontalPadding * 2),
            height: 425
        )
        let balancesChartView = BCBalancesChartView(frame: balancesChartViewFrame)
        balancesChartView.delegate = self
        balancesChartView.layer.masksToBounds = false
        balancesChartView.layer.cornerRadius = 4
        balancesChartView.layer.shadowOffset = CGSize(width: 0, height: 2)
        balancesChartView.layer.shadowRadius = 4
        balancesChartView.layer.shadowOpacity = 0.1
        return balancesChartView
    }()

    private lazy var contentView: UIView = {
        let theView = UIView(frame: CGRect.zero)
        theView.backgroundColor = .clear
        theView.clipsToBounds = true
        return theView
    }()

    // MARK: - IBOutlets
    
    @IBOutlet private var scrollView: UIScrollView!

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        wallet = WalletManager.shared.wallet
        tabControllerManager = AppCoordinator.shared.tabControllerManager
        let currencyCode = BlockchainSettings.App.shared.fiatCurrencyCode
        lastBtcExchangeRate = FiatValue.create(amount: 0, currencyCode: currencyCode)
        lastBchExchangeRate = FiatValue.create(amount: 0, currencyCode: currencyCode)
        lastEthExchangeRate = FiatValue.create(amount: 0, currencyCode: currencyCode)
        lastXlmExchangeRate = FiatValue.create(amount: 0, currencyCode: currencyCode)
        stellarAccountService = XLMServiceProvider.shared.services.accounts
        super.init(coder: aDecoder)
    }

    deinit {
        disposable?.dispose()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resetScrollView),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        title = LocalizationConstants.ObjCStrings.BC_STRING_DASHBOARD
        
        view.backgroundColor = .lightGray
        contentView.addSubview(balancesChartView)

        setupPricePreviewViews()

        let balancesChartHeight = balancesChartView.frame.size.height
        let titleLabelHeight: CGFloat = 40 + 16
        let pricePreviewHeight: CGFloat = 4 * 150
        let pricePreviewSpacing: CGFloat = 4 * 16
        let bottomPadding: CGFloat = 16

        defaultContentHeight = balancesChartHeight + titleLabelHeight + pricePreviewHeight + pricePreviewSpacing + bottomPadding

        let contentViewFrame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: defaultContentHeight)
        contentView.frame = contentViewFrame

        scrollView.addSubview(contentView)
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: contentViewFrame.size.height)

        AnalyticsService.shared.trackEvent(title: "dashboard")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cardsViewController.reloadAllCards()
    }

    // TICKET: IOS-1507 - Refactor to use autolayout
    // TODO: use UIStackView
    // swiftlint:disable:next function_body_length
    private func setupPricePreviewViews() {
        let priceChartsLabelHeight: CGFloat = 40
        let pricePreviewViewHeight: CGFloat = 150

        let priceChartContainerViewFrame = CGRect(
            x: horizontalPadding,
            y: balancesChartView.frame.origin.y + balancesChartView.frame.size.height + pricePreviewViewSpacing,
            width: view.frame.size.width - (horizontalPadding * 2),
            height: priceChartsLabelHeight + (pricePreviewViewHeight * 4) + (pricePreviewViewSpacing * 3)
        )

        let priceChartsLabelFrame = CGRect(x: 8, y: 0, width: (view.frame.size.width / 2), height: priceChartsLabelHeight)

        let bitcoinPricePreviewViewFrame = CGRect(
            x: 0,
            y: priceChartsLabelFrame.origin.y + priceChartsLabelFrame.size.height,
            width: view.frame.size.width - (horizontalPadding * 2),
            height: pricePreviewViewHeight
        )

        let etherPricePreviewViewFrame = bitcoinPricePreviewViewFrame.offsetBy(
            dx: 0,
            dy: pricePreviewViewHeight + pricePreviewViewSpacing
        )

        let bitcoinCashPricePreviewViewFrame = etherPricePreviewViewFrame.offsetBy(
            dx: 0,
            dy: pricePreviewViewHeight + pricePreviewViewSpacing
        )

        let stellarPricePreviewViewFrame = bitcoinCashPricePreviewViewFrame.offsetBy(
            dx: 0,
            dy: pricePreviewViewHeight + pricePreviewViewSpacing
        )

        priceChartContainerView = UIView(frame: priceChartContainerViewFrame)

        let priceChartsLabel = UILabel(frame: priceChartsLabelFrame)
        priceChartsLabel.textColor = .brandPrimary
        priceChartsLabel.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Large)
        priceChartsLabel.text = LocalizationConstants.Dashboard.priceCharts

        bitcoinPricePreviewView = PricePreviewViewFactory.create(for: .bitcoin, buttonTapped: {
            self.showChartContainerViewController(for: .bitcoin)
        })

        etherPricePreviewView = PricePreviewViewFactory.create(for: .ethereum, buttonTapped: {
            self.showChartContainerViewController(for: .ethereum)
        })

        bitcoinCashPricePreviewView = PricePreviewViewFactory.create(for: .bitcoinCash, buttonTapped: {
            self.showChartContainerViewController(for: .bitcoinCash)
        })

        stellarPricePreviewView = PricePreviewViewFactory.create(for: .stellar, buttonTapped: {
            self.showChartContainerViewController(for: .stellar)
        })

        bitcoinPricePreviewView!.frame = bitcoinPricePreviewViewFrame
        etherPricePreviewView!.frame = etherPricePreviewViewFrame
        bitcoinCashPricePreviewView!.frame = bitcoinCashPricePreviewViewFrame
        stellarPricePreviewView!.frame = stellarPricePreviewViewFrame

        priceChartContainerView!.addSubview(priceChartsLabel)
        priceChartContainerView!.addSubview(bitcoinPricePreviewView!)
        priceChartContainerView!.addSubview(etherPricePreviewView!)
        priceChartContainerView!.addSubview(bitcoinCashPricePreviewView!)
        priceChartContainerView!.addSubview(stellarPricePreviewView!)
        contentView.addSubview(priceChartContainerView!)
    }

    private func showChartContainerViewController(for assetType: AssetType) {
        let pricePreviewChartPosition: Int
        let legacyAssetType: LegacyAssetType
        switch assetType {
        case .bitcoin:
            pricePreviewChartPosition = 0
            legacyAssetType = .bitcoin
        case .ethereum:
            pricePreviewChartPosition = 1
            legacyAssetType = .ether
        case .bitcoinCash:
            pricePreviewChartPosition = 2
            legacyAssetType = .bitcoinCash
        case .stellar:
            pricePreviewChartPosition = 3
            legacyAssetType = .stellar
        case .pax:
            // TODO: IOS-2053
            pricePreviewChartPosition = 4
            legacyAssetType = .pax
            fatalError("Not implemented yet")
        }

        let priceChartViewFrame = CGRect(
            x: priceChartPadding,
            y: priceChartPadding,
            width: self.view.frame.size.width - priceChartPadding,
            height: (self.view.frame.size.height * 0.75) - priceChartPadding
        )
        let priceChartView = BCPriceChartView(
            frame: priceChartViewFrame,
            assetType: legacyAssetType,
            dataPoints: nil,
            delegate: self
        )
        chartContainerViewController.add(priceChartView, at: pricePreviewChartPosition)
        fetchChartDataForAsset(type: assetType)

        if chartContainerViewController.presentingViewController == nil {
            tabControllerManager.present(chartContainerViewController, animated: true)
        }
    }

    // Objc backward compatible method to set asset type
    @objc func setAssetType(_ assetType: LegacyAssetType) {
        self.assetType = assetType
    }

    /**
        The functions to get the raw balances below need to be extracted from this class.
        They do not return the balances in fiat. To convert them to fiat, their value must
        be multiplied by the current exchange rate.
    */
    private func getBtcBalance() -> CryptoValue {
        return CryptoValue.bitcoinFromSatoshis(int: Int(wallet.getTotalActiveBalance()))
    }

    private func getEthBalance() -> CryptoValue {
        guard let ethBalance = wallet.getEthBalance() else {
            return CryptoValue.etherFromMajor(decimal: 0)
        }
        return CryptoValue.etherFromMajor(string: ethBalance) ?? CryptoValue.etherFromMajor(decimal: 0)
    }

    private func getBchBalance() -> CryptoValue {
        return CryptoValue.bitcoinCashFromSatoshis(int: Int(wallet.getBchBalance()))
    }

    private func getBtcWatchOnlyBalance() -> CryptoValue {
        return CryptoValue.bitcoinFromSatoshis(int: Int(wallet.getWatchOnlyBalance()))
    }


    private func reloadBalances(_ balances: [AssetType: CryptoValue]? = nil) {
        /// NOTE: This is here due to an issue moving `Swap` to the tab bar caused.
        /// If the view hadn't loaded subviews would be lazily instantiated prior to being
        /// added as subviews resulting in multiple instances of `balancesChartView` being
        /// created.
        guard isViewLoaded == true else { return }
        
        let btcBalance = balances?[.bitcoin] ?? CryptoValue.bitcoinFromMajor(int: 0)
        let btcFiatBalance = btcBalance.convertToFiatValue(exchangeRate: lastBtcExchangeRate)

        let ethBalance = balances?[.ethereum] ?? CryptoValue.etherFromMajor(decimal: 0)
        let ethFiatBalance = ethBalance.convertToFiatValue(exchangeRate: lastEthExchangeRate)

        let bchBalance = balances?[.bitcoinCash] ?? CryptoValue.bitcoinCashFromMajor(int: 0)
        let bchFiatBalance = bchBalance.convertToFiatValue(exchangeRate: lastBchExchangeRate)

        let xlmBalance = balances?[.stellar] ?? CryptoValue.lumensFromMajor(decimal: 0)
        let xlmFiatBalance = xlmBalance.convertToFiatValue(exchangeRate: lastXlmExchangeRate)

        let totalBalance: FiatValue
        do {
            totalBalance = try btcFiatBalance + ethFiatBalance + bchFiatBalance + xlmFiatBalance
        } catch {
            totalBalance = FiatValue.create(amount: 0, currencyCode: btcFiatBalance.currencyCode)
        }

        balancesChartView.updateFiatSymbol(BlockchainSettings.App.shared.fiatCurrencySymbol)

        balancesChartView.updateBitcoinBalance(btcBalance.toDisplayString(includeSymbol: false))
        balancesChartView.updateBitcoinFiatBalance(btcFiatBalance.amount.doubleValue)

        balancesChartView.updateEtherBalance(ethBalance.toDisplayString(includeSymbol: false))
        balancesChartView.updateEtherFiatBalance(ethFiatBalance.amount.doubleValue)

        balancesChartView.updateBitcoinCashBalance(bchBalance.toDisplayString(includeSymbol: false))
        balancesChartView.updateBitcoinCashFiatBalance(bchFiatBalance.amount.doubleValue)

        balancesChartView.updateStellarBalance(xlmBalance.toDisplayString(includeSymbol: false))
        balancesChartView.updateStellarFiatBalance(xlmFiatBalance.amount.doubleValue)

        balancesChartView.updateTotalFiatBalance(totalBalance.toDisplayString(includeSymbol: true))

        if wallet.isInitialized() {
            let watchOnlyBalance = wallet.getWatchOnlyBalance()
            let watchOnlyFiatBalance = getBtcWatchOnlyBalance().convertToFiatValue(exchangeRate: lastBtcExchangeRate)
            if watchOnlyFiatBalance.amount > 0 {
                balancesChartView.updateBitcoinWatchOnlyFiatBalance(watchOnlyFiatBalance.amount.doubleValue)
                balancesChartView.updateBitcoinWatchOnlyBalance(NumberFormatter.formatAmount(watchOnlyBalance, localCurrency: false))
                // Increase height and Y positions to show watch only view
                balancesChartView.showWatchOnlyView()
                let offset = balancesChartView.frame.origin.y + balancesChartView.frame.size.height + pricePreviewViewSpacing
                priceChartContainerView?.changeYPosition(offset)
                contentView.changeHeight(defaultContentHeight + balancesChartView.watchOnlyViewHeight())
            } else {
                // Show default heights and Y positions
                balancesChartView.hideWatchOnlyView()
                let offset = balancesChartView.frame.origin.y + balancesChartView.frame.size.height + pricePreviewViewSpacing
                priceChartContainerView?.changeYPosition(offset)
                contentView.changeHeight(defaultContentHeight)
            }
            cardsViewController.reloadAllCards()
        }

        balancesChartView.updateChart()
    }

    // TICKET: IOS-1506 - Encapsulate methods to get balances into separate component & decouple from DashboardController
    // swiftlint:disable:next function_body_length
    @objc func reload() {
        /// NOTE: This is here due to an issue moving `Swap` to the tab bar caused.
        /// If the view hadn't loaded subviews would be lazily instantiated prior to being
        /// added as subviews resulting in multiple instances of `balancesChartView` being
        /// created.
        /// More than likely this will go away once we move the dashboard to a `UICollectionView`.
        guard isViewLoaded == true else { return }
        if !wallet.isInitialized() {
            reloadBalances()
        }
        let fiatCurrencyCode = BlockchainSettings.App.shared.fiatCurrencyCode
        disposable = PriceServiceClient().allPrices(fiatSymbol: fiatCurrencyCode)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { priceMap in
                AssetType.all.forEach { type in
                    let price = priceMap[type]?.priceInFiat ?? FiatValue.create(amount: 0, currencyCode: fiatCurrencyCode)
                    let formattedPrice = price.toDisplayString(includeSymbol: true)
                    switch type {
                    case .bitcoin:
                        self.lastBtcExchangeRate = price
                        self.bitcoinPricePreviewView?.price = formattedPrice
                    case .ethereum:
                        self.lastEthExchangeRate = price
                        self.etherPricePreviewView?.price = formattedPrice
                    case .bitcoinCash:
                        self.lastBchExchangeRate = price
                        self.bitcoinCashPricePreviewView?.price = formattedPrice
                    case .stellar:
                        self.lastXlmExchangeRate = price
                        self.stellarPricePreviewView?.price = formattedPrice
                    case .pax:
                        // TODO: IOS-2053
                        fatalError("Not implemented yet")
                    }
                }
                let account = self.stellarAccountService.currentStellarAccount(fromCache: false)
                _ = account
                    .subscribeOn(MainScheduler.asyncInstance)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onSuccess: { account in
                        self.reloadBalances([
                            AssetType.bitcoin: self.getBtcBalance(),
                            AssetType.ethereum: self.getEthBalance(),
                            AssetType.bitcoinCash: self.getBchBalance(),
                            AssetType.stellar: CryptoValue.lumensFromMajor(decimal: account.assetAccount.balance)
                        ])
                    }, onError: { _ in
                        self.reloadBalances([
                            AssetType.bitcoin: self.getBtcBalance(),
                            AssetType.ethereum: self.getEthBalance(),
                            AssetType.bitcoinCash: self.getBchBalance(),
                            AssetType.stellar: CryptoValue.lumensFromMajor(int: 0)
                        ])
                    })
            }, onError: { error in
                Logger.shared.error(error.localizedDescription)
            })

        cardsViewController.reloadAllCards()
    }

    @objc func reloadSymbols() {
        balancesChartView.updateWatchOnlyViewBalance()
    }

    // swiftlint:disable:next function_body_length
    private func fetchChartDataForAsset(type: AssetType) {
        let timeFrame: GraphTimeFrame
        let graphTimeFrameKey = UserDefaults.Keys.graphTimeFrameKey.rawValue
        if let data = UserDefaults.standard.object(forKey: graphTimeFrameKey) as? Data,
            let theUnarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: data) as? GraphTimeFrame {
            timeFrame = theUnarchiveObject
        } else {
            timeFrame = GraphTimeFrame.timeFrameWeek()
        }

        let startDate, entryDate: Int
        let base: String

        switch type {
        case .bitcoin:
            base = AssetType.bitcoin.symbol.lowercased()
            entryDate = timeFrame.startDateBitcoin()
        case .bitcoinCash:
            base = AssetType.bitcoinCash.symbol.lowercased()
            entryDate = timeFrame.startDateBitcoinCash()
        case .ethereum:
            base = AssetType.ethereum.symbol.lowercased()
            entryDate = timeFrame.startDateEther()
        case .stellar:
            base = AssetType.stellar.symbol.lowercased()
            entryDate = timeFrame.startDateStellar()
        case .pax:
            // TODO: IOS-2053
            base = AssetType.pax.symbol.lowercased()
            entryDate = 0 // TODO
            fatalError("Not implemented yet")
        }

        startDate = timeFrame.timeFrame == TimeFrameAll || timeFrame.startDate < entryDate ? entryDate : timeFrame.startDate

        guard let quote = NumberFormatter.localCurrencyCode() else {
            showError(message: LocalizationConstants.Dashboard.chartsError)
            return
        }

        let url = URL(string: BlockchainAPI.shared.chartsURL(for: base, quote: quote, startDate: startDate, scale: timeFrame.scale))!
        let task = NetworkManager.shared.session.dataTask(with: url, completionHandler: { data, response, error in
            if let theError = error {
                self.showError(message: theError.localizedDescription)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode),
                let mimeType = httpResponse.mimeType,
                mimeType == HttpHeaderValue.json,
                let theData = data,
                let json = try? JSONSerialization.jsonObject(with: theData, options: .allowFragments),
                let values = json as? [Any] else {
                    self.showError(message: LocalizationConstants.Dashboard.chartsError)
                    return
            }
            DispatchQueue.main.async {
                if values.isEmpty {
                    self.chartContainerViewController.clearChart()
                    self.showError(message: LocalizationConstants.Dashboard.chartsError)
                } else {
                    self.chartContainerViewController.updateChart(withValues: values)
                }
            }
        })
        task.resume()
    }

    // MARK: - Charts

    @objc private func resetScrollView() {
        scrollView.setContentOffset(CGPoint.zero, animated: false)
    }

    // MARK: - View Helpers

    private func showError(message: String) {
        guard BlockchainSettings.App.shared.isPinSet,
            AuthenticationCoordinator.shared.pinEntryViewController == nil,
            wallet.isInitialized(),
            tabControllerManager.tabViewController.selectedIndex() == Int32(Constants.Navigation.tabDashboard),
            ModalPresenter.shared.modalView == nil else {
                return
        }
        // NOTE: May have to be presented in `self.view.window.rootViewController` instead of `self`
        AlertViewPresenter.shared.standardError(message: message, title: LocalizationConstants.Errors.error, in: self)
    }

    // MARK: - Text Helpers

    private func dateStringFromGraphValue(value: Double) -> String {
        let key = UserDefaults.Keys.graphTimeFrameKey.rawValue
        if let data = UserDefaults.standard.object(forKey: key) as? Data,
            let timeFrame = NSKeyedUnarchiver.unarchiveObject(with: data) as? GraphTimeFrame,
            let dateFormat = timeFrame.dateFormat {
            dateFormatter.dateFormat = dateFormat
        } else {
            dateFormatter.dateFormat = GraphTimeFrame.timeFrameDay().dateFormat
        }
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

// MARK: - BCBalancesChartView Delegate

// TICKET: IOS-1510 - Decouple showTransactions* methods from tabControllerManager
extension DashboardController: BCBalancesChartViewDelegate {
    func bitcoinLegendTapped() {
        tabControllerManager.showTransactionsBitcoin()
    }

    func etherLegendTapped() {
        tabControllerManager.showTransactionsEther()
    }

    func bitcoinCashLegendTapped() {
        tabControllerManager.showTransactionsBitcoinCash()
    }

    func stellarLegendTapped() {
        tabControllerManager.showTransactionsStellar()
    }

    func watchOnlyViewTapped() {
        BlockchainSettings.sharedAppInstance().symbolLocal = !BlockchainSettings.sharedAppInstance().symbolLocal
    }
}

// MARK: - BCPriceChartView Delegate

extension DashboardController: BCPriceChartViewDelegate {
    func addPriceChartView(_ assetType: LegacyAssetType) {
        showChartContainerViewController(for: AssetType.from(legacyAssetType: assetType))
    }

    func reloadPriceChartView(_ assetType: LegacyAssetType) {
        fetchChartDataForAsset(type: AssetType.from(legacyAssetType: assetType))
    }
}

// MARK: - IAxisValueFormatter

extension DashboardController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        switch axis {
        case chartContainerViewController.leftAxis():
            guard let formatted = NumberFormatter.localCurrencyFormatter.string(from: NSNumber(value: value)) else {
                return String(format: "%.2f").appendCurrencySymbol()
            }
            return formatted.appendCurrencySymbol()
        case chartContainerViewController.xAxis():
            return dateStringFromGraphValue(value: value)
        default:
            Logger.shared.warning("Warning: no axis found!")
            return String()
        }
    }
}

extension DashboardController: NavigatableView {
    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        AppCoordinator.shared.tabControllerManager.qrCodeButtonClicked()
    }
    
    func navControllerLeftBarButtonTapped(_ navController: UINavigationController) {
        AppCoordinator.shared.toggleSideMenu()
    }
}
