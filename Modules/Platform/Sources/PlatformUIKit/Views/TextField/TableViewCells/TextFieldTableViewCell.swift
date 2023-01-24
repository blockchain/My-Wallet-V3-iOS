// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class TextFieldTableViewCell: UITableViewCell {

    // MARK: - Properties

    public var topInset: CGFloat {
        get {
            textFieldView.topInset
        }
        set {
            textFieldView.topInset = newValue
        }
    }

    public var bottomInset: CGFloat {
        get {
            textFieldView.bottomInset
        }
        set {
            textFieldView.bottomInset = newValue
        }
    }

    public var horizontalInset: CGFloat = 24 {
        didSet {
            leadingInsetConstraint.constant = horizontalInset
            trailingInsetConstraint.constant = -horizontalInset
            layoutIfNeeded()
        }
    }

    private var leadingInsetConstraint: NSLayoutConstraint!
    private var trailingInsetConstraint: NSLayoutConstraint!

    private let textFieldView: TextFieldView = .init()

    // MARK: - Lifecycle

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        selectionStyle = .none
        contentView.addSubview(textFieldView)
        leadingInsetConstraint = textFieldView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: 24
        )
        trailingInsetConstraint = textFieldView.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: -24
        )
        NSLayoutConstraint.activate([leadingInsetConstraint, trailingInsetConstraint])

        textFieldView.layoutToSuperview(.top)
        textFieldView.layoutToSuperview(.bottom, offset: -16)
        textFieldView.layout(dimension: .height, to: 80, priority: .defaultLow)
    }

    public func setup(
        viewModel: TextFieldViewModel,
        keyboardInteractionController: KeyboardInteractionController,
        scrollView: UIScrollView
    ) {
        textFieldView.setup(
            viewModel: viewModel,
            keyboardInteractionController: keyboardInteractionController,
            scrollView: scrollView
        )
    }
}
