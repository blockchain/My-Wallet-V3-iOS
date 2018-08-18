//
//  ExchangeCreateView.swift
//  Blockchain
//
//  Created by kevinwu on 7/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// TICKET: 1159 Combine this protocol with other delegates in setup method and rename 'clicked' to 'tapped'
@objc protocol ExchangeCreateViewDelegate {
    func assetToggleButtonTapped()
    func useMinButtonTapped()
    func useMaxButtonTapped()
    func continueButtonTapped()
}

/*
This view is intended to provide subviews and gesture/input-related methods
required for a general Exchange user interface.
To use it, create an instance using init(frame:), add it as a subview, and call the setup method.
*/
@objc class ExchangeCreateView: UIView {
    // Digital asset input
    @objc var topLeftField: BCSecureTextField?
    @objc var topRightField: BCSecureTextField?

    // Fiat input
    @objc var bottomLeftField: BCSecureTextField?
    @objc var bottomRightField: BCSecureTextField?

    @objc var fiatLabel: UILabel?

    @objc var btcField: BCSecureTextField?
    @objc var ethField: BCSecureTextField?
    @objc var bchField: BCSecureTextField?

    @objc var lastChangedField: UITextField?

    @objc var fromToView: FromToView?
    @objc var leftLabel: UILabel?
    @objc var rightLabel: UILabel?
    @objc var assetToggleButton: UIButton?
    @objc var spinner: UIActivityIndicatorView?
    @objc var continuePaymentAccessoryView: ContinueButtonInputAccessoryView?
    @objc var continueButton: UIButton?

    @objc var errorTextView: UITextView?

    private weak var createViewDelegate: ExchangeCreateViewDelegate?
    private weak var fromToButtonDelegate: FromToButtonDelegate?
    private weak var continueButtonInputAccessoryDelegate: ContinueButtonInputAccessoryViewDelegate?
    private weak var textFieldDelegate: UITextFieldDelegate?
}

// MARK: - Setup

extension ExchangeCreateView {
    @objc func setup(
        createViewDelegate: ExchangeCreateViewDelegate,
        fromToButtonDelegate: FromToButtonDelegate,
        continueButtonInputAccessoryDelegate: ContinueButtonInputAccessoryViewDelegate,
        textFieldDelegate: UITextFieldDelegate
    ) {
        self.createViewDelegate = createViewDelegate
        self.fromToButtonDelegate = fromToButtonDelegate
        self.continueButtonInputAccessoryDelegate = continueButtonInputAccessoryDelegate
        self.textFieldDelegate = textFieldDelegate

        backgroundColor = UIColor.lightGray
        setupSubviews()
    }
}

private extension ExchangeCreateView {
    func setupSubviews() {
        setupFromToView()

        let amountView = UIView(frame: CGRect(
            x: 0,
            y: fromToView!.frame.origin.y + fromToView!.frame.size.height + 1,
            width: windowWidth,
            height: 96
        ))
        amountView.backgroundColor = UIColor.white
        addSubview(amountView)

        setupTopLeftLabel(amountView: amountView)
        setupToggleButtonWithSpinner(amountView: amountView)
        setupTopRightLabel(amountView: amountView)
        setupInputAccessoryView()
        setupTopFields(amountView: amountView)
        setupBottomFields(amountView: amountView)
        setupFiatLabel(amountView: amountView)
        setupMinAndMaxButtons(amountView: amountView)
        setupErrorTextView(amountView: amountView)
        setupContinueButton()
    }

    var windowWidth: CGFloat { return frame.size.width }

    func setupFromToView() {
        let fromToView = FromToView(frame: CGRect(x: 0, y: 16, width: windowWidth, height: 96), enableToTextField: false)
        fromToView!.fromImageView.image = #imageLiteral(resourceName: "chevron_right")
        fromToView!.toImageView.image = #imageLiteral(resourceName: "chevron_right")
        fromToView!.delegate = fromToButtonDelegate
        addSubview(fromToView!)
        self.fromToView = fromToView
    }

