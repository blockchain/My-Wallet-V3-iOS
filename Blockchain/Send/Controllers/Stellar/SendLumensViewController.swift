//
//  SendLumensViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

protocol SendXLMViewControllerDelegate: class {
    func onLoad()
    func onAppear()
    func onMemoTextSelection()
    func onMemoIDSelection()
    func onXLMEntry(_ value: String, latestPrice: Decimal)
    func onFiatEntry(_ value: String, latestPrice: Decimal)
    func onStellarAddressEntry()
    func onPrimaryTapped(toAddress: String, amount: Decimal, feeInXlm: Decimal, memo: StellarMemoType?)
    func onConfirmPayTapped(_ paymentOperation: StellarPaymentOperation)
    func onMinimumBalanceInfoTapped()
}

@objc class SendLumensViewController: UIViewController, BottomButtonContainerView {
    
    
    fileprivate static let topToStackView: CGFloat = 12.0
    fileprivate static let maximumMemoTextLength: Int = 28
    
    fileprivate var keyboardHeight: CGFloat {
        let type = UIDevice.current.type
        if type.isBelow(.iPhone8Plus) {
            return 216
        } else {
            return 226
        }
    }
    
    // MARK: BottomButtonContainerView
    
    var originalBottomButtonConstraint: CGFloat!
    var optionalOffset: CGFloat = -50
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
    @IBOutlet fileprivate var memoLabel: UILabel!
    
    // MARK: Private IBOutlets (UITextField)
    
    @IBOutlet fileprivate var stellarAddressField: UITextField!
    @IBOutlet fileprivate var stellarAmountField: UITextField!
    @IBOutlet fileprivate var fiatAmountField: UITextField!
    @IBOutlet fileprivate var memoTextField: UITextField!
    @IBOutlet fileprivate var memoIDTextField: UITextField!
    
    fileprivate var inputFields: [UITextField] {
        return [
            stellarAddressField,
            stellarAmountField,
            fiatAmountField,
            memoTextField,
            memoIDTextField
        ]
    }
    
    // MARK: Private IBOutlets (Other)
    
    @IBOutlet fileprivate var topToStackViewConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var useMaxLabel: ActionableLabel!
    @IBOutlet fileprivate var primaryButtonContainer: PrimaryButtonContainer!
    @IBOutlet fileprivate var learnAbountStellarButton: UIButton!
    @IBOutlet fileprivate var bottomStackView: UIStackView!
    @IBOutlet fileprivate var memoSelectionTypeButton: UIButton!
    
    weak var delegate: SendXLMViewControllerDelegate?
    fileprivate var coordinator: SendXLMCoordinator!
    fileprivate var trigger: ActionableTrigger?
    fileprivate var memo: StellarMemoType?
    fileprivate var toolbar: UIToolbar?

    // MARK: - Models
    private var pendingPaymentOperation: StellarPaymentOperation?
    private var latestPrice: Decimal? // fiat per whole unit
    private var xlmAmount: Decimal?
    private var xlmFee: Decimal?
    private var baseReserve: Decimal?
    
    private var qrScannerViewModel: QRCodeScannerViewModel<AddressQRCodeParser>?
    
    // MARK: Factory
    
    @objc class func make(with provider: XLMServiceProvider) -> SendLumensViewController {
        let controller = SendLumensViewController.makeFromStoryboard()
        controller.coordinator = SendXLMCoordinator(
            serviceProvider: provider,
            interface: controller,
            modelInterface: controller
        )
        return controller
    }
    
    // MARK: ViewUpdate
    
