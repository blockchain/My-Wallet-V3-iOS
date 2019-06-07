//
//  SendPaxViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/23/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PlatformKit
import PlatformUIKit
import EthereumKit
import ERC20Kit
import SafariServices

protocol SendPaxViewControllerDelegate: class {
    func onLoad()
    func onAppear()
    func onConfirmSendTapped()
    func onSendProposed()
    func onPaxEntry(_ value: CryptoValue?)
    func onFiatEntry(_ value: FiatValue)
    func onAddressEntry(_ value: String?)
    func onErrorBarButtonItemTapped()
    func onQRBarButtonItemTapped()
    
    var rightNavigationCTAType: NavigationCTAType { get }
}

class SendPaxViewController: UIViewController {
    
    // MARK: Public Properties
    
    weak var delegate: SendPaxViewControllerDelegate?
    
    // MARK: Private IBOutlets
    
    @IBOutlet private var outerStackView: UIStackView!
    @IBOutlet private var topGravityStackView: UIStackView!

    @IBOutlet private var paxWalletLabel: UILabel!
    @IBOutlet private var networkFeesLabel: UILabel!
    
    @IBOutlet private var paxAddressTextField: UITextField!
    @IBOutlet private var paxTextField: UITextField!
    @IBOutlet private var fiatTextField: UITextField!
    
    @IBOutlet private var sendNowButton: UIButton!
    @IBOutlet private var paxAddressToolTip: UIButton!
    @IBOutlet private var networkFeesToolTip: UIButton!
    
    private var fields: [UITextField] {
        return [
            paxAddressTextField,
            paxTextField,
            fiatTextField
        ]
    }
    
    // MARK: Private Properties
    
    private var coordinator: SendPaxCoordinator!
    
    private var qrScannerViewModel: QRCodeScannerViewModel<AddressQRCodeParser>?
    
    // MARK: Class Functions
    
    @objc class func make() -> SendPaxViewController {
        let controller = SendPaxViewController.makeFromStoryboard()
        return controller
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = SendPaxCoordinator(interface: self)
        [paxAddressToolTip, networkFeesToolTip].forEach({ $0?.setImage(#imageLiteral(resourceName: "icon_help"), for: .normal) })
        fields.forEach({ $0.delegate = self })
        topGravityStackView.addBackgroundColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
        sendNowButton.layer.cornerRadius = 4.0
        delegate?.onLoad()
        
        setupKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.onAppear()
    }
    
    private func setupKeyboard() {
        let bar = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        bar.items = [ flexibleSpace, doneButton ]
        bar.sizeToFit()
        
        paxAddressTextField.inputAccessoryView = bar
        fiatTextField.inputAccessoryView = bar
        paxTextField.inputAccessoryView = bar
        hideKeyboardWhenTappedAround()
    }
    
    private func apply(_ update: SendMoniesPresentationUpdate) {
        switch update {
        case .cryptoValueTextField(let amount):
            guard paxTextField.isFirstResponder == false else { return }
            paxTextField.text = amount?.toDisplayString(includeSymbol: false)
        case .feeValueLabel(let fee):
            networkFeesLabel.text = fee?.toDisplayString(includeSymbol: true)
        case .toAddressTextField(let address):
            paxAddressTextField.text = address
        case .fiatValueTextField(let amount):
            guard fiatTextField.isFirstResponder == false else { return }
            fiatTextField.text = amount?.toDisplayString(includeSymbol: false, locale: Locale.current)
        case .loadingIndicatorVisibility(let visibility):
            switch visibility {
            case .hidden:
                LoadingViewPresenter.shared.hideBusyView()
            case .visible:
                LoadingViewPresenter.shared.showBusyView(withLoadingText: LocalizationConstants.loading)
            }
        case .sendButtonEnabled(let enabled):
            sendNowButton.isEnabled = enabled
            sendNowButton.alpha = enabled ? 1.0 : 0.5
        case .textFieldEditingEnabled(let editable):
            fields.forEach({ $0.isEnabled = editable })
        case .showAlertSheetForError(let error):
            handle(error: error)
        case .showAlertSheetForSuccess:
            let alert = AlertModel(
                headline: LocalizationConstants.success,
                body: LocalizationConstants.SendAsset.paymentSent,
                image: #imageLiteral(resourceName: "eth_good"),
                style: .sheet
            )
            let alertView = AlertView.make(with: alert, completion: nil)
            alertView.show()
        case .hideConfirmationModal:
            ModalPresenter.shared.closeAllModals()
        case .updateNavigationItems:
            if let navController = navigationController as? BaseNavigationController {
                navController.update()
            }
        }
    }
    
    // MARK: Private Helpers
    
    fileprivate func handle(error: SendMoniesInternalError) {
        fields.forEach({ $0.resignFirstResponder() })
        var alert = AlertModel(
            headline: error.title,
            body: error.description,
            image: #imageLiteral(resourceName: "eth_bad"),
            style: .sheet
        )
        if error == .insufficientFeeCoverage {
            guard let url = URL(string: Constants.Url.ethGasExplanationForPax) else { return }
            let action = AlertAction(style: .confirm(LocalizationConstants.AnnouncementCards.learnMore), metadata: .url(url))
            alert.actions = [action]
        }
        let alertView = AlertView.make(with: alert) { [weak self] action in
            guard let self = self else { return }
            guard let metadata = action.metadata else { return }
            switch metadata {
            case .url(let url):
                let viewController = SFSafariViewController(url: url)
                viewController.modalPresentationStyle = .overFullScreen
                self.present(viewController, animated: true, completion: nil)
            case .block,
                 .pop,
                 .payload,
                 .dismiss:
                break
            }
        }
        alertView.show()
    }
    
    // MARK: Actions
    
    @IBAction func sendNowTapped(_ sender: UIButton) {
        delegate?.onSendProposed()
    }
    
    @IBAction func paxAddressToolTipTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func networkFeesToolTipTapped(_ sender: UIButton) {
        
    }
}

extension SendPaxViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else { return }
        if textField == paxAddressTextField {
            delegate?.onAddressEntry(text)
        }
        if textField == paxTextField {
            let value = CryptoValue.paxFromMajor(string: text)
            delegate?.onPaxEntry(value)
        }
        if textField == fiatTextField {
            let currencyCode = BlockchainSettings.App.shared.fiatCurrencyCode
            let value = FiatValue.create(amountString: text, currencyCode: currencyCode)
            delegate?.onFiatEntry(value)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let replacementInput = (text as NSString).replacingCharacters(in: range, with: string)
        
        if textField == paxAddressTextField {
            delegate?.onAddressEntry(replacementInput)
        }
        if textField == paxTextField {
            let value = CryptoValue.paxFromMajor(string: replacementInput)
            delegate?.onPaxEntry(value)
        }
        if textField == fiatTextField {
            let currencyCode = BlockchainSettings.App.shared.fiatCurrencyCode
            let value = FiatValue.create(amountString: replacementInput, currencyCode: currencyCode)
            delegate?.onFiatEntry(value)
        }
        return true
    }
}

extension SendPaxViewController: NavigatableView {
    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        if let type = delegate?.rightNavigationCTAType, type == .error {
            delegate?.onErrorBarButtonItemTapped()
        } else if let type = delegate?.rightNavigationCTAType, type == .qrCode {
            delegate?.onQRBarButtonItemTapped()
        } else if let parent = parent as? AssetSelectorContainerViewController {
            parent.navControllerRightBarButtonTapped(navController)
        }
    }
    
