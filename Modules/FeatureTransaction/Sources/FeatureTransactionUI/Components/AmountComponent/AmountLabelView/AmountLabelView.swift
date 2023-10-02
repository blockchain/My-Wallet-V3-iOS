// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift
import UIComponentsKit
import UIKit

public final class AmountLabelView: UIView {

    // MARK: - Exposed Properties

    public var presenter: AmountLabelViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter else { return }

            presenter.output
                .map(\.string)
                .drive(weak: self, onNext: { (self, attributedText) in
                    self.amountLabel.attributedText = attributedText
                    self.amountLabel.lineBreakMode = .byClipping
                })
                .disposed(by: disposeBag)

            presenter.output
                .map(\.accessibility)
                .drive(amountLabel.rx.accessibility)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - UI Properties

    override public var intrinsicContentSize: CGSize {
        amountLabel.intrinsicContentSize
    }

    public var textColor: UIColor {
        get {
            amountLabel.textColor
        }
        set {
            amountLabel.textColor = newValue
        }
    }

    private let amountLabel = UILabel()

    // MARK: - Accessors

    private var disposeBag = DisposeBag()

    // MARK: - Setup

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(amountLabel)
        amountLabel.constraint(edgesTo: self)
        amountLabel.minimumScaleFactor = 0.35
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.textAlignment = .center
        amountLabel.baselineAdjustment = .alignCenters

        verticalContentHuggingPriority = UILayoutPriority.defaultLow
        horizontalContentHuggingPriority = UILayoutPriority.defaultLow
        verticalContentCompressionResistancePriority = UILayoutPriority.defaultHigh
        horizontalContentCompressionResistancePriority = UILayoutPriority.defaultHigh
    }
}