    enum PresentationUpdate {
        case activityIndicatorVisibility(Visibility)
        case errorLabelVisibility(Visibility)
        case learnAboutStellarButtonVisibility(Visibility)
        case actionableLabelVisibility(Visibility)
        case memoTextFieldVisibility(Visibility)
        case memoIDTextFieldVisibility(Visibility)
        case memoSelectionButtonVisibility(Visibility)
        case memoTextFieldShouldBeginEditing
        case memoIDFieldShouldBeginEditing
        case errorLabelText(String)
        case feeAmountLabelText()
        case stellarAddressText(String)
        case stellarAddressTextColor(UIColor)
        case xlmFieldTextColor(UIColor)
        case fiatFieldTextColor(UIColor)
        case actionableLabelTrigger(ActionableTrigger)
        case primaryButtonEnabled(Bool)
        case showPaymentConfirmation(StellarPaymentOperation)
        case hidePaymentConfirmation
        case paymentSuccess
        case stellarAmountText(String?)
        case fiatAmountText(String?)
        case fiatSymbolLabel(String?)
    }

    // MARK: Public Methods

    @objc func scanQrCodeForDestinationAddress() {
        guard let scanner = QRCodeScanner() else { return }
        
        let parser = AddressQRCodeParser(assetType: .stellar)
        let textViewModel = AddressQRCodeTextViewModel()
        
        qrScannerViewModel = QRCodeScannerViewModel(
            parser: parser,
            textViewModel: textViewModel,
            scanner: scanner,
            completed: { [weak self] result in
                self?.handleAddressScan(result: result)
            }
        )
        
        let viewController = QRCodeScannerViewControllerBuilder(viewModel: qrScannerViewModel)?
            .with(dismissAnimated: false)
            .build()
        
        guard let qrCodeScannerViewController = viewController else { return }
        
        DispatchQueue.main.async {
            guard let controller = AppCoordinator.shared.tabControllerManager.tabViewController else { return }
            controller.present(qrCodeScannerViewController, animated: true, completion: nil)
        }
    }
    
