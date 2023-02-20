// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Lottie
import SwiftUI

#if canImport(UIKit)
public struct LottieView: UIViewRepresentable {

    public let json: Data?
    public let loopMode: LottieLoopMode

    public init(json: String, loopMode: LottieLoopMode = .loop) {
        self.json = Data(json.utf8)
        self.loopMode = loopMode
    }

    public init(json: Data?, loopMode: LottieLoopMode = .loop) {
        self.json = json
        self.loopMode = loopMode
    }

    public class Container: UIView {
        let animationView = LottieAnimationView()
        override public func didMoveToSuperview() {
            super.didMoveToSuperview()
            animationView.contentMode = .scaleAspectFit
            animationView.translatesAutoresizingMaskIntoConstraints = false
            if animationView.superview !== self {
                addSubview(animationView)
                NSLayoutConstraint.activate(
                    [
                        animationView.heightAnchor.constraint(equalTo: heightAnchor),
                        animationView.widthAnchor.constraint(equalTo: widthAnchor)
                    ]
                )
            }
        }
    }

    public func makeUIView(context: UIViewRepresentableContext<LottieView>) -> Container {
        Container(frame: .zero)
    }

    public func updateUIView(_ uiView: Container, context: Context) {
        if let json {
            do {
                uiView.animationView.animation = try JSONDecoder()
                    .decode(LottieAnimation.self, from: json)
            } catch {
                uiView.animationView.animation = nil
            }
        }
        uiView.animationView.loopMode = loopMode
        uiView.animationView.play()
    }
}
#else
public struct LottieView: NSViewRepresentable {

    public let json: Data?
    public let loopMode: LottieLoopMode

    public init(json: String, loopMode: LottieLoopMode = .loop) {
        self.json = Data(json.utf8)
        self.loopMode = loopMode
    }

    public init(json: Data?, loopMode: LottieLoopMode = .loop) {
        self.json = json
        self.loopMode = loopMode
    }

    public class Container: NSView {
        let animationView = LottieAnimationView()
        override public func viewDidMoveToSuperview() {
            super.viewDidMoveToSuperview()
            animationView.contentMode = .scaleAspectFit
            animationView.translatesAutoresizingMaskIntoConstraints = false
            if animationView.superview !== self {
                addSubview(animationView)
            }
        }

        override public func layout() {
            super.layout()
            animationView.frame = bounds
        }
    }

    public func makeNSView(context: NSViewRepresentableContext<LottieView>) -> Container {
        Container(frame: .zero)
    }

    public func updateNSView(_ nsView: Container, context: Context) {
        if let json {
            do {
                nsView.animationView.animation = try JSONDecoder()
                    .decode(LottieAnimation.self, from: json)
            } catch {
                nsView.animationView.animation = nil
            }
        }
        nsView.animationView.loopMode = loopMode
        nsView.animationView.play()
    }
}
#endif

struct LottieView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            LottieView(
                json: square
            )
            .padding()
            LottieView(
                json: Bundle.componentLibrary.url(forResource: "loader", withExtension: "json").flatMap { url in
                    try? Data(contentsOf: url)
                }!
            )
            .padding()
        }
    }
}

// swiftlint:disable all

let square = """
{"v":"5.7.6","fr":29.9700012207031,"ip":0,"op":31.0000012626559,"w":1000,"h":1000,"nm":"Comp 1","ddd":0,"assets":[],"layers":[{"ddd":0,"ind":1,"ty":4,"nm":"Shape Layer 1","sr":1,"ks":{"o":{"a":0,"k":100,"ix":11},"r":{"a":1,"k":[{"i":{"x":[0.481],"y":[1]},"o":{"x":[0.529],"y":[0]},"t":0,"s":[0]},{"t":30.0000012219251,"s":[360]}],"ix":10},"p":{"a":0,"k":[500,500,0],"ix":2,"l":2},"a":{"a":0,"k":[-32.151,-3.326,0],"ix":1,"l":2},"s":{"a":0,"k":[100,100,100],"ix":6,"l":2}},"ao":0,"shapes":[{"ty":"gr","it":[{"ty":"rc","d":1,"s":{"a":0,"k":[368.071,368.071],"ix":2},"p":{"a":0,"k":[0,0],"ix":3},"r":{"a":0,"k":0,"ix":4},"nm":"Rectangle Path 1","mn":"ADBE Vector Shape - Rect","hd":false},{"ty":"st","c":{"a":0,"k":[0.079999998504,0.079999998504,0.079999998504,1],"ix":3},"o":{"a":0,"k":100,"ix":4},"w":{"a":0,"k":0,"ix":5},"lc":1,"lj":1,"ml":4,"bm":0,"nm":"Stroke 1","mn":"ADBE Vector Graphic - Stroke","hd":false},{"ty":"fl","c":{"a":0,"k":[0.878431013519,0.041338000578,0.041338000578,1],"ix":4},"o":{"a":0,"k":100,"ix":5},"r":1,"bm":0,"nm":"Fill 1","mn":"ADBE Vector Graphic - Fill","hd":false},{"ty":"tr","p":{"a":0,"k":[-32.151,-3.326],"ix":2},"a":{"a":0,"k":[0,0],"ix":1},"s":{"a":0,"k":[100,100],"ix":3},"r":{"a":0,"k":0,"ix":6},"o":{"a":0,"k":100,"ix":7},"sk":{"a":0,"k":0,"ix":4},"sa":{"a":0,"k":0,"ix":5},"nm":"Transform"}],"nm":"Rectangle 1","np":3,"cix":2,"bm":0,"ix":1,"mn":"ADBE Vector Group","hd":false}],"ip":0,"op":450.000018328876,"st":0,"bm":0}],"markers":[]}
"""
