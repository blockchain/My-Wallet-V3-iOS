// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public final class CheckboxTableViewCell: UITableViewCell {

    // MARK: - Public Properties

    public var viewModel: CheckboxViewModel! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let viewModel else { return }

            viewModel
                .textViewViewModel
                .drive(interactableTextView.rx.viewModel)
                .disposed(by: disposeBag)

            viewModel
                .image
                .drive(checkboxImageView.rx.image)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()
    private let interactableTextView = InteractableTextView()
    private let checkboxImageView = UIImageView()
    private let button = UIButton()

    // MARK: - Lifecycle

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(checkboxImageView)
        contentView.addSubview(interactableTextView)
        contentView.addSubview(button)
        checkboxImageView.layout(size: .edge(16.0))
        checkboxImageView.layout(edges: .leading, to: contentView, offset: 24)
        checkboxImageView.layout(edges: .top, to: contentView, offset: 24)
        interactableTextView.layout(edges: .top, to: checkboxImageView)
        interactableTextView.layout(edge: .leading, to: .trailing, of: checkboxImageView, offset: 8.0)
        interactableTextView.layout(edge: .trailing, to: .trailing, of: contentView, offset: -24)
        interactableTextView.layout(edge: .bottom, to: .bottom, of: contentView, offset: -16)

        button.layout(size: .edge(24.0))
        button.layout(edges: .centerX, .centerY, to: checkboxImageView)
        button.addTarget(self, action: #selector(toggled(sender:)), for: .touchUpInside)
    }

    @objc func toggled(sender: UIButton) {
        viewModel.selectedRelay.accept(!viewModel.selectedRelay.value)
    }
}