    var smallFont: UIFont { return UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Small)! }
    var topLeftLabelFrame: CGRect { return CGRect(x: 15, y: 0, width: 40, height: 30) }

    func setupTopLeftLabel(amountView: UIView) {
        let topLeftLabel = UILabel(frame: topLeftLabelFrame)
        topLeftLabel.font = smallFont
        topLeftLabel.textColor = UIColor.gray5
        topLeftLabel.text = AssetType.bitcoin.symbol
        topLeftLabel.center = CGPoint(x: topLeftLabel.center.x, y: FromToView.self.rowHeight() / 2)

        leftLabel = topLeftLabel
        amountView.addSubview(topLeftLabel)
    }

    var toggleButtonFrame: CGRect { return CGRect(x: 0, y: 12, width: 30, height: 30) }

    func setupToggleButtonWithSpinner(amountView: UIView) {
        let assetToggleButton = UIButton(frame: toggleButtonFrame)
        assetToggleButton.center = CGPoint(x: windowWidth / 2, y: assetToggleButton.center.y)
        assetToggleButton.addTarget(self, action: #selector(self.assetToggleButtonTapped), for: .touchUpInside)
        assetToggleButton.setImage(#imageLiteral(resourceName: "switch_currencies"), for: .normal)
        assetToggleButton.imageView?.transform = CGAffineTransform(rotationAngle: .pi / 2)
        assetToggleButton.center = CGPoint(x: assetToggleButton.center.x, y: FromToView.self.rowHeight() / 2)
        amountView.addSubview(assetToggleButton)
        self.assetToggleButton = assetToggleButton

        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner!.center = assetToggleButton.center
        amountView.addSubview(spinner!)
        spinner!.isHidden = true
    }

    var topRightLabelFrame: CGRect { return CGRect(
        x: self.assetToggleButton!.frame.origin.x + self.assetToggleButton!.frame.size.width + 15,
        y: 12,
        width: 40,
        height: 30)
    }

    func setupTopRightLabel(amountView: UIView) {
        let topRightLabel = UILabel(frame: topRightLabelFrame)
        topRightLabel.font = smallFont
        topRightLabel.textColor = UIColor.gray5
        topRightLabel.text = AssetType.ethereum.symbol
        topRightLabel.center = CGPoint(x: topRightLabel.center.x, y: FromToView.self.rowHeight() / 2)
        rightLabel = topRightLabel
        amountView.addSubview(topRightLabel)
    }

    func setupInputAccessoryView() {
        let inputAccessoryView = ContinueButtonInputAccessoryView()
        inputAccessoryView.delegate = continueButtonInputAccessoryDelegate
        continuePaymentAccessoryView = inputAccessoryView
    }

    var leftFieldOriginX: CGFloat { return topLeftLabelFrame.origin.x + topLeftLabelFrame.size.width + 8 }
    var rightFieldOriginX: CGFloat { return topRightLabelFrame.origin.x + topRightLabelFrame.size.width + 8 }
    var leftFieldWidth: CGFloat { return self.assetToggleButton!.frame.origin.x - 8 - leftFieldOriginX }
    var rightFieldWidth: CGFloat { return windowWidth - 8 - rightFieldOriginX }

    func setupTopFields(amountView: UIView) {
        let leftField = inputTextField(frame: CGRect(x: leftFieldOriginX, y: 12, width: leftFieldWidth, height: 30))
        amountView.addSubview(leftField)
        leftField.placeholder = assetPlaceholder
        leftField.center = CGPoint(x: leftField.center.x, y: FromToView.self.rowHeight() / 2)
        topLeftField = leftField
        btcField = topLeftField
        let rightField = inputTextField(frame: CGRect(x: rightFieldOriginX, y: 12, width: rightFieldWidth, height: 30))
        amountView.addSubview(rightField)
        rightField.placeholder = assetPlaceholder
        rightField.center = CGPoint(x: rightField.center.x, y: FromToView.self.rowHeight() / 2)
        topRightField = rightField
        ethField = topRightField
    }

    func setupBottomFields(amountView: UIView) {
        let dividerLine = UIView(frame: CGRect(
            x: leftFieldOriginX,
            y: FromToView.self.rowHeight(),
            width: windowWidth - leftFieldOriginX,
            height: 0.5
        ))
        dividerLine.backgroundColor = UIColor.grayLine
        amountView.addSubview(dividerLine)

        bottomLeftField = inputTextField(frame: CGRect(
            x: leftFieldOriginX,
            y: dividerLine.frame.origin.y + dividerLine.frame.size.height + 8,
            width: leftFieldWidth,
            height: 30
        ))
        amountView.addSubview(bottomLeftField!)
        bottomLeftField?.placeholder = fiatPlaceholder
        bottomLeftField?.center = CGPoint(x: bottomLeftField?.center.x ?? 0.0, y: FromToView.self.rowHeight() * 1.5)

        bottomRightField = inputTextField(frame: CGRect(
            x: rightFieldOriginX,
            y: dividerLine.frame.origin.y + dividerLine.frame.size.height + 8,
            width: rightFieldWidth,
            height: 30
        ))
        amountView.addSubview(bottomRightField!)
        bottomRightField?.placeholder = fiatPlaceholder
        bottomRightField?.center = CGPoint(x: bottomRightField!.center.x, y: FromToView.self.rowHeight() * 1.5)
    }

    func setupFiatLabel(amountView: UIView) {
        fiatLabel = UILabel(frame: CGRect(x: 15, y: 0, width: 40, height: 30))
        fiatLabel?.center = CGPoint(x: fiatLabel!.center.x, y: bottomLeftField!.center.y)
        fiatLabel?.font = smallFont
        fiatLabel?.textColor = UIColor.gray5
        fiatLabel?.text = WalletManager.shared.latestMultiAddressResponse!.symbol_local.code
        fiatLabel?.center = CGPoint(x: fiatLabel!.center.x, y: FromToView.self.rowHeight() * 1.5)
        amountView.addSubview(fiatLabel!)
    }

    var conversionRateViewHeight: CGFloat { return 50 }

    func setupConversionRateView(amountView: UIView) {
        let lineAboveButtonsView = BCLine(yPosition: amountView.frame.origin.y + amountView.frame.size.height)
        addSubview(lineAboveButtonsView!)

        let conversionRateView = UIView(frame: CGRect(
            x: 0,
            y: amountView.frame.origin.y + amountView.frame.size.height + 0.5,
            width: windowWidth,
            height: minMaxButtonHeight
        ))
    }

    var minMaxButtonHeight: CGFloat { return 50 }

    func setupMinAndMaxButtons(amountView: UIView) {
        let buttonsView = UIView(frame: CGRect(
            x: 0,
            y: amountView.frame.origin.y + amountView.frame.size.height + 0.5,
            width: windowWidth,
            height: minMaxButtonHeight
        ))
        buttonsView.backgroundColor = UIColor.grayLine
        addSubview(buttonsView)

        let buttonFont = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.Small)
        let dividerLineWidth: CGFloat = 0.5
        let useMinButton = UIButton(frame: CGRect(
            x: 0,
            y: 0,
            width: buttonsView.frame.size.width / 2 - dividerLineWidth / 2,
            height: minMaxButtonHeight
        ))
        useMinButton.titleLabel?.font = buttonFont
        useMinButton.backgroundColor = UIColor.white
        useMinButton.setTitleColor(UIColor.brandSecondary, for: .normal)
        useMinButton.setTitle(LocalizationConstants.Exchange.useMinimum, for: .normal)
        useMinButton.addTarget(self, action: #selector(self.useMinButtonTapped), for: .touchUpInside)
        buttonsView.addSubview(useMinButton)

        let useMaxButtonOriginX: CGFloat = buttonsView.frame.size.width / 2 + dividerLineWidth / 2
        let useMaxButton = UIButton(frame: CGRect(
            x: useMaxButtonOriginX,
            y: 0,
            width: buttonsView.frame.size.width - useMaxButtonOriginX,
            height: minMaxButtonHeight
        ))
        useMaxButton.titleLabel?.font = buttonFont
        useMaxButton.backgroundColor = UIColor.white
        useMaxButton.setTitleColor(UIColor.brandSecondary, for: .normal)
        useMaxButton.setTitle(LocalizationConstants.Exchange.useMaximum, for: .normal)
        useMaxButton.addTarget(self, action: #selector(self.useMaxButtonTapped), for: .touchUpInside)
        buttonsView.addSubview(useMaxButton)
    }

    func setupErrorTextView(amountView: UIView) {
        let errorTextView = UITextView(frame: CGRect(
            x: 15,
            y: amountView.frame.origin.y + amountView.frame.size.height + 0.5 + minMaxButtonHeight + 8,
            width: windowWidth - 30,
            height: 60
        ))
        errorTextView.isEditable = false
        errorTextView.isScrollEnabled = false
        errorTextView.isSelectable = false
        errorTextView.textColor = UIColor.error
        errorTextView.font = smallFont
        errorTextView.backgroundColor = UIColor.clear
        addSubview(errorTextView)
        errorTextView.isHidden = true
    }

    func setupContinueButton() {
        continueButton = UIButton(frame: CGRect(x: 0, y: 0, width: frame.size.width - 40, height: Constants.Measurements.buttonHeight))
        continueButton?.backgroundColor = UIColor.brandSecondary
        continueButton?.layer.cornerRadius = Constants.Measurements.buttonCornerRadius
        continueButton?.setTitleColor(UIColor.white, for: .normal)
        continueButton?.titleLabel?.font = UIFont(name: Constants.FontNames.montserratRegular, size: 17.0)
        continueButton?.setTitle(LocalizationConstants.continueString, for: .normal)
        let safeAreaInsetTop: CGFloat = UIView.rootViewSafeAreaInsets().top
        let continueButtonCenterY = frame.size.height - 24 - Constants.Measurements.buttonHeight / 2
            - safeAreaInsetTop - ConstantsObjcBridge.defaultNavigationBarHeight()
        continueButton?.center = CGPoint(x: center.x, y: continueButtonCenterY)
        addSubview(continueButton!)
        continueButton?.addTarget(self, action: #selector(self.continueButtonTapped), for: .touchUpInside)
    }
}

// MARK: - Button actions

@objc private extension ExchangeCreateView {
    func assetToggleButtonTapped() {
        createViewDelegate?.assetToggleButtonTapped()
    }

    func useMinButtonTapped() {
        createViewDelegate?.useMinButtonTapped()
    }

    func useMaxButtonTapped() {
        createViewDelegate?.useMaxButtonTapped()
    }

    func continueButtonTapped() {
        createViewDelegate?.continueButtonTapped()
    }
}

// MARK: - View Helpers

private extension ExchangeCreateView {
    var fiatPlaceholder: String {
        return placeholder(decimalPlaces: 2)
    }

    var assetPlaceholder: String {
        return placeholder(decimalPlaces: 3)
    }

    func placeholder(decimalPlaces: Int) -> String {
        let decimalSeparator = NSLocale.current.decimalSeparator ?? "."
        var afterDecimal = ""
        for _ in 0..<decimalPlaces {
            afterDecimal += "0"
        }
        return "0\(decimalSeparator)" + afterDecimal
    }

    func inputTextField(frame: CGRect) -> BCSecureTextField {
        let textField = BCSecureTextField(frame: frame)
        textField.keyboardType = .decimalPad
        textField.font = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.Small)
        textField.textColor = UIColor.gray5
        textField.delegate = textFieldDelegate
        textField.inputAccessoryView = continuePaymentAccessoryView
        return textField
    }
}

// MARK: - View methods
@objc extension ExchangeCreateView {
    func clearFields() {
        topLeftField?.text = nil
        topRightField?.text = nil
        bottomLeftField?.text = nil
        bottomRightField?.text = nil
    }

    func hideKeyboard() {
        bottomRightField?.resignFirstResponder()
        bottomLeftField?.resignFirstResponder()
        topLeftField?.resignFirstResponder()
        topRightField?.resignFirstResponder()
    }

    func highlightInvalidAmounts() {
        changeAmountFieldColor(color: UIColor.error)
    }

    func removeHighlightFromAmounts() {
        changeAmountFieldColor(color: UIColor.gray5)
    }

    private func changeAmountFieldColor(color: UIColor) {
        topLeftField?.textColor = color
        topRightField?.textColor = color
        bottomLeftField?.textColor = color
        bottomRightField?.textColor = color
    }

    func enableAssetToggleButton() {
        assetToggleButton?.isUserInteractionEnabled = true
        assetToggleButton?.setImage(#imageLiteral(resourceName: "switch_currencies"), for: .normal)
    }

    func disableAssetToggleButton() {
        assetToggleButton?.isUserInteractionEnabled = false
        assetToggleButton?.setImage(nil, for: .normal)
    }

    func startSpinner() {
        spinner?.startAnimating()
    }

    func stopSpinner() {
        spinner?.stopAnimating()
    }

    func enablePaymentButtons() {
        continuePaymentAccessoryView?.enableContinueButton()
        continueButton?.isEnabled = true
        continueButton?.setTitleColor(UIColor.white, for: .normal)
        continueButton?.backgroundColor = UIColor.brandSecondary
    }

    func disablePaymentButtons() {
        continuePaymentAccessoryView?.disableContinueButton()
        continueButton?.isEnabled = false
        continueButton?.setTitleColor(UIColor.gray, for: .disabled)
        continueButton?.backgroundColor = UIColor.keyPadButton
    }

    func showError(text: String) {
        highlightInvalidAmounts()
        errorTextView?.isHidden = false
        errorTextView?.text = text
        disablePaymentButtons()
    }

    func clearRightFields() {
        topRightField?.text = nil
        bottomRightField?.text = nil
    }

    private func clearLeftFields() {
        topLeftField?.text = nil
        bottomLeftField?.text = nil
    }

    func clearOppositeFields() {
        guard let topRightFieldIsActive = topRightField?.isFirstResponder,
            let bottomRightFieldIsActive = bottomRightField?.isFirstResponder else {
            Logger.shared.error("isFirstResponder returning nil instead of boolean")
            return
        }
        if topRightFieldIsActive || bottomRightFieldIsActive {
            clearLeftFields()
        } else {
            clearRightFields()
        }
    }
}
