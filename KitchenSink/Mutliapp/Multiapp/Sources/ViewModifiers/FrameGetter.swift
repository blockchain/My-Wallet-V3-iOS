
import SwiftUI

class ViewFrame: ObservableObject {

    var startingRect: CGRect?

    @Published var frame: CGRect {
        willSet {
            if newValue.minY == 0, newValue != startingRect {
                startingRect = newValue
            }
        }
    }

    init() {
        self.frame = .zero
    }
}

extension View {
    func frameGetter(_ frame: Binding<CGRect>) -> some View {
        modifier(FrameGetter(frame: frame))
    }
}

struct FrameGetter: ViewModifier {

    @Binding var frame: CGRect

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> Color in
                    let rect = proxy.frame(in: .global)
                    if rect.integral != frame.integral {
                        DispatchQueue.main.async {
                            frame = rect
                        }
                    }
                    return Color.clear
                }
            )
    }
}
