// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import UIKit

final class DigitPadButtonView: UIView {

    // MARK: - UI Properties

    @IBOutlet private var backgroundView: UIView!
    @IBOutlet private var button: UIButton!

    // MARK: - Rx

    private let disposeBag = DisposeBag()

    // MARK: - Injected

    var viewModel: DigitPadButtonViewModel! {
        didSet {
            backgroundView.layer.cornerRadius = viewModel.background.cornerRadius
            switch viewModel.content {
            case .image(type: let image, tint: let color):
                button.setImage(image.image, for: .normal)
                button.imageView?.tintColor = color
            case .label(text: let value, tint: let color):
                button.setTitle(value, for: .normal)
                button.setTitleColor(color, for: .normal)
            case .none:
                break
            }

            button.accessibility = viewModel.content.accessibility

            // Bind button taps to the view model tap relay
            button.rx.tap
                .bindAndCatch(weak: self) { (self) in
                    self.viewModel.tap()
                }
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Setup

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        fromNib(in: Bundle.platformUIKit)
        button.titleLabel?.font = .main(.medium, 32)
        backgroundView.clipsToBounds = true
        backgroundColor = .clear
    }

    // MARK: - Button touches

    @IBAction private func touchDown() {
        backgroundView.backgroundColor = viewModel.background.highlightColor
    }

    @IBAction private func touchUp() {
        backgroundView.backgroundColor = .clear
    }
}
