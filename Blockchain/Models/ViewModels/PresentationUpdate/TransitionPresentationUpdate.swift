//
//  TransitionPresentationUpdate.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Have your `enum` of TransitionUpdates conform
/// to this empty protocol and it can use `TransitionPresentationUpdate`
protocol Transition { }

/// This is for animating in a `UIView.transition` block.
/// Its used for animating updating the `UIImage` on a button
/// or the title.
struct TransitionPresentationUpdate<T: Transition> {
    let transitions: [T]
    let transitionType: TransitionParameter
    
    init(transitions: [T], transition: TransitionParameter) {
        self.transitions = transitions
        self.transitionType = transition
    }
}

struct TransitionPresentationUpdateGroup<T: Transition, C: CompletionEvent> {
    let transitions: [T]
    let transitionType: TransitionParameter
    let completionEvents: [C]
    let completion: UpdateCompletion<C>
    
    init(transitions: [T], transitionType: TransitionParameter, completionEvents: [C], completion: @escaping UpdateCompletion<C>) {
        self.transitions = transitions
        self.transitionType = transitionType
        self.completionEvents = completionEvents
        self.completion = completion
    }
    
    func finish(completed: Bool) {
        DispatchQueue.main.async {
            self.completion(completed, self.completionEvents)
        }
    }
}


/// This is used in `TransitionPresentationUpdate`.
/// You use this parameter value to change the style
/// of the animation applied to the UI update.
enum TransitionParameter {
    
    case crossFade(duration: TimeInterval)
    case none
    
    func perform(with view: UIView, animations: @escaping () -> Void) {
        switch self {
        case .crossFade(duration: let duration):
            UIView.transition(
                with: view,
                duration: duration,
                options: [
                    .beginFromCurrentState,
                    .transitionCrossDissolve,
                    .allowUserInteraction
                ],
                animations: animations,
                completion: nil
            )
            
        case .none:
            animations()
        }
    }
}
