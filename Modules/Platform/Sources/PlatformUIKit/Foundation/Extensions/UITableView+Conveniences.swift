// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import UIKit

extension UITableView {

    // MARK: - Register header / footer

    public func register(_ headerType: (some UITableViewHeaderFooterView).Type) {
        register(headerType, forHeaderFooterViewReuseIdentifier: headerType.objectName)
    }

    // MARK: - Register cell type

    public func register(_ cellType: (some UITableViewCell).Type) {
        register(cellType, forCellReuseIdentifier: cellType.objectName)
    }

    public func register(_ cellTypes: [(some UITableViewCell).Type]) {
        for type in cellTypes {
            register(type, forCellReuseIdentifier: type.objectName)
        }
    }

    // MARK: - Register cell name

    public func registerHeaderView(_ name: String, bundle: Bundle = .main) {
        register(UINib(nibName: name, bundle: bundle), forHeaderFooterViewReuseIdentifier: name)
    }

    public func registerNibCell(_ type: UITableViewCell.Type, in bundle: Bundle) {
        let name = type.objectName
        register(UINib(nibName: name, bundle: bundle), forCellReuseIdentifier: name)
    }

    // MARK: - Dequeue accessors

    public func dequeue<CellType: UITableViewCell>(_ type: CellType.Type, for indexPath: IndexPath) -> CellType {
        dequeueReusableCell(withIdentifier: type.objectName, for: indexPath) as! CellType
    }

    public func dequeue<HeaderType: UITableViewHeaderFooterView>(_ type: HeaderType.Type) -> HeaderType {
        dequeueReusableHeaderFooterView(withIdentifier: type.objectName) as! HeaderType
    }
}
