// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

struct ClipboardCellViewModel {
    let title: String
    let accessibilityID: String

    init(title: String, accessibilityID: String) {
        self.title = title
        self.accessibilityID = accessibilityID
    }
}

final class ClipboardTableViewCell: UITableViewCell {

    // MARK: - Model

    typealias ViewModel = ClipboardCellViewModel

    var viewModel: ViewModel! {
        didSet {
            titleLabel.text = viewModel.title
            titleLabel.accessibility = .id(viewModel.accessibilityID)
        }
    }

    // MARK: - Private IBOutlets

    @IBOutlet private var titleLabel: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .semantic.background
        titleLabel.textColor = .semantic.title
    }
}
