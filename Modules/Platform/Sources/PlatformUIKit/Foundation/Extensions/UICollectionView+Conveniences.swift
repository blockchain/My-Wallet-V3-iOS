// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension UICollectionView {

    public func register(_ cellType: UICollectionViewCell.Type) {
        register(cellType, forCellWithReuseIdentifier: cellType.objectName)
    }

    public func registerNibCell(_ type: UICollectionViewCell.Type, in bundle: Bundle) {
        let name = type.objectName
        register(UINib(nibName: name, bundle: bundle), forCellWithReuseIdentifier: name)
    }

    public func dequeue<CellType: UICollectionViewCell>(_ type: CellType.Type, for indexPath: IndexPath) -> CellType {
        dequeueReusableCell(withReuseIdentifier: type.objectName, for: indexPath) as! CellType
    }
}
