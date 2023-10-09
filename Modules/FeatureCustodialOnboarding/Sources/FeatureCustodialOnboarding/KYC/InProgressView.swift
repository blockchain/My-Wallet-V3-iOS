import BlockchainUI
import SwiftUI

public struct InProgressView: View {

    public var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(.indeterminate)
                .frame(width: 40.pt, height: 40.pt)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.semantic.light)
    }
}

struct InProgressView_Preview: PreviewProvider {
    static var previews: some View {
        InProgressView()
    }
}
