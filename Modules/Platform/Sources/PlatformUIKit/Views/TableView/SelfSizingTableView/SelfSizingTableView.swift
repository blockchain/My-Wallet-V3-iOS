// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/**
 Simple `UITableView` that sizes itself.
 Handy if your `UITableView` is in a containerView or a `UIStackView`.

 - See Also: [SelfSizingTableView Behaviour](x-source-tag://SelfSizingTableView.Behaviour).
 */
public final class SelfSizingTableView: UITableView {

    // MARK: Static Private Properties

    private static let screenHeight = UIScreen.main.bounds.size.height

    // MARK: Types

    /**
     `SelfSizingTableView` has two behaviours:
     - `compact` means it will always try to not exceed the set maximum size (previously default behaviour), this is used when showing a table view form anchored to the bottom of the screen and it must be compacted to it's minimum content size.
     - `fill` means it will always return at least a size that fills the screen with content, this is useful if you want to attach another view outside the bottom of the tableview, and it must be on the bottom of the screen even if the tableview has short content.
     - Tag: `SelfSizingTableView.Behaviour`
     */
    public enum Behaviour {
        case compact
        case fill
    }

    // MARK: Public Properties

    /// Default to the main `UIScreen` bounds height. Set this to maximum height `SelfSizingTableView` could be.
    public var availableHeight: CGFloat = SelfSizingTableView.screenHeight {
        didSet {
            if availableHeight != oldValue {
                invalidateIntrinsicContentSize()
            }
        }
    }

    /// Default to `0`. This value is subtractd from `availableHeight` when calculating the final desired height for it's `intrinsicContentSize` .
    public var unavailableHeight: CGFloat = 0 {
        didSet {
            if unavailableHeight != oldValue {
                invalidateIntrinsicContentSize()
            }
        }
    }

    public var selfSizingBehaviour: Behaviour = .compact

    override public var intrinsicContentSize: CGSize {
        CGSize(
            width: contentSize.width,
            height: desiredHeight
        )
    }

    // MARK: Private Properties

    private let _contentSizeDisposeBag = DisposeBag()

    private var desiredHeight: CGFloat {
        switch selfSizingBehaviour {
        case .compact:
            compactDesiredHeight
        case .fill:
            fillDesiredHeight
        }
    }

    private var fillDesiredHeight: CGFloat {
        let max = (availableHeight - unavailableHeight)
        if contentSize.height < max {
            return max
        } else {
            return contentSize.height
        }
    }

    private var compactDesiredHeight: CGFloat {
        min(contentSize.height, availableHeight - unavailableHeight)
    }

    // MARK: Setup

    override public init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupContentSize()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContentSize()
    }

    private func setupContentSize() {
        rx
            .observe(CGSize.self, "contentSize")
            .distinctUntilChanged()
            .subscribe { [weak self] event in
                switch event {
                case .completed,
                     .error:
                    break
                case .next:
                    self?.invalidateIntrinsicContentSize()
                }
            }
            .disposed(by: _contentSizeDisposeBag)
    }
}