    func navControllerLeftBarButtonTapped(_ navController: UINavigationController) {
        if let parent = parent as? AssetSelectorContainerViewController {
            parent.navControllerLeftBarButtonTapped(navController)
        }
    }
    
    var rightNavControllerCTAType: NavigationCTAType {
        return delegate?.rightNavigationCTAType ?? .qrCode
    }
    
    var rightCTATintColor: UIColor {
        guard let delegate = delegate else { return .white }
        if delegate.rightNavigationCTAType == .qrCode ||
            delegate.rightNavigationCTAType == .activityIndicator {
            return .white
        }
        return .pending
    }
}

extension SendPaxViewController: SendPAXInterface {
    func apply(updates: Set<SendMoniesPresentationUpdate>) {
        updates.forEach({ self.apply($0) })
    }
    
    func display(confirmation: BCConfirmPaymentViewModel) {
        let confirmView = BCConfirmPaymentView(
            frame: view.frame,
            viewModel: confirmation,
            sendButtonFrame: sendNowButton.frame
        )!
        confirmView.confirmDelegate = self
        ModalPresenter.shared.showModal(
            withContent: confirmView,
            closeType: ModalCloseTypeBack,
            showHeader: true,
            headerText: LocalizationConstants.SendAsset.confirmPayment
        )
    }
    
    func displayQRCodeScanner() {
        scanQrCodeForDestinationAddress()
    }
}

extension SendPaxViewController: ConfirmPaymentViewDelegate {
    func confirmButtonDidTap(_ note: String?) {
        delegate?.onConfirmSendTapped()
    }
    
    func feeInformationButtonClicked() {
        // TODO
    }
}

extension SendPaxViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SendPaxViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// TODO: Clean this up, move to Coordinator
extension SendPaxViewController {
    @objc func scanQrCodeForDestinationAddress() {
        guard let scanner = QRCodeScanner() else { return }
        
        let parser = AddressQRCodeParser(assetType: .pax)
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
        if case .success(let assetURL) = result {
            delegate?.onAddressEntry(assetURL.payload.address)
            
            guard
                let amount = assetURL.payload.amount,
                let value = CryptoValue.paxFromMajor(string: amount)
            else {
                return
            }
            delegate?.onPaxEntry(value)
        }
    }
}
