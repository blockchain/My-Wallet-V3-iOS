//
//  HorizontalContainerCell.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 1/7/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// HorizontalContainerCell is the base class that is used to present nested collection
/// view content that scrolls horizontally.
public class HorizontalContainerCell: NestedCollectionViewCell, Container {
    
    // MARK: Public IBOutlets
    
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    @IBOutlet var trailingConstraint: NSLayoutConstraint!
    @IBOutlet var title: UILabel!
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var collectionViewTop: NSLayoutConstraint!
    
    // MARK: Public Properties
    
    weak var delegate: ContainerDelegate?
    var cellModel: StandardContainerModel!
    
    // MARK: Private Static Constants
    
    fileprivate static let titleToCollectionView: CGFloat = 16.0
    fileprivate static let titleVerticalPadding: CGFloat = 16.0
    fileprivate static let titleHorizontalPadding: CGFloat = 16
    fileprivate static let collectionViewToBottom: CGFloat = 4.0
    fileprivate static let verticalPadding: CGFloat = 20.0
    
    // MARK: Internal Properties
    
    internal var layoutAttributes: LayoutAttributes = .horizontal
    internal var reuseIdentifiers: Set<String> = []
    
    // MARK: Lifecycle
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = nil
        collectionView.showsVerticalScrollIndicator = false
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        collectionViewTop.constant = title.text == nil ? 0 : HorizontalContainerCell.titleToCollectionView
        setupLayoutAttributes()
        
        if needsReloadOnNextLayout {
            needsReloadOnNextLayout = false
            collectionView.reloadData()
        }
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        cellModel = nil
        collectionView.reloadData()
    }
    
    // MARK: Overrides
    
    override public class func heightForProposedWidth(_ width: CGFloat, containerModel: ContainerModel) -> CGFloat {
        guard case .standard(let model) = containerModel else { return 0.0 }
        
        let attributes: LayoutAttributes = .horizontal
        let columns : CGFloat = model.layout.columns
        
        let availableWidth = width
        let totalItemSpacing = (columns - 1) * attributes.minimumInterItemSpacing
        let itemWidth = ((availableWidth - totalItemSpacing) / columns).rounded()
        
        var titleHeight: CGFloat = 0
        var titleToCollection : CGFloat = 0
        
        let detailWidth = titleHorizontalPadding
        
        let availableTitleWidth = width - titleHorizontalPadding - detailWidth
        
        if let title = model.title {
            titleHeight = NSAttributedString(string: title, attributes: [.font: BaseCell.sectionTitleFont()]).heightForWidth(width: availableTitleWidth)
            titleToCollection = titleToCollectionView
        }
        
        let collectionViewHeight = maxCellHeight(model.cells, width: itemWidth)
        let verticalPadding: CGFloat = titleVerticalPadding
        
        return verticalPadding + titleHeight + titleToCollection + collectionViewHeight + collectionViewToBottom
    }
    
    override func applyAccessibility() {
        isAccessibilityElement = false
        shouldGroupAccessibilityChildren = true
        title.accessibilityLabel = title.text
        title.accessibilityTraits = .header
    }
    
    // MARK: Class Methods
    
    class func maxCellHeight(_ cells: [CellModel], width: CGFloat) -> CGFloat {
        var maxCellHeight: CGFloat = 0
        
        cells.forEach { cell in
            let cellType = cell.cellType()
            let height = cellType.heightForProposedWidth(width, model: cell)
            
            if height > maxCellHeight {
                maxCellHeight = height
            }
        }
        
        return floor(maxCellHeight)
    }
    
    // MARK: Public Methods
    
    override public func configure(_ model: ContainerModel) {
        guard case .standard(let containerModel) = model else { return }
        
        cellModel = containerModel
        collectionView.backgroundColor = containerModel.backgroundColor
        title.text = containerModel.title
        
        containerModel.cells.forEach { cell in
            let reuse = cell.reuseIdentifier()
            
            if !reuseIdentifiers.contains(reuse) {
                let nib = UINib(nibName: reuse, bundle: Bundle(for: cell.cellType()))
                collectionView.register(nib, forCellWithReuseIdentifier: reuse)
                reuseIdentifiers.insert(reuse)
            }
        }
    }
    
    open func setupLayoutAttributes() {
        guard let layout = layout else { return }
        layout.sectionInset = layoutAttributes.sectionInsets
        layout.minimumLineSpacing = layoutAttributes.minimumLineSpacing
        layout.minimumInteritemSpacing = layoutAttributes.minimumInterItemSpacing
        
        leadingConstraint.constant = layoutAttributes.sectionInsets.left
    }
}

extension HorizontalContainerCell: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = cellModel.cells[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: item.reuseIdentifier(),
            for: indexPath) as? BaseCell else {
                return UICollectionViewCell()
        }
        
        item.configure(cell)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModel.cells.count
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension HorizontalContainerCell: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        let columns = cellModel.layout.columns
        let availableWidth = bounds.width
        let totalItemSpacing = (columns - 1) * layoutAttributes.minimumInterItemSpacing
        let cellWidth = (availableWidth - totalItemSpacing) / columns
        let cellHeight = HorizontalContainerCell.maxCellHeight(cellModel.cells, width: cellWidth)
        
        return CGSize(
            width: cellWidth.rounded(),
            height: cellHeight.rounded()
        )
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.container(self, didSelectItemAt: indexPath)
    }
}
