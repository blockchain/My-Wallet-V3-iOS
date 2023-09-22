// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public enum ImageLocation: Hashable {

    case local(name: String, bundle: Bundle)
    case remote(url: URL)
    case systemName(String)

    @ViewBuilder
    public var image: some View {
        switch self {
        case .remote(url: let url):
            AsyncMedia(url: url)
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
