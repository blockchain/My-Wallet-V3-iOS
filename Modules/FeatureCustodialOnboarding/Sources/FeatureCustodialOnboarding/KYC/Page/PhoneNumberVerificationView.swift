import BlockchainUI
import SwiftUI

public struct PhoneNumberVerificationView: View {

    @BlockchainApp var app

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
                    action: {
                        Task { await object.resend() }
                    }
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
        .task { await object.poll() }
        .onAppear {
            $app.post(event: blockchain.ux.kyc.prove.phone.number.verification)
        }
    }
}

public struct PhoneNumberVerification: Codable {
    public var isVerified: Bool
}

@MainActor public class PhoneNumberVerificationObject: ObservableObject {

    @Published public var state: AsyncState<PhoneNumberVerification, Error> = .idle

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.KYCOnboardingService) var KYCOnboardingService

    let backoff = ExponentialBackoff()

    public var isVerified: Bool {
        if case .success(let value) = state { return value.isVerified }
        return false
    }

    @discardableResult
    public func poll() async -> AsyncState<PhoneNumberVerification, Error> {
        state = .loading
        do {
            var inProgress = false
            var result: InstantLink
            repeat {
                do {
                    result = try await KYCOnboardingService.instantLink()
                } catch {
                    result = InstantLink(status: .inProgress)
                    try await backoff.next()
                }
                inProgress = result.status == .inProgress
                if inProgress {
                    try await mainQueue.sleep(for: .seconds(3))
                }
            } while inProgress
            state = .success(PhoneNumberVerification(isVerified: result.status == .verified))
        } catch {
            state = .failure(error)
        }
        return state
    }

    public func resend() async {
        guard state == .loading else { return }
        do {
            try await KYCOnboardingService.requestInstantLinkResend()
        } catch {
            return
        }
    }
}

struct PhoneNumberVerificationView_Preview: PreviewProvider {
    static var previews: some View {
        PhoneNumberVerificationView(completion: { print(#fileID) })
    }
}
