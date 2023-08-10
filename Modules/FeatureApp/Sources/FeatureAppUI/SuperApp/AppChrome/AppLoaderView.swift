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
        VStack {
            BlockchainProgressView()
                .task {
                    do {
                        let result = try await loaderService.loadAppDependencies()
                        withAnimation {
                            didFinish = true
                        }
                    }
                    catch {
                        didFinish = true
                        print(error.localizedDescription)
                    }
                }
        }
        .fullScreenCover(isPresented: $didFinish) {
            content
        }
    }
}

struct AppLoaderView_Previews: PreviewProvider {
    static var previews: some View {
        AppLoaderView {

        }
    }
}




