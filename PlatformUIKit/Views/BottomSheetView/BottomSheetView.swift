//
//  BottomSheetView.swift
//  PlatformUIKit
//
//  Created by AlexM on 2/22/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public class BottomSheetView: UIView {
    
    // MARK: Private Static Properties
    
    fileprivate static let actionInterItemSpacing: CGFloat = 16.0
    fileprivate static let verticalPadding: CGFloat = 97.0
    fileprivate static let actionHeight: CGFloat = 56.0
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var closeButton: UIButton!
    @IBOutlet fileprivate var title: UILabel!
    @IBOutlet fileprivate var stackView: UIStackView!
    
    // MARK: Private Properties
    
    fileprivate var model: BottomSheet!
    fileprivate var completion: ((BottomSheetAction) -> Void)?
    
    public class func make(with model: BottomSheet, completion: ((BottomSheetAction) -> Void)?) -> BottomSheetView {
        let bundle = Bundle(for: BottomSheetView.self)
        let nib = UINib(nibName: String(describing: BottomSheetView.self), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! BottomSheetView
        view.model = model
        view.completion = completion
        return view
    }
    
    public class func estimatedHeight(model: BottomSheet) -> CGFloat {
        guard let window = UIApplication.shared.keyWindow else { return 0.0 }
        
        let buttonsHeight = model.actions.map { _ -> CGFloat in
            return actionHeight
        }.reduce(0, +)
        let interitemPadding = ((buttonsHeight / actionHeight) - 1) * actionInterItemSpacing
        
        let titleHeight = NSAttributedString(string: model.title, attributes: [.font: titleFont()]).height
        
        if #available(iOS 11.0, *) {
            return verticalPadding + interitemPadding + buttonsHeight + titleHeight + window.safeAreaInsets.bottom
        } else {
            return verticalPadding + interitemPadding + buttonsHeight + titleHeight
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        apply(model: model)
        applyRadius(12.0, to: [.topLeft, .topRight])
    }
    
    @objc func dismiss() {
        guard model.dismissable == true else { return }
        teardown()
    }
    
    @objc func selectionTapped(_ sender: UIButton) {
        guard let model = model else { return }
        if let index = stackView.arrangedSubviews.index(of: sender) {
            let action = model.actions[index]
            teardown(with: action)
        }
    }
    
    fileprivate static func titleFont() -> UIFont {
        return Font(.branded(.montserratSemiBold), size: .custom(16.0)).result
    }
    
    fileprivate func apply(model: BottomSheet) {
        guard stackView.arrangedSubviews.count == 0 else { return }
        
        title.text = model.title
        closeButton.setTitle(model.dismissalTitle, for: .normal)
        model.actions.forEach { sheetAction in
            let button = BaseUIButtonFill(
                frame: CGRect(
                    origin: .zero,
                    size: .init(
                        width: stackView.frame.width,
                        height: BottomSheetView.actionHeight
                    )
                )
            )
            button.heightAnchor.constraint(equalToConstant: BottomSheetView.actionHeight).isActive = true
            button.cornerRadius = 4.0
            button.setTitle(sheetAction.title, for: .normal)
            button.addTarget(self, action: #selector(selectionTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }
    
    fileprivate func teardown(with selectedAction: BottomSheetAction? = nil) {
        UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.1, animations: {
                self.alpha = 0.0
            })
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.2, animations: {
                self.dimmingView.alpha = 0.0
                self.frame = self.frame.offsetBy(dx: 0.0, dy: self.bounds.height)
            })
        }, completion: { [weak self] _ in
            guard let this = self else { return }
            this.dimmingView.removeFromSuperview()
            this.removeFromSuperview()
            if let action = selectedAction {
                this.completion?(action)
            }
        })
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        teardown()
    }
    
    // MARK: Public
    
    public func show() {
        guard let window = UIApplication.shared.keyWindow else { return }
        alpha = 0.0
        let width = window.bounds.width
        let height = BottomSheetView.estimatedHeight(model: model)
        let start = CGPoint(
            x: window.bounds.midX - (width / 2.0),
            y: window.bounds.maxY
        )
        frame = CGRect(
            origin: start,
            size: .init(
                width: width,
                height: height
            )
        )
        window.addSubview(dimmingView)
        window.addSubview(self)
        
        UIView.animateKeyframes(withDuration: 0.4, delay: 0.0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1, animations: {
                self.dimmingView.alpha = 0.4
            })
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.2, animations: {
                self.alpha = 1.0
                self.frame.origin = CGPoint(
                    x: self.frame.origin.x,
                    y: window.frame.maxY - height
                )
            })
        }, completion: nil)
    }
    
    fileprivate lazy var dimmingView: UIView = {
        let dimming = UIView(frame: UIScreen.main.bounds)
        dimming.backgroundColor = .black
        dimming.alpha = 0.0
        dimming.isAccessibilityElement = true
        dimming.accessibilityTraits = UIAccessibilityTraits.button
        dimming.accessibilityHint = NSLocalizedString(
            "Double tap to close",
            comment: "Dimmed background behind a modal alert. Double tap to close."
        )
        dimming.isUserInteractionEnabled = true
        dimming.addGestureRecognizer(dismissTapGesture)
        return dimming
    }()
    
    fileprivate lazy var dismissTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        return tap
    }()
}