    private func handleAddressScan(result: NewResult<AddressQRCodeParser.Address, AddressQRCodeParser.AddressQRCodeParserError>) {
        if case .success(let address) = result {
            stellarAddressField.text = address.payload.address
            stellarAmountField.text = address.payload.amount
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = UIView.rootViewSafeAreaFrame(
            navigationBar: true,
            tabBar: true,
            assetSelector: true
        )
        originalBottomButtonConstraint = layoutConstraintBottomButton.constant
        setUpBottomButtonContainerView()
        setupMemoIDField()
        useMaxLabel.delegate = self
        memoTextField.delegate = self
        stellarAddressField.delegate = self
        primaryButtonContainer.isEnabled = true
        learnAbountStellarButton.titleLabel?.textAlignment = .center
        primaryButtonContainer.actionBlock = { [unowned self] in
            guard let toAddress = self.stellarAddressField.text else { return }
            guard let amount = self.xlmAmount else { return }
            guard let fee = self.xlmFee else { return }
            self.inputFields.forEach({ $0.resignFirstResponder() })
            self.delegate?.onPrimaryTapped(toAddress: toAddress, amount: amount, feeInXlm: fee, memo: self.memo)
        }
        delegate?.onLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.onAppear()
    }
    
    fileprivate func clearMemoField() {
        /// Users may change their mind and want to enter in a
        /// `Int` as their memo as opposed to a string value.
        /// So we do this when they have deleted everything in
        /// the memo field.
        [memoTextField, memoIDTextField].forEach({ $0?.resignFirstResponder() })
        memo = nil
        apply(updates: [.memoTextFieldVisibility(.visible),
                        .memoIDTextFieldVisibility(.hidden),
                        .memoSelectionButtonVisibility(.visible)])
    }
    
    fileprivate func setupMemoIDField() {
        toolbar = UIToolbar()
        toolbar?.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resignMemoIDField))
        toolbar?.items = [doneButton]
        memoIDTextField.inputAccessoryView = toolbar
    }
    
    @objc func resignMemoIDField() {
        memoIDTextField.resignFirstResponder()
        
        /// If the user hasn't entered a value in the `memoIDTextField`
        /// we call `clearMemoField()` to reset the memo state. This allows
        /// users to see the action sheet again to select either `memoID` or
        /// `memoText`
        guard memoIDTextField.text == nil else { return }
        clearMemoField()
    }
    
    fileprivate func useMaxAttributes() -> [NSAttributedString.Key: Any] {
        let fontName = Constants.FontNames.montserratRegular
        let font = UIFont(name: fontName, size: 13.0) ?? UIFont.systemFont(ofSize: 13.0)
        return [.font: font,
                .foregroundColor: UIColor.darkGray]
    }
    
    fileprivate func useMaxActionAttributes() -> [NSAttributedString.Key: Any] {
        let fontName = Constants.FontNames.montserratRegular
        let font = UIFont(name: fontName, size: 13.0) ?? UIFont.systemFont(ofSize: 13.0)
        return [.font: font,
                .foregroundColor: UIColor.brandSecondary]
    }

    // swiftlint:disable function_body_length
    // swiftlint:disable:next cyclomatic_complexity
    fileprivate func apply(_ update: PresentationUpdate) {
        switch update {
        case .memoTextFieldVisibility(let visibility):
            memoTextField.alpha = visibility.defaultAlpha
        case .memoIDTextFieldVisibility(let visibility):
            memoIDTextField.alpha = visibility.defaultAlpha
        case .memoSelectionButtonVisibility(let visibility):
            memoSelectionTypeButton.alpha = visibility.defaultAlpha
            guard visibility == .visible else { return }
            memoIDTextField.text = nil
            memoTextField.text = nil
            
        case .activityIndicatorVisibility(let visibility):
            primaryButtonContainer.isLoading = (visibility == .visible)
        case .errorLabelVisibility(let visibility):
            errorLabel.isHidden = visibility.isHidden
        case .learnAboutStellarButtonVisibility(let visibility):
            learnAbountStellarButton.isHidden = visibility.isHidden
        case .actionableLabelVisibility(let visibility):
            useMaxLabel.isHidden = visibility.isHidden
        case .memoTextFieldShouldBeginEditing:
            memoTextField.becomeFirstResponder()
        case .memoIDFieldShouldBeginEditing:
            memoIDTextField.becomeFirstResponder()
        case .errorLabelText(let value):
            errorLabel.text = value
        case .feeAmountLabelText:
            // TODO: move formatting outside of this file
            guard let price = latestPrice, let fee = xlmFee else { return }
            let assetType: AssetType = .stellar
            let xlmSymbol = assetType.symbol
            let feeFormatted = NumberFormatter.stellarFormatter.string(from: NSDecimalNumber(decimal: fee)) ?? "\(fee)"
            let fiatCurrencySymbol = BlockchainSettings.sharedAppInstance().fiatCurrencySymbol
            let fiatAmount = price * fee
            let fiatFormatted = NumberFormatter.localCurrencyFormatter.string(from: NSDecimalNumber(decimal: fiatAmount)) ?? "\(fiatAmount)"
            let fiatText = fiatCurrencySymbol + fiatFormatted
            feeAmountLabel.text = "\(feeFormatted) \(xlmSymbol) (\(fiatText))"
        case .stellarAddressText(let value):
            stellarAddressField.text = value
        case .stellarAddressTextColor(let color):
            stellarAddressField.textColor = color
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
        case .fiatSymbolLabel(let text):
            fiatSymbolLabel.text = text
        }
    }

    private func showPaymentSuccess() {
        let controller = AppCoordinator.shared.tabControllerManager
        controller.showTransactionsStellar()
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
    
    @IBAction private func learnAboutStellarButtonTapped(_ sender: Any) {
        delegate?.onMinimumBalanceInfoTapped()
    }
    
    @IBAction private func memoSelectionTypeTapped(_ sender: UIButton) {
        let title = LocalizationConstants.Stellar.memoDescription
        let memoTextOption = LocalizationConstants.Stellar.memoText
        let memoTextID = LocalizationConstants.Stellar.memoID
        let controller = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        [memoTextOption, memoTextID].forEach { option in
            let action = UIAlertAction(title: option, style: .default, handler: { [unowned self] _ in
                switch option {
                case memoTextOption:
                    self.delegate?.onMemoTextSelection()
                    
                case memoTextID:
                    self.delegate?.onMemoIDSelection()
                default:
                    break
                }
            })
            controller.addAction(action)
        }
        let cancel = UIAlertAction(title: LocalizationConstants.cancel, style: .cancel) { _ in
            controller.dismiss(animated: true, completion: nil)
        }
        controller.addAction(cancel)
        present(controller, animated: true, completion: nil)
    }
}

