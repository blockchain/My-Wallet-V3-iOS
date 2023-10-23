// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import DIKit
import FeatureAppDomain
import FeatureProductsDomain
import SwiftUI

struct AppLoaderView<Content: View>: View {
    @Dependency(\.app) var app
    @StateObject var loaderService = AppLoaderService()
    let content: Content
    @State var didFinish: Bool = false
    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    var body: some View {
      if didFinish {
        content
      } else {
        BlockchainProgressView()
          .task {
            _ = try? await loaderService.loadAppDependencies()
            withAnimation { didFinish = true }
          }
          .onAppear {
              app.post(event: blockchain.app.loader.did.appear)
          }
      }
    }
}

struct AppLoaderView_Previews: PreviewProvider {
    static var previews: some View {
        AppLoaderView {}
    }
}
