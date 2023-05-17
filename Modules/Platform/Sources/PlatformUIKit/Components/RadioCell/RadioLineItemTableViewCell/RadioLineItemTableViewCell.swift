// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import RxSwift

public final class RadioLineItemTableViewCell: UITableViewCell {

    // MARK: - Public Properties

    public var presenter: RadioLineItemCellPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter else { return }

            presenter
                .image
                .drive(radioView.rx.image)
                .disposed(by: disposeBag)

            presenter
                .isSeparatorHidden
                .drive(separatorView.rx.isHidden)
                .disposed(by: disposeBag)

            presenter
                .viewModel
                .drive(lineItemView.rx.rx_viewModel)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()
    private let lineItemView = LineItemView()
    private let radioView = UIImageView()
    private let separatorView = UIView()

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
        presenter = nil
    }

    private func setup() {
        selectionStyle = .none
        contentView.addSubview(lineItemView)
        contentView.addSubview(radioView)
        contentView.addSubview(separatorView)
        separatorView.layoutToSuperview(.leading, .trailing, .bottom)
        separatorView.layout(dimension: .height, to: 1.0)
        separatorView.backgroundColor = .semantic.light
        lineItemView.layout(to: .centerY, of: contentView)
        lineItemView.layoutToSuperview(.top, offset: 16.0)
        lineItemView.layoutToSuperview(.leading, offset: 24.0)
        lineItemView.layout(edge: .trailing, to: .leading, of: radioView, offset: -16.0)
        radioView.layout(size: .edge(24.0))
        radioView.layout(to: .centerY, of: contentView)
        radioView.layoutToSuperview(.trailing, offset: -24.0)
    }
}
