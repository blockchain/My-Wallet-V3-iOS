// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import UIKit

public final class TermsTableViewCell: UITableViewCell {

    private let textView = UITextView(frame: .zero)
    private var readMoreButtonTitle = ""
    private lazy var readMoreButton: UIView = { [weak self] in
        guard let self else { return .init() }
        let button = SmallMinimalButton(
            title: .init(
                get: { self.readMoreButtonTitle },
                set: { value in self.readMoreButtonTitle = value }
            )
        ) {
            self.readMore()
        }
        let buttonView = UIHostingController(rootView: button)
        return buttonView.view ?? .init()
    }()

    public var viewModel: TermsViewCellModel! {
        willSet {}
        didSet {
            guard let viewModel else {
                return
            }
            let disclaimerText = NSMutableAttributedString(attributedString: viewModel.text ?? .init(string: ""))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            disclaimerText.addAttributes(
                [
                    .font: UIFont.main(.medium, 12),
                    .paragraphStyle: paragraphStyle,
                    .foregroundColor: UIColor.semantic.text
                ],
                range: NSRange(location: 0, length: disclaimerText.length)
            )
            textView.attributedText = disclaimerText
            textView.textAlignment = .left
            textView.sizeToFit()
            readMoreButtonTitle = viewModel.readMoreButtonTitle
        }
    }

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
        contentView.addSubview(textView)
        contentView.addSubview(readMoreButton)
        selectionStyle = .none
        textView.isScrollEnabled = false
        textView.isSelectable = true
        textView.isEditable = false
        textView.textAlignment = .left
        textView.sizeToFit()

        textView.layout(edges: .top, to: contentView, offset: 16)
        textView.layout(edge: .leading, to: .leading, of: contentView, offset: 19)
        textView.layout(edge: .trailing, to: .trailing, of: contentView, offset: -19)

        readMoreButton.layout(edge: .top, to: .bottom, of: textView, offset: 8)
        readMoreButton.layout(edge: .leading, to: .leading, of: contentView, offset: 21)
        readMoreButton.layout(edge: .bottom, to: .bottom, of: contentView, offset: -16)
    }

    private func readMore() {
        viewModel.tapPublishRelay.accept(viewModel.detailsDescription)
    }
}
