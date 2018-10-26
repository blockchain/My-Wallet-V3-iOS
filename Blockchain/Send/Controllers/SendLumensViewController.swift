//
//  SendLumensViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol SendXLMViewControllerDelegate: class {
    func onLoad()
    func onAppear()
    func onXLMEntry(_ value: String, latestPrice: Decimal)
    func onFiatEntry(_ value: String, latestPrice: Decimal)
    func onPrimaryTapped(toAddress: String, amount: Decimal, feeInXlm: Decimal)
    func onConfirmPayTapped(_ paymentOperation: StellarPaymentOperation)
    func onUseMaxTapped()
}

@objc class SendLumensViewController: UIViewController, BottomButtonContainerView {
    
    // MARK: BottomButtonContainerView
    
    var originalBottomButtonConstraint: CGFloat!
    @IBOutlet var layoutConstraintBottomButton: NSLayoutConstraint!
    
    // MARK: Private IBOutlets (UILabel)
    
    @IBOutlet fileprivate var fromLabel: UILabel!
    @IBOutlet fileprivate var toLabel: UILabel!
    @IBOutlet fileprivate var walletNameLabel: UILabel!
    @IBOutlet fileprivate var feeLabel: UILabel!
    @IBOutlet fileprivate var feeAmountLabel: UILabel!
    @IBOutlet fileprivate var errorLabel: UILabel!
    @IBOutlet fileprivate var stellarSymbolLabel: UILabel!
    @IBOutlet fileprivate var fiatSymbolLabel: UILabel!
    
    // MARK: Private IBOutlets (UITextField)
    
    @IBOutlet fileprivate var stellarAddressField: UITextField!
    @IBOutlet fileprivate var stellarAmountField: UITextField!
    @IBOutlet fileprivate var fiatAmountField: UITextField!
    
    // MARK: Private IBOutlets (Other)
    
    @IBOutlet fileprivate var useMaxLabel: ActionableLabel!
    @IBOutlet fileprivate var primaryButtonContainer: PrimaryButtonContainer!
    @IBOutlet fileprivate var learnAbountStellarButton: UIButton!
    
    weak var delegate: SendXLMViewControllerDelegate?
    fileprivate var coordinator: SendXLMCoordinator!
    fileprivate var trigger: ActionableTrigger?

    // MARK: - Models
    private var pendingPaymentOperation: StellarPaymentOperation?
    private var latestPrice: Decimal? // fiat per whole unit
    private var xlmAmount: Decimal?
    private var xlmFee: Decimal?

    // MARK: Factory
    
    @objc class func make() -> SendLumensViewController {
        let controller = SendLumensViewController.makeFromStoryboard()
        return controller
    }
    
    // MARK: ViewUpdate
    
    enum PresentationUpdate {
        case activityIndicatorVisibility(Visibility)
        case errorLabelVisibility(Visibility)
        case learnAboutStellarButtonVisibility(Visibility)
        case actionableLabelVisibility(Visibility)
        case errorLabelText(String)
        case feeAmountLabelText()
        case stellarAddressText(String)
        case xlmFieldTextColor(UIColor)
        case fiatFieldTextColor(UIColor)
        case actionableLabelTrigger(ActionableTrigger)
        case primaryButtonEnabled(Bool)
        case showPaymentConfirmation(StellarPaymentOperation)
        case hidePaymentConfirmation
        case paymentSuccess
        case stellarAmountText(String)
        case fiatAmountText(String)
    }

    // MARK: Public Methods

    @objc func scanQrCodeForDestinationAddress() {
        let qrCodeScanner = QRCodeScannerSendViewController()
        qrCodeScanner.qrCodebuttonClicked(nil)
        qrCodeScanner.delegate = self
        present(qrCodeScanner, animated: false)
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let services = XLMServices(configuration: .test)
        let provider = XLMServiceProvider(services: services)
        coordinator = SendXLMCoordinator(serviceProvider: provider, interface: self, modelInterface: self)
        view.frame = UIView.rootViewSafeAreaFrame(
            navigationBar: true,
            tabBar: true,
            assetSelector: true
        )
        originalBottomButtonConstraint = layoutConstraintBottomButton.constant
        setUpBottomButtonContainerView()
        useMaxLabel.delegate = self
        primaryButtonContainer.isEnabled = true
        primaryButtonContainer.actionBlock = { [unowned self] in
            guard let toAddress = self.stellarAddressField.text else { return }
            guard let amount = self.xlmAmount else { return }
            guard let fee = self.xlmFee else { return }
            self.delegate?.onPrimaryTapped(toAddress: toAddress, amount: amount, feeInXlm: fee)
        }
        delegate?.onLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.onAppear()
    }
    
    fileprivate func useMaxAttributes() -> [NSAttributedStringKey: Any] {
        let fontName = Constants.FontNames.montserratRegular
        let font = UIFont(name: fontName, size: 13.0) ?? UIFont.systemFont(ofSize: 13.0)
        return [.font: font,
                .foregroundColor: UIColor.darkGray]
    }
    
