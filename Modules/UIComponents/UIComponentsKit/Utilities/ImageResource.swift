// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

#if canImport(UIKit)
import UIKit
public typealias UniversalImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias UniversalImage = NSImage
#endif

public enum ImageResource: Hashable {

    public enum Resource {
        case image(UniversalImage)
        case url(URL)
    }

    case local(name: String, bundle: Bundle)
    case remote(url: URL)
    case systemName(String)

    public var resource: Resource? {
        switch self {
        case .local(let name, let bundle):
            return UniversalImage(named: name, in: bundle, compatibleWith: nil).map(Resource.image)
        case .remote(let url):
            return .url(url)
        case .systemName(let name):
            return UniversalImage(systemName: name).map(Resource.image)
        }
    }

    public var url: URL? {
        if case .remote(let url) = self {
            return url
        }
        return nil
    }

    public var image: Image? {
        guard case .image(let image) = resource else {
            return nil
        }
        #if canImport(UIKit)
        return Image(uiImage: image)
        #elseif canImport(AppKit)
        return Image(nsImage: image)
        #endif
    }

    @ViewBuilder
    public var view: some View {
        switch self {
        case .local(let name, let bundle):
            UniversalImage(named: name, in: bundle, compatibleWith: nil).map { image in
                #if canImport(UIKit)
                return Image(uiImage: image).resizable()
                #elseif canImport(AppKit)
                return Image(nsImage: image).resizable()
                #endif
            }
        case .remote(let url):
            AsyncMedia(
                url: url,
                placeholder: {
                    Image(systemName: "squareshape.squareshape.dashed")
                        .resizable()
                        .overlay(ProgressView().opacity(0.3))
                        .foregroundColor(.semantic.light)
                }
            )
        case .systemName(let string):
            Image(systemName: string)
                .resizable()
        }
    }
}
