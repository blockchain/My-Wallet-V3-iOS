// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI
import UIComponentsKit
import UIKit

public final class NoticeView: UIView {

    // MARK: - IBOutlet Properties

    private let imageView = UIImageView()
    private let stackView = UIStackView()

    private var topAlignmentConstraint: NSLayoutConstraint!
    private var centerAlignmentConstraint: NSLayoutConstraint!
    private var sizeConstraints: LayoutForm.Constraints!

    // MARK: - Injected

    public var viewModel: NoticeViewModel! {
        didSet {
            guard let viewModel else { return }
            imageView.set(viewModel.imageViewContent)
            sizeConstraints.setConstant(
                horizontal: viewModel.imageViewSize.width,
                vertical: viewModel.imageViewSize.height
            )
            stackView.removeSubviews()

            viewModel.labelContents
                .map {
                    let label = UILabel()
                    label.content = $0
                    label.numberOfLines = 0
                    return label
                }
                .forEach {
                    stackView.addArrangedSubview($0)
                }

            switch viewModel.verticalAlignment {
            case .center:
                topAlignmentConstraint.priority = .defaultLow
                centerAlignmentConstraint.priority = .penultimateHigh
            case .top:
                topAlignmentConstraint.priority = .penultimateHigh
                centerAlignmentConstraint.priority = .defaultLow
            }
            layoutIfNeeded()
        }
    }

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
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 4

        imageView.contentMode = .scaleAspectFit

        addSubview(imageView)
        addSubview(stackView)

        imageView.layoutToSuperview(.leading)
        sizeConstraints = imageView.layout(size: .init(edge: 20))

        topAlignmentConstraint = imageView.layout(to: .top, of: stackView, priority: .penultimateHigh)
        centerAlignmentConstraint = imageView.layout(to: .centerY, of: stackView, priority: .defaultLow)

        stackView.layout(edge: .leading, to: .trailing, of: imageView, offset: 18)
        stackView.layoutToSuperview(axis: .vertical, priority: .penultimateHigh)
        stackView.layoutToSuperview(.trailing)
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct NoticeViewContainer: UIViewRepresentable {
    typealias UIViewType = NoticeView

    func makeUIView(context: Context) -> UIViewType {
        let view = NoticeView()
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
                    font: .main(.medium, 16),
                    color: .descriptionText
                )
            ],
            verticalAlignment: .center
        )
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct NoticeViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NoticeViewContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 400, height: 50))
    }
}
#endif
