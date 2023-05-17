// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary

public final class ExplainedActionTableViewCell: UITableViewCell {

    // MARK: - Injected

    public var viewModel: ExplainedActionViewModel! {
        didSet {
            explainedActionView.viewModel = viewModel
        }
    }

    // MARK: - UI Properties

    private let explainedActionView = ExplainedActionView()
    private let separatorView = UIView()

    // MARK: - Setup

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .semantic.background
        contentView.addSubview(explainedActionView)
        contentView.addSubview(separatorView)
        explainedActionView.layoutToSuperview(.leading, .trailing, .top)
        explainedActionView.layout(edge: .bottom, to: .top, of: separatorView)
        separatorView.backgroundColor = .semantic.light
        separatorView.layoutToSuperview(.leading, .trailing, .bottom)
        separatorView.layout(dimension: .height, to: 1)
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
