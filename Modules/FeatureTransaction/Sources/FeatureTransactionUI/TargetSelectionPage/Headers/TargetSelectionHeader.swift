// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum TargetSelectionHeader: Equatable {
    case none
    case section(String)

    var defaultHeight: CGFloat {
        switch self {
        case .none:
            return 0
        case .section:
            return 32
        }
    }

    func view(fittingWidth width: CGFloat) -> UIView? {
        let frame = CGRect(x: 0, y: 0, width: width, height: defaultHeight)
        switch self {
        case .none:
            return nil
        case .section(let value):
            let headerView = TargetSelectionHeaderView(frame: frame)
            headerView.model = value
            return headerView
        }
    }
}
