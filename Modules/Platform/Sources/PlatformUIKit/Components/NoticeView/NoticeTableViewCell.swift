// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI
import UIComponentsKit
import UIKit

public final class NoticeTableViewCell: UITableViewCell {

    // MARK: - Properties

    public var viewModel: NoticeViewModel! {
        didSet {
            noticeView.viewModel = viewModel
        }
    }

    public var topOffset: CGFloat = 16 {
        didSet {
            verticalConstraints.leading.constant = topOffset
        }
    }

    public var bottomOffset: CGFloat = 16 {
        didSet {
            verticalConstraints.trailing.constant = -bottomOffset
        }
    }

    private let noticeView = NoticeView()
    private var verticalConstraints: Axis.Constraints!

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(noticeView)
        noticeView.layoutToSuperview(axis: .horizontal, offset: 24)
        self.verticalConstraints = noticeView.layoutToSuperview(
            axis: .vertical,
            offset: topOffset
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct NoticeTableViewCellContainer: UIViewRepresentable {
    typealias UIViewType = NoticeTableViewCell

    func makeUIView(context: Context) -> UIViewType {
        let view = NoticeTableViewCell()
        let image = ImageViewContent(
            imageResource: .local(name: "icon-disclosure-down-small", bundle: .platformUIKit)
        )
        view.viewModel = NoticeViewModel(
            imageViewContent: image,
            imageViewSize: .edge(40),
            labelContents: [
                LabelContent(
                    text: "UniSwap Dapp",
                    font: .main(.semibold, 16),
                    color: .darkTitleText
                ),
                LabelContent(
                    text: "https://app.uniswap.org",
                    font: .main(.medium, 12),
                    color: .descriptionText
                )
            ],
            verticalAlignment: .center
        )
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct NoticeTableViewCellContainer_Previews: PreviewProvider {
    static var previews: some View {
        NoticeTableViewCellContainer()
            .previewLayout(.fixed(width: 375, height: 100))
    }
}
#endif