    fileprivate func useMaxActionAttributes() -> [NSAttributedStringKey: Any] {
        let fontName = Constants.FontNames.montserratRegular
        let font = UIFont(name: fontName, size: 13.0) ?? UIFont.systemFont(ofSize: 13.0)
        return [.font: font,
                .foregroundColor: UIColor.brandSecondary]
    }

    // swiftlint:disable function_body_length
    fileprivate func apply(_ update: PresentationUpdate) {
        switch update {
        case .activityIndicatorVisibility(let visibility):
            primaryButtonContainer.isLoading = (visibility == .visible)
        case .errorLabelVisibility(let visibility):
            errorLabel.isHidden = visibility.isHidden
        case .learnAboutStellarButtonVisibility(let visibility):
            learnAbountStellarButton.isHidden = visibility.isHidden
        case .actionableLabelVisibility(let visibility):
            useMaxLabel.isHidden = visibility.isHidden
        case .errorLabelText(let value):
            errorLabel.text = value
        case .feeAmountLabelText:
            // TODO: move formatting outside of this file
            guard let price = latestPrice, let fee = xlmFee else { return }
            let assetType: AssetType = .stellar
            let xlmSymbol = assetType.symbol
            let feeFormatted = NumberFormatter.stellarFormatter.string(from: NSDecimalNumber(decimal: fee)) ?? "\(fee)"
            guard let fiatCurrencySymbol = BlockchainSettings.sharedAppInstance().fiatCurrencySymbol else {
                feeAmountLabel.text = feeFormatted + " " + xlmSymbol
                return
            }
            let fiatAmount = price * fee
            let fiatFormatted = NumberFormatter.localCurrencyFormatter.string(from: NSDecimalNumber(decimal: fiatAmount)) ?? "\(fiatAmount)"
            let fiatText = fiatCurrencySymbol + fiatFormatted
            feeAmountLabel.text = feeFormatted + " " + "(\(fiatText))"
        case .stellarAddressText(let value):
            stellarAddressField.text = value
        case .xlmFieldTextColor(let color):
            stellarAmountField.textColor = color
        case .fiatFieldTextColor(let color):
            fiatAmountField.textColor = color
        case .actionableLabelTrigger(let trigger):
            self.trigger = trigger
            let primary = NSMutableAttributedString(
                string: trigger.primaryString,
                attributes: useMaxAttributes()
            )
            
            let CTA = NSAttributedString(
                string: " " + trigger.callToAction,
                attributes: useMaxActionAttributes()
            )
            
            primary.append(CTA)
            
            if let secondary = trigger.secondaryString {
                let trailing = NSMutableAttributedString(
                    string: " " + secondary,
                    attributes: useMaxAttributes()
                )
                primary.append(trailing)
            }
            
            useMaxLabel.attributedText = primary
        case .primaryButtonEnabled(let enabled):
            primaryButtonContainer.isEnabled = enabled
        case .paymentSuccess:
            showPaymentSuccess()
        case .showPaymentConfirmation(let paymentOperation):
            showPaymentConfirmation(paymentOperation: paymentOperation)
        case .hidePaymentConfirmation:
            ModalPresenter.shared.closeAllModals()
        case .stellarAmountText(let text):
            stellarAmountField.text = text
        case .fiatAmountText(let text):
            fiatAmountField.text = text
        }

    }

    private func showPaymentSuccess() {
        AlertViewPresenter.shared.standardNotify(
            message: LocalizationConstants.SendAsset.paymentSent,
            title: LocalizationConstants.success
        )
    }

    private func showPaymentConfirmation(paymentOperation: StellarPaymentOperation) {
        self.pendingPaymentOperation = paymentOperation
        let viewModel = BCConfirmPaymentViewModel.initialize(with: paymentOperation, price: latestPrice)
        let confirmView = BCConfirmPaymentView(
            frame: view.frame,
            viewModel: viewModel,
            sendButtonFrame: primaryButtonContainer.frame
        )!
        confirmView.confirmDelegate = self
        ModalPresenter.shared.showModal(
            withContent: confirmView,
            closeType: ModalCloseTypeBack,
            showHeader: true,
            headerText: LocalizationConstants.SendAsset.confirmPayment
        )
    }
}

extension SendLumensViewController: SendXLMInterface {
    func apply(updates: [PresentationUpdate]) {
        updates.forEach({ apply($0) })
    }
}

extension SendLumensViewController: ConfirmPaymentViewDelegate {
    func confirmButtonDidTap(_ note: String?) {
        guard let paymentOperation = pendingPaymentOperation else {
            Logger.shared.warning("No pending payment operation")
            return
        }
        delegate?.onConfirmPayTapped(paymentOperation)
    }

    func feeInformationButtonClicked() {
        // TODO
    }
}

extension SendLumensViewController: ActionableLabelDelegate {
    func targetRange(_ label: ActionableLabel) -> NSRange? {
        return trigger?.actionRange()
    }
    
    func actionRequestingExecution(label: ActionableLabel) {
        guard let trigger = trigger else { return }
        trigger.execute()
    }
}