extension SendLumensViewController: SendXLMInterface {
    func apply(updates: [PresentationUpdate]) {
        updates.forEach({ apply($0) })
    }

    func present(viewController: UIViewController) {
        AppCoordinator.shared.tabControllerManager.tabViewController.present(viewController, animated: true)
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

extension BCConfirmPaymentViewModel {
    static func initialize(
        with paymentOperation: StellarPaymentOperation,
        price: Decimal?
    ) -> BCConfirmPaymentViewModel {
        // TODO: Refactor, move formatting out
        let assetType: AssetType = .stellar
        let amountXlm = paymentOperation.amountInXlm
        let feeXlm = paymentOperation.feeInXlm

        let amountXlmDecimalNumber = NSDecimalNumber(decimal: amountXlm)
        let amountXlmString = NumberFormatter.stellarFormatter.string(from: amountXlmDecimalNumber) ?? "\(amountXlm)"
        let amountXlmStringWithSymbol = amountXlmString.appendAssetSymbol(for: assetType)

        let feeXlmDecimalNumber = NSDecimalNumber(decimal: paymentOperation.feeInXlm)
        let feeXlmString = NumberFormatter.stellarFormatter.string(from: feeXlmDecimalNumber) ?? "\(feeXlm)"
        let feeXlmStringWithSymbol = feeXlmString.appendAssetSymbol(for: assetType)

        let totalXlmDecimalNumber = NSDecimalNumber(decimal: amountXlm + feeXlm)
        let totalXlmString = NumberFormatter.stellarFormatter.string(from: totalXlmDecimalNumber) ?? "\(amountXlm)"
        let totalXlmStringWithSymbol = totalXlmString.appendAssetSymbol(for: assetType)

        let fiatTotalAmountText: String
        let cryptoWithFiatAmountText: String
        let amountWithFiatFeeText: String

        if let decimalPrice = price {
            fiatTotalAmountText = NumberFormatter.localCurrencyAmount(
                fromAmount: amountXlm + feeXlm,
                fiatPerAmount: decimalPrice
            ).appendCurrencySymbol()
            cryptoWithFiatAmountText = NumberFormatter.formattedAssetAndFiatAmountWithSymbols(
                fromAmount: amountXlm,
                fiatPerAmount: decimalPrice,
                assetType: .stellar
            )
            amountWithFiatFeeText = NumberFormatter.formattedAssetAndFiatAmountWithSymbols(
                fromAmount: feeXlm,
                fiatPerAmount: decimalPrice,
                assetType: .stellar
            )
        } else {
            fiatTotalAmountText = ""
            cryptoWithFiatAmountText = amountXlmStringWithSymbol
            amountWithFiatFeeText = feeXlmStringWithSymbol
        }

        return BCConfirmPaymentViewModel(
            from: paymentOperation.sourceAccount.label ?? "",
            to: paymentOperation.destinationAccountId,
            totalAmountText: totalXlmStringWithSymbol,
            fiatTotalAmountText: fiatTotalAmountText,
            cryptoWithFiatAmountText: cryptoWithFiatAmountText,
            amountWithFiatFeeText: amountWithFiatFeeText,
            buttonTitle: LocalizationConstants.SendAsset.send,
            showDescription: paymentOperation.memo != nil,
            surgeIsOccurring: false,
            showsFeeInformationButton: false,
            noteText: paymentOperation.memo?.displayValue,
            warningText: nil,
            descriptionTitle: LocalizationConstants.Stellar.memoTitle
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

    func updateXLMAmount(_ value: Decimal?) {
        xlmAmount = value
    }

    func updateBaseReserve(_ value: Decimal?) {
        baseReserve = value
    }
}

extension SendLumensViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if [memoIDTextField, memoTextField].contains(textField), memo == nil {
            clearMemoField()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard UIDevice.current.type.isBelow(.iPhone8Plus) else { return }
        guard [memoTextField, memoIDTextField].contains(textField) else { return }
        let toolbarHeight = toolbar?.frame.height ?? 0.0
        let primaryButtonOffset = originalBottomButtonConstraint +
            optionalOffset +
            keyboardHeight +
            primaryButtonContainer.frame.size.height +
            toolbarHeight
        
        let height = view.bounds.height
        let bottomStackViewMaxY = bottomStackView.frame.maxY
        let offset = (height - bottomStackViewMaxY) - primaryButtonOffset
        
        guard topToStackViewConstraint.constant != offset else { return }
        topToStackViewConstraint.constant = offset
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard topToStackViewConstraint.constant != SendLumensViewController.topToStackView else { return }
        topToStackViewConstraint.constant = SendLumensViewController.topToStackView
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if inputFields.contains(textField) {
            switch textField {
            case memoTextField:
                guard let text = textField.text else { return true }
                guard let current = Range(range, in: text) else { return true }
                let value = text.replacingCharacters(in: current, with: string)
                if value.count == 0 {
                    clearMemoField()
                    return true
                }
                let count = text.utf8.count + string.utf8.count - range.length
                guard count <= SendLumensViewController.maximumMemoTextLength else { return false }
                memo = .text(value)
                
            case memoIDTextField:
                guard let text = textField.text else { return true }
                guard let range = Range(range, in: text) else { return true }
                let value = text.replacingCharacters(in: range, with: string)
                if value.count == 0 {
                    clearMemoField()
                    return true
                }
                guard let identifier = Int(value) else { return false }
                if identifier <= Int64.max {
                    memo = .identifier(identifier)
                    return true
                } else {
                    return false
                }
            case stellarAddressField:
                return addressField(
                    textField,
                    shouldChangeCharactersIn: range,
                    replacementString: string
                )
            case fiatAmountField, stellarAmountField:
                return amountField(
                    textField,
                    shouldChangeCharactersIn: range,
                    replacementString: string
                )
            default:
                return true
            }
        }
        return true
    }
}

// MARK: - Text Field handling
extension SendLumensViewController {

    func amountField(_ amountField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = amountField.text,
            let textRange = Range(range, in: text) {
            let newString = text.replacingCharacters(in: textRange, with: string)

            var maxDecimalPlaces: Int?
            if amountField == stellarAmountField {
                maxDecimalPlaces = NumberFormatter.stellarFractionDigits
            } else if amountField == fiatAmountField {
                maxDecimalPlaces = NumberFormatter.localCurrencyFractionDigits
            }

            guard let decimalPlaces = maxDecimalPlaces else {
                Logger.shared.error("Unhandled textfield")
                return true
            }

            let amountDelegate = AmountTextFieldDelegate(maxDecimalPlaces: decimalPlaces)
            let isInputValid = amountDelegate.textField(amountField, shouldChangeCharactersIn: range, replacementString: string)
            if !isInputValid {
                return false
            }

            guard let price = latestPrice else { return true }
            if amountField == stellarAmountField {
                delegate?.onXLMEntry(newString, latestPrice: price)
            } else if amountField == fiatAmountField {
                delegate?.onFiatEntry(newString, latestPrice: price)
            }
        }
        return true
    }

    func addressField(_ addressField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if addressField == stellarAddressField {
            delegate?.onStellarAddressEntry()
        }
        return true
    }
}
