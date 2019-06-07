//
//  PaginatedContainerCell.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 1/22/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// `PaginatedContainerCell` is a special case of `NestedCollectionViewCell` that only supports
/// a `UICollectionView` with paging enabled. Much of the inner workings are similar to
/// `HorizontalContainerCell` but `HorizontalContainerCell` takes a `StandardContainerModel`
/// which should be reserved for only `.horizontal` and `.vertical` layout types.
/// `PaginatedContainerCell` only shows a single column and shouldn't show more than a single column.
/// If we need to show additional columns to enable "peaking", use `HorizontalContainerCell`. If it needs
/// to be a paginated cell as well as showing multiple columns, then a new `Container` should be made.
public class PaginatedContainerCell: NestedCollectionViewCell, Container {
    
    // MARK: Private Static Constants
    
    fileprivate static let titleToCollectionView: CGFloat = 16.0
    fileprivate static let titleVerticalPadding: CGFloat = 16.0
    fileprivate static let titleHorizontalPadding: CGFloat = 16.0
    fileprivate static let pageControlHeight: CGFloat = 37.0
    fileprivate static let verticalPadding: CGFloat = 20.0
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var leadingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var trailingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var collectionViewTop: NSLayoutConstraint!
    @IBOutlet fileprivate var title: UILabel!
    @IBOutlet fileprivate var pageControl: UIPageControl!
    
    // MARK: Public Properties
    
    weak var delegate: ContainerDelegate?
    var cellModel: PaginatedContainerModel!
    
    // MARK: Internal Properties
    
    internal var layoutAttributes: LayoutAttributes = .outer
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
        
        collectionViewTop.constant = title.text == nil ? 0 : PaginatedContainerCell.titleToCollectionView
        setupLayoutAttributes()
        
        if needsReloadOnNextLayout {
            needsReloadOnNextLayout = false
            collectionView.reloadData()
        }
    }
    
    func setupLayoutAttributes() {
        guard let layout = layout else { return }
        layout.sectionInset = layoutAttributes.sectionInsets
        layout.minimumLineSpacing = layoutAttributes.minimumLineSpacing
        layout.minimumInteritemSpacing = layoutAttributes.minimumInterItemSpacing
        
        leadingConstraint.constant = layoutAttributes.sectionInsets.left
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        cellModel = nil
        collectionView.reloadData()
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
    
    // MARK: Overrides
    
    override public func configure(_ model: ContainerModel) {
        guard case .paginated(let containerModel) = model else { return }
        cellModel = containerModel
        pageControl.numberOfPages = containerModel.cells.count
        pageControl.tintColor = containerModel.pageControlColor ?? .white
        pageControl.currentPageIndicatorTintColor = containerModel.currentPageTintColor ?? #colorLiteral(red: 0, green: 0.2901960784, blue: 0.4862745098, alpha: 1)
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
    
    // MARK: Overrides
    
    override public class func heightForProposedWidth(_ width: CGFloat, containerModel: ContainerModel) -> CGFloat {
        guard case .paginated(let model) = containerModel else { return 0.0 }
        
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
        
        return verticalPadding + titleHeight + titleToCollection + collectionViewHeight + pageControlHeight
    }
}

extension PaginatedContainerCell: UICollectionViewDataSource {
    
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

extension PaginatedContainerCell: UICollectionViewDelegateFlowLayout {
    
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

// MARK: UIScrollViewDelegate

extension PaginatedContainerCell {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(collectionView.contentOffset.x / collectionView.frame.size.width)
        pageControl.currentPage = index
    }
    
    // This makes scrolling a bit more sticky
    public func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let visible = collectionView.visibleCells.first {
            let insets: CGFloat = layout.sectionInset.left
            let point = CGPoint(x: targetContentOffset.pointee.x + insets, y: visible.frame.origin.y)
            
            guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
            guard let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath) else { return }
            if point.x > layoutAttributes.frame.origin.x + layoutAttributes.frame.width / 2 {
                let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
                if let layoutAttributes = collectionView.layoutAttributesForItem(at: nextIndexPath) {
                    targetContentOffset.pointee.x = layoutAttributes.frame.origin.x - insets
                }
            } else {
                targetContentOffset.pointee.x = layoutAttributes.frame.origin.x - insets
            }
        }
    }
}
