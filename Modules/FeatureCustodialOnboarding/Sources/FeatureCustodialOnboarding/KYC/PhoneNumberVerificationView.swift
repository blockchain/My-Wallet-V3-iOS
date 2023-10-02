import BlockchainUI
import SwiftUI

public struct PhoneNumberVerificationView: View {

    @State private var request = UUID()
    @StateObject private var object = PhoneNumberVerificationObject()

    public var completion: () -> Void

    public var body: some View {
        VStack {
            VStack {
                Spacer()
                    .frame(maxHeight: 64.pt)
                if object.isVerified {
                    Icon.checkCircle
                        .color(.semantic.success)
                        .frame(width: 60.pt, height: 60.pt)
                        .padding(24.pt)
                    VStack(spacing: 12.pt) {
                        Text(L10n.deviceVerified)
                            .typography(.title3)
                            .foregroundColor(.semantic.title)
                        Text(L10n.successfullyVerified)
                            .typography(.body1)
                            .foregroundColor(.semantic.body)
                    }
                } else {
                    ProgressView()
                        .progressViewStyle(.indeterminate)
                        .frame(width: 60.pt, height: 60.pt)
                        .padding(24.pt)
                    VStack(spacing: 12.pt) {
                        Text(L10n.verifyingDevice)
                            .typography(.title3)
                            .foregroundColor(.semantic.title)
                        Text(L10n.sentALink)
                            .typography(.body1)
                            .foregroundColor(.semantic.body)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            if object.isVerified {
                PrimaryButton(
                    title: L10n.next,
                    action: { completion() }
                )
            } else {
                MinimalButton(
                    title: L10n.resendSMS,
                    action: { request = UUID() }
                )
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white)
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.semantic.light)
        .task(id: request) { await object.submit() }
    }
}

public struct PhoneNumberVerification: Codable {
    public var isVerified: Bool
}

@MainActor public class PhoneNumberVerificationObject: ObservableObject {

    @Published public var state: AsyncState<PhoneNumberVerification, Error> = .idle
    @Dependency(\.mainQueue) var mainQueue

    public var isVerified: Bool {
        if case .success(let value) = state { return value.isVerified }
        return false
    }

    @discardableResult
    public func submit() async -> AsyncState<PhoneNumberVerification, Error> {
        state = .loading
        do {
            // In the real world, we will want to poll for the result until it's been verified
            // for await phoneNumber in client.checkPhoneNumberVerification() where !phoneNumber.isVerified {
            //   try await mainQueue.sleep(for: .seconds(3))
            //   state = .success(phoneNumber)
            // }
            try await mainQueue.sleep(for: .seconds(3))
            state = .success(PhoneNumberVerification(isVerified: Bool.random()))
        } catch {
            state = .failure(error)
        }
        return state
    }
}

struct PhoneNumberVerificationView_Preview: PreviewProvider {
    static var previews: some View {
        PhoneNumberVerificationView(completion: { print(#fileID) })
    }
}
