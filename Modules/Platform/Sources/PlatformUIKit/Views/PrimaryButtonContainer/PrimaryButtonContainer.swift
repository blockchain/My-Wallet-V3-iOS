// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxRelay
import RxSwift
import UIKit

@IBDesignable
public class PrimaryButtonContainer: NibBasedView {

    private enum FontNames {
        static let montserratRegular = "Montserrat-Regular"
        static let montserratMedium = "Montserrat-Medium"
    }

    public enum PrimaryButtonFont: Int {
        case kyc = 0
        case send = 1
        case small = 2

        var font: UIFont {
            switch self {
            case .kyc:
                return UIFont(
                    name: FontNames.montserratMedium,
                    size: 20.0
                ) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
            case .send:
                return UIFont(
                    name: FontNames.montserratRegular,
                    size: 17.0
                ) ?? UIFont.systemFont(ofSize: 17.0, weight: .regular)
            case .small:
                return UIFont(
                    name: FontNames.montserratRegular,
                    size: 14.0
                ) ?? UIFont.systemFont(ofSize: 14.0, weight: .regular)
            }
        }
    }

    override public var bundle: Bundle { .module }

    // MARK: Private IBOutlets

    @IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate var primaryButton: UIButton!

    // MARK: Public

    /// Simple block for handling the call back when the
    /// `primaryButton` is tapped.
    public var actionBlock: (() -> Void)?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        primaryButton.layer.cornerRadius = 4.0
        buttonBackgroundColor = UIColor.semantic.primary
        buttonTitleColor = .primaryButtonTitle
        primaryButton.accessibility = .id(Accessibility.Identifier.General.mainCTAButton)
    }

    public var activityIndicatorStyle: UIActivityIndicatorView.Style = .large {
        didSet {
            activityIndicator.style = activityIndicatorStyle
        }
    }

    // MARK: IBInspectable

    @IBInspectable public var primaryButtonFont: Int = 0 {
        didSet {
            let value = PrimaryButtonFont(rawValue: primaryButtonFont) ?? .kyc
            primaryButton.titleLabel?.font = value.font
        }
    }

    @IBInspectable public var buttonBackgroundColor: UIColor = .brandSecondary {
        didSet {
            primaryButton.backgroundColor = buttonBackgroundColor
        }
    }

    @IBInspectable public var buttonTitleColor: UIColor = .primaryButtonTitle {
        didSet {
            primaryButton.setTitleColor(buttonTitleColor, for: .normal)
        }
    }

    @IBInspectable public var disabledButtonBackgroundColor: UIColor = .brandSecondary

    @IBInspectable public var isLoading: Bool = false {
        didSet {
            isLoading == true ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
            primaryButton.setTitleColor(isLoading ? buttonBackgroundColor : buttonTitleColor, for: .normal)
        }
    }

    @IBInspectable public var title: String {
        get {
            primaryButton.title(for: .normal) ?? ""
        }
        set {
            primaryButton.setTitle(newValue, for: .normal)
        }
    }

    @IBInspectable public var attributedTitle: NSAttributedString {
        get {
            primaryButton.attributedTitle(for: .normal) ?? NSAttributedString(string: title)
        }
        set {
            primaryButton.setAttributedTitle(newValue, for: .normal)
        }
    }

    @IBInspectable public var isEnabled: Bool = true {
        didSet {
            primaryButton.isEnabled = isEnabled
            primaryButton.backgroundColor = isEnabled ? buttonBackgroundColor : disabledButtonBackgroundColor
        }
    }

    // MARK: Actions

    @IBAction func primaryButtonTapped(_ sender: UIButton) {
        actionBlock?()
    }
}

extension Reactive where Base: PrimaryButtonContainer {
    public var isEnabled: Binder<Bool> {
        Binder(base) { container, isEnabled in
            container.isEnabled = isEnabled
        }
    }
}

extension Reactive where Base: PrimaryButtonContainer {
    public var tap: ControlEvent<Void> {
        base.primaryButton.rx.tap
    }
}
