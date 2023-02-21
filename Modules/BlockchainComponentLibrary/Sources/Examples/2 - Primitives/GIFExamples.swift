import BlockchainComponentLibrary
import SwiftUI

struct GIFExamples: View {

    @State var url: URL? = URL(string: "https://mailfloss.com/wp-content/uploads/2019/08/5d667832888ec_gif1-Everyonelovesgifs_4ef1dbef8a604a3e1b26eebf2c000ef0.gif")

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(minimum: 100, maximum: 300)),
                    GridItem(.flexible(minimum: 100, maximum: 300))
                ]
            ) {
                ForEach(0..<30, id: \.self) { _ in
                    AsyncMedia(url: url)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(radius: 2)
                        .padding([.leading, .top])
                }
            }
            .padding([.trailing, .bottom])
        }
    }
}
