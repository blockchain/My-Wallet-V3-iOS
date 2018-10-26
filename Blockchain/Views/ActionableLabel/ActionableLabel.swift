//
//  ActionableLabel.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol ActionableLabelDelegate: class {
    
    /// This returns the range of the call to action text
    /// Users must tap within this range in order to trigger
    /// the delegate call back inidicating the CTA was tapped.
    func targetRange(_ label: ActionableLabel) -> NSRange?
    
    func actionRequestingExecution(label: ActionableLabel)
}

class ActionableLabel: UILabel {
    
    // MARK: Public Properties
    
    weak var delegate: ActionableLabelDelegate?
    
    fileprivate var tapGesture: UITapGestureRecognizer!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    fileprivate func commonInit() {
        isUserInteractionEnabled = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(action(_:)))
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: Touch Handling
    
    @objc fileprivate func action(_ tapGesture: UITapGestureRecognizer) {
        let location = tapGesture.location(in: self)
        guard let range = delegate?.targetRange(self) else { return }
        if didTap(inRange: range, location: location) {
            delegate?.actionRequestingExecution(label: self)
        }
    }
}

// MARK: Actionable Helpers

fileprivate extension ActionableLabel {
    
    func didTap(inRange targetRange: NSRange, location: CGPoint) -> Bool {
        guard let text = attributedText else { return false }
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
        let textStorage = NSTextStorage(attributedString: text)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        
        let index = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: .none)
        
        return NSLocationInRange(index, targetRange)
    }
    
}
