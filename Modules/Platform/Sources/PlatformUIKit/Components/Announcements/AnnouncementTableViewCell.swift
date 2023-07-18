// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class AnnouncementTableViewCell: UITableViewCell {

    // MARK: - Lifecycle

    /// Set custom spacing
    public var bottomSpacing: CGFloat {
        get { -bottomSpacingConstraint.constant }
        set { bottomSpacingConstraint.constant = -newValue }
    }

    private var bottomSpacingConstraint: NSLayoutConstraint!

    /// A view that represents the announcement
    private var cardView: AnnouncementCardView!

    public var viewModel: AnnouncementCardViewModel! {
        didSet {
            guard let viewModel else { return }
            cardView = AnnouncementCardView(using: viewModel)
            contentView.addSubview(cardView)
            cardView.layoutToSuperview(.top, .leading, .trailing)
            bottomSpacingConstraint = cardView.layoutToSuperview(.bottom)
        }
    }

    // MARK: - Lifecycle

    override public func prepareForReuse() {
        super.prepareForReuse()
        cardView?.removeFromSuperview()
        cardView = nil
        viewModel = nil
    }
}
