//
//  DashboardController.swift
//  Blockchain
//
//  Created by Maurice A. on 9/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import Charts

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
    private let previewViewSpacing: CGFloat = 16
    private var defaultContentHeight: CGFloat = 0
    private var priceChartContainerView: UIView
    private var bitcoinPricePreview, etherPricePreview, bitcoinCashPricePreview: BCPricePreviewView?
    private var lastEthExchangeRate: NSDecimalNumber
    private let wallet: Wallet, tabControllerManager: TabControllerManager

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

    private lazy var balancesLabelFrame = {
        CGRect(
            x: horizontalPadding,
            y: 16,
            width: (view.frame.size.width / 2),
            height: 40
        )
    }()

    private lazy var balancesChartView: BCBalancesChartView = {
        let balancesChartViewFrame = CGRect(
            x: horizontalPadding,
            y: balancesLabelFrame.origin.y + balancesLabelFrame.size.height,
            width: view.frame.size.width - (horizontalPadding * 2),
            height: 320
        )
        let balancesChartView = BCBalancesChartView(frame: balancesChartViewFrame)
        balancesChartView.delegate = self
        balancesChartView.layer.masksToBounds = false
        balancesChartView.layer.cornerRadius = 2
        balancesChartView.layer.shadowOffset = CGSize(width: 0, height: 2)
        balancesChartView.layer.shadowRadius = 3
        balancesChartView.layer.shadowOpacity = 0.25
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
        priceChartContainerView = UIView(frame: CGRect.zero)
        lastEthExchangeRate = NSDecimalNumber(value: 0)
        super.init(coder: aDecoder)
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resetScrollView),
            name: .UIApplicationDidEnterBackground,
            object: nil
        )

        view.backgroundColor = .lightGray

        setupPieChart()

        setupPriceCharts()

        let balancesChartHeight = balancesChartView.frame.size.height
        let titleLabelHeight: CGFloat = 2 * (40 + 16)
        let pricePreviewHeight: CGFloat = 3 * 140
        let pricePreviewSpacing: CGFloat = 3 * 16
        let bottomPadding: CGFloat = 8

        defaultContentHeight = balancesChartHeight + titleLabelHeight + pricePreviewHeight + pricePreviewSpacing + bottomPadding

        let contentViewFrame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: defaultContentHeight)
        contentView.frame = contentViewFrame

        scrollView.addSubview(contentView)
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: contentViewFrame.size.height)

        cardsViewController.reloadCards()
    }

    // Objc backward compatible method to set asset type
    @objc func setAssetType(_ assetType: LegacyAssetType) {
        self.assetType = assetType
    }

    // TICKET: IOS-1506 - Encapsulate methods to get balances into separate component & decouple from DashboardController
    // swiftlint:disable:next function_body_length
    @objc func reload() {
        guard wallet.isInitialized() else {
            Logger.shared.warning("Returning nil because wallet was not initialized!")
            return
        }
        let btcFiatBalance = getBtcBalance()
        let ethFiatBalance = getEthBalance()
        let bchFiatBalance = getBchBalance()
        let watchOnlyFiatBalance = getBtcWatchOnlyBalance()
        guard let latestMultiAddressResponse = WalletManager.shared.latestMultiAddressResponse,
            let symbolLocal = latestMultiAddressResponse.symbol_local,
            let symbol = symbolLocal.symbol else {
                Logger.shared.warning("Failed to get symbol from latestMultiAddressResponse!")
                return
        }

        let truncatedEthBalance = wallet.getEthBalanceTruncated()

        let bchBalance = wallet.getBchBalance()

        let totalActiveBalance = wallet.getTotalActiveBalance()

        let totalFiatBalance = btcFiatBalance + ethFiatBalance + bchFiatBalance

        let walletIsInitialized = wallet.isInitialized()

        if walletIsInitialized {
            balancesChartView.updateFiatSymbol(symbol)
            // Fiat balances
            balancesChartView.updateBitcoinFiatBalance(btcFiatBalance)
            balancesChartView.updateEtherFiatBalance(ethFiatBalance)
            balancesChartView.updateBitcoinCashFiatBalance(bchFiatBalance)
            balancesChartView.updateTotalFiatBalance(
                NumberFormatter.appendString(toFiatSymbol: NumberFormatter.fiatString(from: totalFiatBalance))
            )
            // Balances
            balancesChartView.updateBitcoinBalance(NumberFormatter.formatAmount(totalActiveBalance, localCurrency: false))
            balancesChartView.updateEtherBalance(truncatedEthBalance)
            balancesChartView.updateBitcoinCashBalance(NumberFormatter.formatAmount(bchBalance, localCurrency: false))
            // Watch-only balances
            let watchOnlyBalance = wallet.getWatchOnlyBalance()
            if watchOnlyBalance > 0 {
                balancesChartView.updateBitcoinWatchOnlyFiatBalance(watchOnlyFiatBalance)
                balancesChartView.updateBitcoinWatchOnlyBalance(NumberFormatter.formatAmount(watchOnlyBalance, localCurrency: false))
                // Increase height and Y positions to show watch only view
                balancesChartView.showWatchOnlyView()
                let offset = balancesChartView.frame.origin.y + balancesChartView.frame.size.height + previewViewSpacing
                priceChartContainerView.changeYPosition(offset)
                contentView.changeHeight(defaultContentHeight + balancesChartView.watchOnlyViewHeight())
            } else {
                // Show default heights and Y positions
                balancesChartView.hideWatchOnlyView()
                let offset = balancesChartView.frame.origin.y + balancesChartView.frame.size.height + previewViewSpacing
                priceChartContainerView.changeYPosition(offset)
                contentView.changeHeight(defaultContentHeight)
            }
        }

        balancesChartView.updateChart()

        if !walletIsInitialized {
            balancesChartView.clearLegendKeyBalances()
        }

        reloadPricePreviews()

        cardsViewController.reloadCards()
    }

    @objc func reloadSymbols() {
        balancesChartView.updateWatchOnlyViewBalance()
    }

    // swiftlint:disable:next function_body_length
    private func fetchChartDataForAsset(type: LegacyAssetType) {
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
        case .ether:
            base = AssetType.ethereum.symbol.lowercased()
            entryDate = timeFrame.startDateEther()
        case .stellar:
            // TODO: implement chart data for stellar
            base = AssetType.stellar.symbol.lowercased()
            entryDate = 0
            return
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
            guard
                let httpResponse = response as? HTTPURLResponse,
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

    @objc func updateEthExchangeRate(_ rate: NSDecimalNumber) {
        lastEthExchangeRate = rate
        reloadPricePreviews()
    }

    private func showChartContainerViewController() {
        if chartContainerViewController.presentingViewController == nil {
            tabControllerManager.present(chartContainerViewController, animated: true)
        }
    }

    @objc private func bitcoinChartTapped() {
        showChartContainerViewController()

        let priceChartViewFrame = CGRect(
            x: priceChartPadding,
            y: priceChartPadding,
            width: self.view.frame.size.width - priceChartPadding,
            height: (self.view.frame.size.height * (3 / 4)) - priceChartPadding
        )
        let priceChartView = BCPriceChartView(frame: priceChartViewFrame, assetType: .bitcoin, dataPoints: nil, delegate: self)
        chartContainerViewController.add(priceChartView, at: 0)
        fetchChartDataForAsset(type: .bitcoin)
    }

    @objc private func etherChartTapped() {
        showChartContainerViewController()

        let priceChartViewFrame = CGRect(
            x: priceChartPadding,
            y: priceChartPadding,
            width: self.view.frame.size.width - priceChartPadding,
            height: (self.view.frame.size.height * (3 / 4)) - priceChartPadding
        )
        let priceChartView = BCPriceChartView(frame: priceChartViewFrame, assetType: .ether, dataPoints: nil, delegate: self)
        chartContainerViewController.add(priceChartView, at: 1)
        chartContainerViewController.updateEthExchangeRate(lastEthExchangeRate)
        fetchChartDataForAsset(type: .ether)
    }

    @objc private func bitcoinCashChartTapped() {
        showChartContainerViewController()

        let priceChartViewFrame = CGRect(
            x: priceChartPadding,
            y: priceChartPadding,
            width: self.view.frame.size.width - priceChartPadding,
            height: (self.view.frame.size.height * (3 / 4)) - priceChartPadding
        )
        let priceChartView = BCPriceChartView(frame: priceChartViewFrame, assetType: .bitcoinCash, dataPoints: nil, delegate: self)
        chartContainerViewController.add(priceChartView, at: 2)
        fetchChartDataForAsset(type: .bitcoinCash)
    }

    // MARK: - Charts

    // TICKET: IOS-1507 - Refactor to use autolayout
    private func setupPieChart() {
        let balancesLabel = UILabel(frame: balancesLabelFrame)
        balancesLabel.textColor = .brandPrimary
        balancesLabel.font = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.Large)
        balancesLabel.text = LocalizationConstants.balances.uppercased()
        contentView.addSubview(balancesLabel)
        contentView.addSubview(balancesChartView)
    }

    // swiftlint:disable:next function_body_length
    private func setupPriceCharts() {
        let labelHeight: CGFloat = 40, previewViewHeight: CGFloat = 140
        let priceChartContainerViewFrame = CGRect(
            x: horizontalPadding,
            y: balancesChartView.frame.origin.y + balancesChartView.frame.size.height + previewViewSpacing,
            width: view.frame.size.width - (horizontalPadding * 2),
            height: labelHeight + (previewViewHeight * 3) + (previewViewSpacing * 2)
        )
        let priceChartContainerView = UIView(frame: priceChartContainerViewFrame)
        contentView.addSubview(priceChartContainerView)

        let balancesLabelFrame = CGRect(x: 0, y: 0, width: (view.frame.size.width / 2), height: labelHeight)
        let balancesLabel = UILabel(frame: balancesLabelFrame)
        balancesLabel.textColor = .brandPrimary
        balancesLabel.font = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.Large)
        balancesLabel.text = LocalizationConstants.Dashboard.priceCharts.uppercased()
        priceChartContainerView.addSubview(balancesLabel)

        let bitcoinPreviewViewFrame = CGRect(
            x: 0,
            y: balancesLabel.frame.origin.y + balancesLabel.frame.size.height,
            width: (view.frame.size.width - (horizontalPadding * 2)),
            height: previewViewHeight
        )
        // TICKET: IOS-1508 - Encapsulate getBtcPrice, getEthPrice and getBchPrice into separate component & decouple from DashboardController.
        let bitcoinPreviewView = BCPricePreviewView(
            frame: bitcoinPreviewViewFrame,
            assetName: AssetType.bitcoin.description,
            price: "0",
            assetImage: "bitcoin_white"
        )!
        priceChartContainerView.addSubview(bitcoinPreviewView)
        bitcoinPricePreview = bitcoinPreviewView

        let bitcoinChartTapGesture = UITapGestureRecognizer(target: self, action: #selector(bitcoinChartTapped))
        bitcoinPreviewView.addGestureRecognizer(bitcoinChartTapGesture)

        let etherPreviewViewFrame = CGRect(
            x: 0,
            y: bitcoinPreviewView.frame.origin.y + bitcoinPreviewView.frame.size.height + previewViewSpacing,
            width: (view.frame.size.width - (horizontalPadding * 2)),
            height: previewViewHeight
        )
        let etherPreviewView = BCPricePreviewView(
            frame: etherPreviewViewFrame,
            assetName: AssetType.ethereum.description,
            price: "0",
            assetImage: "ether_white"
        )!
        priceChartContainerView.addSubview(etherPreviewView)
        etherPricePreview = etherPreviewView

        let etherChartTapGesture = UITapGestureRecognizer(target: self, action: #selector(etherChartTapped))
        etherPreviewView.addGestureRecognizer(etherChartTapGesture)

        let bitcoinCashPreviewViewFrame = CGRect(
            x: 0,
            y: etherPreviewView.frame.origin.y + etherPreviewView.frame.size.height + previewViewSpacing,
            width: (view.frame.size.width - (horizontalPadding * 2)),
            height: previewViewHeight
        )
        let bitcoinCashPreviewView = BCPricePreviewView(
            frame: bitcoinCashPreviewViewFrame,
            assetName: AssetType.bitcoinCash.description,
            price: "0",
            assetImage: "bitcoin_cash_white"
        )!
        priceChartContainerView.addSubview(bitcoinCashPreviewView)
        bitcoinCashPricePreview = bitcoinCashPreviewView

        let bitcoinCashChartTapGesture = UITapGestureRecognizer(target: self, action: #selector(bitcoinCashChartTapped))
        bitcoinCashPreviewView.addGestureRecognizer(bitcoinCashChartTapGesture)

        self.priceChartContainerView = priceChartContainerView
    }

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

    private func dateStringFromGraphValue(value: Double) -> String? {
        guard let dateFormat = getDateFormat() else {
            Logger.shared.warning("Failed to get date format!")
            return nil
        }
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }

    private func getDateFormat() -> String? {
        let key = UserDefaults.Keys.graphTimeFrameKey.rawValue
        guard let data = UserDefaults.standard.object(forKey: key) as? Data,
            let timeFrame = NSKeyedUnarchiver.unarchiveObject(with: data) as? GraphTimeFrame else {
                Logger.shared.warning("Failed to unarchive the data object with key \(key)")
                return nil
        }
        guard let dateFormat = timeFrame.dateFormat else {
            Logger.shared.warning("Failed to get date format from GraphTimeFrame!")
            return nil
        }
        return dateFormat
    }

    // TICKET: IOS-1508 - Encapsulate methods to get prices into separate component & decouple from DashboardController
    // TICKET: IOS-1509 - Refactor NSNumberFormatter+Currencies to avoid returning nil on empty balances
    private func getBtcPrice() -> String? {
        guard wallet.isInitialized() else {
            Logger.shared.warning("Returning nil because wallet was not initialized!")
            return nil
        }
        return NumberFormatter.formatMoney(Constants.Conversions.satoshi, localCurrency: true)
    }

    private func getBchPrice() -> String? {
        guard wallet.isInitialized() else {
            Logger.shared.warning("Returning nil because wallet was not initialized!")
            return nil
        }
        return NumberFormatter.formatBch(withSymbol: Constants.Conversions.satoshi, localCurrency: true)
    }

    private func getEthPrice() -> String? {
        guard wallet.isInitialized() else {
            Logger.shared.warning("Returning nil because wallet was not initialized!")
            return nil
        }
        guard lastEthExchangeRate != 0 else {
            Logger.shared.error("Returning nil because lastEthExchangeRate was not set!")
            return nil
        }
        return NumberFormatter.formatEthToFiat(withSymbol: "1", exchangeRate: lastEthExchangeRate)
    }

    private func getBtcBalance() -> Double {
        let balance = wallet.getTotalActiveBalance()
        let amount = NumberFormatter.formatAmount(balance, localCurrency: true) ?? "0"
        return numberFormatter.number(from: amount)?.doubleValue ?? 0
    }

    private func getEthBalance() -> Double {
        guard let balance = wallet.getEthBalance() else {
            Logger.shared.warning("Failed to get ETH balance!")
            return 0
        }
        let amount = NumberFormatter.formatEth(
            toFiat: balance,
            exchangeRate: wallet.latestEthExchangeRate,
            localCurrencyFormatter: NumberFormatter.localCurrencyFormatter
        ) ?? "0"
        return numberFormatter.number(from: amount)?.doubleValue ?? 0
    }

    private func getBchBalance() -> Double {
        let balance = wallet.getBchBalance()
        let amount = NumberFormatter.formatBch(balance, localCurrency: true) ?? "0"
        return numberFormatter.number(from: amount)?.doubleValue ?? 0
    }

    private func getBtcWatchOnlyBalance() -> Double {
        let balance = wallet.getWatchOnlyBalance()
        let amount = NumberFormatter.formatAmount(balance, localCurrency: true) ?? "0"
        return numberFormatter.number(from: amount)?.doubleValue ?? 0
    }

    private func reloadPricePreviews() {
        bitcoinPricePreview?.updatePrice(getBtcPrice())
        etherPricePreview?.updatePrice(getEthPrice())
        bitcoinCashPricePreview?.updatePrice(getBchPrice())
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

    func watchOnlyViewTapped() {
        BlockchainSettings.sharedAppInstance().symbolLocal = !BlockchainSettings.sharedAppInstance().symbolLocal
    }
}

// MARK: - BCPriceChartView Delegate

extension DashboardController: BCPriceChartViewDelegate {
    func addPriceChartView(_ assetType: LegacyAssetType) {
        switch assetType {
        case .bitcoin:
            bitcoinChartTapped()
        case .ether:
            etherChartTapped()
        case .bitcoinCash:
            bitcoinCashChartTapped()
        case .stellar:
            // TODO: implement stellarChartTapped()
            return
        }
    }

    func reloadPriceChartView(_ assetType: LegacyAssetType) {
        fetchChartDataForAsset(type: assetType)
    }
}

// MARK: - IAxisValueFormatter

extension DashboardController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        switch axis {
        case chartContainerViewController.leftAxis():
            guard let latestMultiAddressResponse = WalletManager.shared.latestMultiAddressResponse,
                let symbolLocal = latestMultiAddressResponse.symbol_local,
                let symbol = symbolLocal.symbol else {
                    Logger.shared.warning("Failed to get symbol from latestMultiAddressResponse!")
                    return String()
            }
            return String(format: "%@%.f", symbol)
        case chartContainerViewController.xAxis():
            return dateStringFromGraphValue(value: value) ?? String()
        default:
            Logger.shared.warning("Warning: no axis found!")
            return String()
        }
    }
}

// TICKET: IOS-1249 - Refactor CardsViewController

// MARK: - AnnouncementCard Delegate

//extension DashboardController: AnnouncementCardDelegate {
//    func makeAnnouncement(📢 card: AnnouncementCard) {
//
//    }
//}
