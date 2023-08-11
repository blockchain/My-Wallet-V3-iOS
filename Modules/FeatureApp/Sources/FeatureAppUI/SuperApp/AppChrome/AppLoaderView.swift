//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import SwiftUI
import FeatureProductsDomain
import FeatureAppDomain
import DIKit

struct AppLoaderView<Content: View>: View {
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
      }
    }
}

struct AppLoaderView_Previews: PreviewProvider {
    static var previews: some View {
        AppLoaderView {

        }
    }
}




