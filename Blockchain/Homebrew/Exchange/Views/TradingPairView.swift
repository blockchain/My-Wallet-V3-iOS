//
//  TradingPairView.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

protocol TradingPairViewDelegate: class {
    func onLeftButtonTapped(_ view: TradingPairView, title: String)
    func onRightButtonTapped(_ view: TradingPairView, title: String)
    func onSwapButtonTapped(_ view: TradingPairView)
}

class TradingPairView: NibBasedView {
    
    typealias TradingTransitionUpdate = TransitionPresentationUpdate<ViewTransition>
    typealias TradingPresentationUpdate = AnimatablePresentationUpdate<ViewUpdate>
    
    enum ViewUpdate: Update {
        case statusTintColor(UIColor)
        case leftStatusVisibility(Visibility)
        case rightStatusVisibility(Visibility)
        case backgroundColors(left: UIColor, right: UIColor)
        case swapTintColor(UIColor)
    }
    
    enum ViewTransition: Transition {
        case swapImage(UIImage)
        case images(left: UIImage?, right: UIImage?)
        case titles(left: String, right: String)
    }
    
    // MARK: IBOutlets
    
    @IBOutlet fileprivate var leftButton: UIButton!
    @IBOutlet fileprivate var rightButton: UIButton!
    @IBOutlet fileprivate var swapButton: UIButton!
    @IBOutlet fileprivate var leftIconStatusImageView: UIImageView!
    @IBOutlet fileprivate var rightIconStatusImageView: UIImageView!
    @IBOutlet fileprivate var exchangeLabel: UILabel!
    @IBOutlet fileprivate var receiveLabel: UILabel!
    
    // MARK: Public
    
    weak var delegate: TradingPairViewDelegate?
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        leftButton.layer.cornerRadius = 4.0
        rightButton.layer.cornerRadius = 4.0
    }
    
    // MARK: Actions
    
    @IBAction func leftButtonTapped(_ sender: UIButton) {
        delegate?.onLeftButtonTapped(self, title: sender.titleLabel?.text ?? "")
    }
    
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        delegate?.onRightButtonTapped(self, title: sender.titleLabel?.text ?? "")
    }
    
    @IBAction func swapButtonTapped(_ sender: UIButton) {
        delegate?.onSwapButtonTapped(self)
    }
    
    // MARK: Public
    
    func apply(pair: TradingPair, animation: AnimationParameter = .none, transition: TransitionParameter = .none) {
        let presentationUpdate = TradingPresentationUpdate(
            animations: [
                .backgroundColors(left: pair.from.brandColor, right: pair.to.brandColor),
                .statusTintColor(.green),
                .swapTintColor(.grayBlue),
                .rightStatusVisibility(.visible),
                .leftStatusVisibility(.hidden)
            ],
            animation: animation
        )
        
        let transitionUpdate = TradingTransitionUpdate(
            transitions: [
                .images(left: pair.from.brandImage, right: pair.to.brandImage),
                .titles(left: pair.from.description, right: pair.to.description),
                .swapImage(#imageLiteral(resourceName: "Icon-Exchange").withRenderingMode(.alwaysTemplate))
            ],
            transition: transition
        )
        
        apply(presentationUpdate: presentationUpdate)
        apply(transitionUpdate: transitionUpdate)
    }
    
    func apply(presentationUpdate: TradingPresentationUpdate) {
        presentationUpdate.animationType.perform { [weak self] in
            guard let this = self else { return }
            presentationUpdate.animations.forEach({this.handle($0)})
        }
    }
    
    func apply(transitionUpdate: TradingTransitionUpdate) {
        transitionUpdate.transitionType.perform(with: self) { [weak self] in
            guard let this = self else { return }
            transitionUpdate.transitions.forEach({this.handle($0)})
        }
    }
    
    // MARK: Private
    
    fileprivate func handle(_ update: ViewUpdate) {
        switch update {
        case .statusTintColor(let color):
            rightIconStatusImageView.tintColor = color
            leftIconStatusImageView.tintColor = color
            
        case .rightStatusVisibility(let visibility):
            rightIconStatusImageView.alpha = visibility.defaultAlpha
            
        case .leftStatusVisibility(let visibility):
            leftIconStatusImageView.alpha = visibility.defaultAlpha
            
        case .backgroundColors(left: let leftColor, right: let rightColor):
            leftButton.backgroundColor = leftColor
            rightButton.backgroundColor = rightColor
            
        case .swapTintColor(let color):
            swapButton.tintColor = color
        }
    }
    
    func handle(_ transition: ViewTransition) {
        switch transition {
        case .swapImage(let image):
            swapButton.setImage(image, for: .normal)
            
        case .images(left: let leftImage, right: let rightImage):
            rightButton.setImage(rightImage, for: .normal)
            leftButton.setImage(leftImage, for: .normal)
            
        case .titles(left: let leftTitle, right: let rightTitle):
            leftButton.setTitle(leftTitle, for: .normal)
            rightButton.setTitle(rightTitle, for: .normal)
        }
    }
}
