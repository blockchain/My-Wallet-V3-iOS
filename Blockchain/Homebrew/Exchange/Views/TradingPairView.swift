//
//  TradingPairView.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

protocol TradingPairViewDelegate: class {
    func onFromButtonTapped(_ view: TradingPairView)
    func onToButtonTapped(_ view: TradingPairView)
    func onSwapButtonTapped(_ view: TradingPairView)
}

class TradingPairView: NibBasedView {
    
    typealias TradingTransitionUpdate = TransitionPresentationUpdate<ViewTransition>
    typealias TradingPresentationUpdate = AnimatablePresentationUpdate<ViewUpdate>
    
    enum ViewUpdate: Update {
        case statusTintColor(UIColor)
        case statusVisibility(Visibility)
        case backgroundColors(from: UIColor, to: UIColor)
        case swapTintColor(UIColor)
    }
    
    enum ViewTransition: Transition {
        case swapImage(UIImage)
        case images(from: UIImage?, to: UIImage?)
        case titles(from: String, to: String)
    }
    
    // MARK: IBOutlets
    
    @IBOutlet fileprivate var fromButton: UIButton!
    @IBOutlet fileprivate var swapButton: UIButton!
    @IBOutlet fileprivate var toButton: UIButton!
    @IBOutlet fileprivate var iconStatusImageView: UIImageView!
    
    // MARK: Public
    
    weak var delegate: TradingPairViewDelegate?
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        fromButton.layer.cornerRadius = 4.0
        toButton.layer.cornerRadius = 4.0
    }
    
    // MARK: Actions
    
    @IBAction func fromButtonTapped(_ sender: UIButton) {
        delegate?.onFromButtonTapped(self)
    }
    
    @IBAction func toButtonTapped(_ sender: UIButton) {
        delegate?.onToButtonTapped(self)
    }
    
    @IBAction func swapButtonTapped(_ sender: UIButton) {
        delegate?.onSwapButtonTapped(self)
    }
    
    // MARK: Public
    
    func apply(pair: TradingPair, animation: AnimationParameter = .none, transition: TransitionParameter = .none) {
        let presentationUpdate = TradingPresentationUpdate(
            animations: [
                .backgroundColors(from: pair.from.brandColor, to: pair.to.brandColor),
                .statusTintColor(.green),
                .swapTintColor(.grayBlue),
                .statusVisibility(.visible)
            ],
            animation: animation
        )
        
        let transitionUpdate = TradingTransitionUpdate(
            transitions: [
                .images(from: pair.from.brandImage, to: pair.to.brandImage),
                .titles(from: pair.from.description, to: pair.to.description),
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
            iconStatusImageView.tintColor = color
            
        case .statusVisibility(let visibility):
            iconStatusImageView.alpha = visibility.defaultAlpha
            
        case .backgroundColors(from: let fromColor, to: let toColor):
            toButton.backgroundColor = toColor
            fromButton.backgroundColor = fromColor
            
        case .swapTintColor(let color):
            swapButton.tintColor = color
        }
    }
    
    func handle(_ transition: ViewTransition) {
        switch transition {
        case .swapImage(let image):
            swapButton.setImage(image, for: .normal)
            
        case .images(from: let fromImage, to: let toImage):
            toButton.setImage(toImage, for: .normal)
            fromButton.setImage(fromImage, for: .normal)
            
        case .titles(from: let fromTitle, to: let toTitle):
            toButton.setTitle(toTitle, for: .normal)
            fromButton.setTitle(fromTitle, for: .normal)
        }
    }
}
