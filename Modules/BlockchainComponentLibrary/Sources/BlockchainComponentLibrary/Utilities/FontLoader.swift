// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CoreText
import Foundation
import Lottie
import Nuke
import NukeUI

func loadCustomFonts() {
    DispatchQueue.once {
        Typography.FontResource.allCases
            .map(\.rawValue)
            .forEach { registerFont(fileName: $0) }
        Task(priority: .userInitiated) { @MainActor in
            registerImageFormats()
        }
    }
}

func registerFont(fileName: String, bundle: Bundle = Bundle.componentLibrary) {
    guard let fontURL = bundle.url(forResource: fileName, withExtension: "ttf") else {
        print("No font named \(fileName).ttf was found in the module bundle")
        return
    }

    var error: Unmanaged<CFError>?
    CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
    if error != nil {
        print("Failed to register font: \(fileName)")
    }
}

extension AssetType {
    public static let svg: AssetType = "public.svg"
    public static let lottie: AssetType = "public.lottie"
}

@MainActor
func registerImageFormats() {

    ImageDecoderRegistry.shared.register { context in
        guard let uniformTypeIdentifier = context.urlResponse?.url?.uniformTypeIdentifier else { return nil }
        if uniformTypeIdentifier.conforms(to: .svg) {
            return ImageDecoders.Empty(assetType: .svg, isProgressive: false)
        } else if uniformTypeIdentifier.conforms(to: .json) {
            return ImageDecoders.Empty(assetType: .lottie, isProgressive: false)
        } else {
            return nil
        }
    }

    ImageView.registerContentView { container in
        container.type == .svg ? SVG(container.data)?.view : nil
    }

    ImageView.registerContentView { container in
        guard
            container.type == .lottie,
            let json = container.data
        else {
            return nil
        }
        do {
            let animation = try JSONDecoder()
                .decode(LottieAnimation.self, from: json)
            let view = LottieAnimationView(animation: animation)
            view.loopMode = .loop
            view.play()
            return view
        } catch {
            return nil
        }
    }
}