extension SendLumensViewController: QRCodeScannerViewControllerDelegate {
    func qrCodeScannerViewController(_ qrCodeScannerViewController: QRCodeScannerSendViewController, didScanString scannedString: String?) {
        qrCodeScannerViewController.dismiss(animated: false)
        guard let scanned = scannedString else { return }
        guard let payload = AssetURLPayloadFactory.create(fromString: scanned, assetType: .stellar) else {
            Logger.shared.error("Could not create payload from scanned string: \(scanned)")
            return
        }
        stellarAddressField.text = payload.address
        stellarAmountField.text = payload.amount
    }
}

extension BCConfirmPaymentViewModel {
    static func initialize(
        with paymentOperation: StellarPaymentOperation,
        price: Decimal?
    ) -> BCConfirmPaymentViewModel {
        // TODO: Refactor, move formatting out
        let assetType: AssetType = .stellar
        let xlmSymbol = assetType.symbol
        let fiatCurrencySymbol = BlockchainSettings.sharedAppInstance().fiatCurrencySymbol ?? ""

        let amountXlmDecimalNumber = NSDecimalNumber(decimal: paymentOperation.amountInXlm)
        let amountXlmString = NumberFormatter.stellarFormatter.string(from: amountXlmDecimalNumber) ?? "\(paymentOperation.amountInXlm)"
        let amountXlmStringWithSymbol = amountXlmString + " " + xlmSymbol

        let feeXlmDecimalNumber = NSDecimalNumber(decimal: paymentOperation.feeInXlm)
        let feeXlmString = NumberFormatter.stellarFormatter.string(from: feeXlmDecimalNumber) ?? "\(paymentOperation.feeInXlm)"
        let feeXlmStringWithSymbol = feeXlmString + " " + xlmSymbol

        let fiatTotalAmountText: String
        let cryptoWithFiatAmountText: String
        let amountWithFiatFeeText: String

        if let decimalPrice = price {
            let fiatAmount = NSDecimalNumber(decimal: decimalPrice).multiplying(by: NSDecimalNumber(decimal: paymentOperation.amountInXlm))
            let fiatAmountFormatted = NumberFormatter.localCurrencyFormatter.string(from: fiatAmount)
            fiatTotalAmountText = fiatAmountFormatted == nil ? "" : (fiatCurrencySymbol + fiatAmountFormatted!)
            cryptoWithFiatAmountText = fiatTotalAmountText.isEmpty ?
                amountXlmStringWithSymbol :
                "\(amountXlmStringWithSymbol) (\(fiatTotalAmountText))"

            let fiatFee = NSDecimalNumber(decimal: decimalPrice).multiplying(by: NSDecimalNumber(decimal: paymentOperation.feeInXlm))
            let fiatFeeText = NumberFormatter.localCurrencyFormatter.string(from: fiatFee) ?? ""
            amountWithFiatFeeText = fiatFeeText.isEmpty ?
                feeXlmStringWithSymbol :
                "\(feeXlmStringWithSymbol) (\(fiatCurrencySymbol)\(fiatFeeText))"
        } else {
            fiatTotalAmountText = ""
            cryptoWithFiatAmountText = amountXlmStringWithSymbol
            amountWithFiatFeeText = feeXlmStringWithSymbol
        }

        return BCConfirmPaymentViewModel(
            from: paymentOperation.sourceAccount.label ?? "",
            to: paymentOperation.destinationAccountId,
            totalAmountText: amountXlmStringWithSymbol,
            fiatTotalAmountText: fiatTotalAmountText,
            cryptoWithFiatAmountText: cryptoWithFiatAmountText,
            amountWithFiatFeeText: amountWithFiatFeeText,
            buttonTitle: LocalizationConstants.SendAsset.send,
            showDescription: true,
            surgeIsOccurring: false,
            noteText: nil,
            warningText: nil
        )
    }
}

extension SendLumensViewController: SendXLMModelInterface {
    func updateFee(_ value: Decimal) {
        xlmFee = value
    }

    func updatePrice(_ value: Decimal) {
        latestPrice = value
    }

    func updateXLMAmount(_ value: Decimal) {
        xlmAmount = value
    }
}

extension SendLumensViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let newString = text.replacingCharacters(in: textRange, with: string)

            var maxDecimalPlaces: Int?
            if textField == stellarAmountField {
                maxDecimalPlaces = NumberFormatter.stellarFractionDigits
            } else if textField == fiatAmountField {
                maxDecimalPlaces = NumberFormatter.localCurrencyFractionDigits
            }

            guard let decimalPlaces = maxDecimalPlaces else {
                // TODO: Handle to address field here
                return true
            }

            let amountDelegate = AmountTextFieldDelegate(maxDecimalPlaces: decimalPlaces)
            let isInputValid = amountDelegate.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
            if !isInputValid {
                return false
            }

            guard let price = latestPrice else { return true }
            if textField == stellarAmountField {
                delegate?.onXLMEntry(newString, latestPrice: price)
            } else if textField == fiatAmountField {
                delegate?.onFiatEntry(newString, latestPrice: price)
            }
        }
        return true
    }
}
