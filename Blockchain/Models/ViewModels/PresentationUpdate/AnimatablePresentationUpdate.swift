//
//  AnimatablePresentationUpdate.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// When a `PresentationUpdateGroup` is created, there is the option
/// to include an array of `CompletionEvent` enums to fire
/// upon completion of the `AnimatablePresentationUpdate`.

protocol CompletionEvent {}

/// Have your `enum` of PresentationUpdates conform
/// to this empty protocol and it can use `AnimatablePresentationUpdate`
protocol Update { }

typealias UpdateCompletion<C: CompletionEvent> = ([C]?) -> Void

struct AnimatablePresentationUpdate<U: Update> {
    
    let animations: [U]
    let animationType: AnimationParameter
    
    init(animations: [U], animation: AnimationParameter) {
        self.animations = animations
        self.animationType = animation
    }
}

struct AnimatablePresentationUpdateGroup<U: Update, C: CompletionEvent> {
    let preparations: [U]
    let animations: [U]
    let animationType: AnimationParameter
    let completionEvents: [C]
    let completion: UpdateCompletion<C>
    
    init(
        preparations: [U] = [],
        animations: [U],
        animation: AnimationParameter,
        completionEvents: [C],
        completion: @escaping UpdateCompletion<C>
        ) {
        self.preparations = preparations
        self.animations = animations
        self.animationType = animation
        self.completionEvents = completionEvents
        self.completion = completion
    }
    
    func finish() {
        DispatchQueue.main.async {
            self.completion(self.completionEvents)
        }
    }
}

/// This is used in `AnimatablePresentationUpdate`.
/// You use this parameter value to change the style
/// of the animation applied to the UI update.
enum AnimationParameter {
    
    case standard(duration: TimeInterval)
    case easeIn(duration: TimeInterval)
    case easeOut(duration: TimeInterval)
    case crossFade(duration: TimeInterval)
    case none
    
    func perform(animations: @escaping () -> Void, completion: (() -> Void)? = nil) {
        
        switch self {
        case .crossFade(duration: let duration):
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: [
                    .beginFromCurrentState,
                    .transitionCrossDissolve,
                    .allowUserInteraction
                ],
                animations: animations,
                completion: { finished in
                    if let block = completion {
                        block()
                    }
            })
            
        case .standard(let duration):
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: [
                    .beginFromCurrentState,
                    .allowUserInteraction
                ],
                animations: animations,
                completion: { finished in
                    if let block = completion {
                        block()
                    }
            })
            
        case .easeIn(let duration):
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: [
                    .beginFromCurrentState,
                    .allowUserInteraction,
                    .curveEaseIn
                ],
                animations: animations,
                completion: { finished in
                    if let block = completion {
                        block()
                    }
            })
            
        case .easeOut(let duration):
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: [
                    .beginFromCurrentState,
                    .allowUserInteraction,
                    .curveEaseOut
                ],
                animations: animations,
                completion: { finished in
                    if let block = completion {
                        block()
                    }
            })
            
        case .none:
            animations()
        }
    }
}
