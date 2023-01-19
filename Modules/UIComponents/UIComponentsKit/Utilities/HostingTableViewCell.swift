// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftUI
import UIKit

public final class HostingTableViewCell<Content: View>: UITableViewCell {
    private var hostingController: UIHostingController<Content?>?
    private var heightConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .lightBorder
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func host(
        _ rootView: Content,
        parent: UIViewController,
        height: CGFloat? = nil,
        insets: UIEdgeInsets = .zero,
        showSeparator: Bool = true,
        backgroundColor: UIColor = .lightBorder
    ) {
        self.backgroundColor = backgroundColor
        contentView.backgroundColor = backgroundColor
        hostingController?.view.removeFromSuperview()
        hostingController?.rootView = nil
        hostingController = .init(rootView: rootView)

        guard let hostingController else {
            return
        }
        hostingController.view.invalidateIntrinsicContentSize()
        let requiresControllerMove = hostingController.parent != parent
        if requiresControllerMove {
            parent.addChild(hostingController)
        }

        if !contentView.subviews.contains(hostingController.view) {
            contentView.addSubview(hostingController.view)
            var insets = insets
            insets.bottom += showSeparator ? 1 : 0
            hostingController.view.constraint(
                edgesTo: contentView,
                insets: insets
            )

            if let height, heightConstraint == nil {
                heightConstraint = contentView.heightAnchor
                    .constraint(equalToConstant: height)
                heightConstraint?.isActive = true
            }
        }

        if requiresControllerMove {
            hostingController.didMove(toParent: parent)
        }
    }

    @discardableResult
    public func updateRootView(height: CGFloat) -> Bool {
        if heightConstraint?.constant == height {
            return false
        }
        if heightConstraint != nil {
            contentView.backgroundColor = height <= 1 ? .clear : .lightBorder
            heightConstraint?.constant = height
            contentView.setNeedsLayout()
        }
        return true
    }
}
