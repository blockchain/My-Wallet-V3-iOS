import SwiftUI

extension View {

    public func modal<Content: View>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View {
        modifier(ModalWrapper(isPresented: isPresented, modal: content))
    }
}

struct ModalWrapper<Modal: View>: ViewModifier {

    @Binding var isPresented: Bool
    let modal: () -> Modal

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                modal()
            }
        }
    }
}
