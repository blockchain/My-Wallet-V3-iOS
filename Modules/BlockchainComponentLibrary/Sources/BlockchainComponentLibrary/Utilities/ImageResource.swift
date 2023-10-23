// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public indirect enum ImageLocation: Hashable {

    case local(name: String, bundle: Bundle)
    case remote(url: URL, fallback: ImageLocation?)
    case systemName(String)

    @ViewBuilder
    public var image: some View {
        switch self {
        case .remote(url: let url, fallback: let fallback):
            RemoteImageLocationView(url: url, fallback: fallback)
        case .local(name: let name, bundle: let bundle):
            Image(name, bundle: bundle)
                .resizable()
                .aspectRatio(contentMode: .fit)
        case .systemName(let value):
            Image(systemName: value)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

private struct RemoteImageLocationView: View {
    let url: URL
    let fallback: ImageLocation?
    var body: some View {
        AsyncMedia(
            url: url,
            failure: { _ in
                if let fallback {
                    fallback.image
                }
            }
        )
    }
}
