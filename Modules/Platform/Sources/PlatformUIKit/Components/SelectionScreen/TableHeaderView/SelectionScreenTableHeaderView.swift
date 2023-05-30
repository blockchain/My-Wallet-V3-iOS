// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public final class SelectionScreenTableHeaderView: UIView {

    private static let verticalPadding: CGFloat = 32.0
    private static let horizontalPadding: CGFloat = 64.0

    private var disposeBag = DisposeBag()

    // MARK: - Public Properties

    var viewModel: SelectionScreenTableHeaderViewModel! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let viewModel else { return }

            titleLabel.font = viewModel.font

            // Bind label text
            viewModel.text
                .drive(titleLabel.rx.text)
                .disposed(by: disposeBag)

            // Bind label text color
            viewModel.contentColor
                .drive(titleLabel.rx.textColor)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private IBOutlets

    @IBOutlet private var titleLabel: UILabel!

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
        fromNib(in: .module)
        clipsToBounds = true
        backgroundColor = .semantic.background
    }
}

extension SelectionScreenTableHeaderView {
    static func estimatedHeight(for width: CGFloat, model: SelectionScreenTableHeaderViewModel) -> CGFloat {
        let adjustedWidth = width - horizontalPadding
        let textHeight = NSAttributedString(
            string: model.textRelay.value,
            attributes: [
                .font: model.font
            ]
        ).heightForWidth(width: adjustedWidth)
        return textHeight + verticalPadding
    }
}
