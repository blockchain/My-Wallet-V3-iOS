import Blockchain
import FeatureAuthenticationDomain

class ResubmitResidentialInformation: Client.Observer {

    @Dependency(\.app) var app

    lazy var resubmit = app.on(blockchain.ux.user.authentication.sign.up.address.submit) { [app] _ async throws in
        guard app.state.contains(blockchain.ux.user.authentication.sign.up.address.country.code) else { return }
        let country: String = try app.state.get(blockchain.ux.user.authentication.sign.up.address.country.code)
        let countryState: String? = try? app.state.get(blockchain.ux.user.authentication.sign.up.address.country.state)
        let service: WalletCreationService = resolve()
        try await service.setResidentialInfo(country, countryState).await()
        app.state.transaction { state in
            state.clear(blockchain.ux.user.authentication.sign.up.address.country.code)
            state.clear(blockchain.ux.user.authentication.sign.up.address.country.state)
        }
    }

    func start() {
        resubmit.start()
    }

    func stop() {
        resubmit.stop()
    }
}
