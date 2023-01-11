import Foundation

// MARK: I

public protocol I: Sendable, TypeLocalized, SourceCodeIdentifiable {}

public protocol TypeLocalized {
	static var localized: String { get }
}

public protocol SourceCodeIdentifiable: CustomDebugStringConvertible {
	var __: String { get }
}

public extension SourceCodeIdentifiable {
	@inlinable var debugDescription: String { __ }
}

public enum CallAsFunctionExtensions<X> {
	case from
}

public extension I {
	func callAsFunction<Property>(_ keyPath: KeyPath<CallAsFunctionExtensions<I>, (I) -> Property>) -> Property {
		CallAsFunctionExtensions.from[keyPath: keyPath](self)
	}
}

public extension CallAsFunctionExtensions where X == I {
	var id: (I) -> String {{ $0.__ }}
	var localizedType: (I) -> String {{ type(of: $0).localized }}
}

// MARK: L

open class L: @unchecked Sendable, Hashable, I {
	open class var localized: String { "" }
	public let __: String
	public required init(_ id: String) { __ = id }
}

public extension L {
	static func == (lhs: L, rhs: L) -> Bool { lhs.__ == rhs.__ }
	func hash(into hasher: inout Hasher) { hasher.combine(__) }
}

// MARK: generated types

public let blockchain = L_blockchain("blockchain")

public final class L_blockchain: L, I_blockchain {
	public override class var localized: String { NSLocalizedString("blockchain", comment: "") }
}
public protocol I_blockchain: I {}
public extension I_blockchain {
	var `api`: L_blockchain_api { .init("\(__).api") }
	var `app`: L_blockchain_app { .init("\(__).app") }
	var `db`: L_blockchain_db { .init("\(__).db") }
	var `nabu`: L_blockchain_nabu { .init("\(__).nabu") }
	var `namespace`: L_blockchain_namespace { .init("\(__).namespace") }
	var `session`: L_blockchain_session { .init("\(__).session") }
	var `type`: L_blockchain_type { .init("\(__).type") }
	var `ui`: L_blockchain_ui { .init("\(__).ui") }
	var `user`: L_blockchain_user { .init("\(__).user") }
	var `ux`: L_blockchain_ux { .init("\(__).ux") }
}
public final class L_blockchain_api: L, I_blockchain_api {
	public override class var localized: String { NSLocalizedString("blockchain.api", comment: "") }
}
public protocol I_blockchain_api: I {}
public extension I_blockchain_api {
	var `nabu`: L_blockchain_api_nabu { .init("\(__).nabu") }
}
public final class L_blockchain_api_nabu: L, I_blockchain_api_nabu {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu", comment: "") }
}
public protocol I_blockchain_api_nabu: I {}
public extension I_blockchain_api_nabu {
	var `gateway`: L_blockchain_api_nabu_gateway { .init("\(__).gateway") }
}
public final class L_blockchain_api_nabu_gateway: L, I_blockchain_api_nabu_gateway {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway: I {}
public extension I_blockchain_api_nabu_gateway {
	var `generate`: L_blockchain_api_nabu_gateway_generate { .init("\(__).generate") }
	var `price`: L_blockchain_api_nabu_gateway_price { .init("\(__).price") }
	var `products`: L_blockchain_api_nabu_gateway_products { .init("\(__).products") }
	var `user`: L_blockchain_api_nabu_gateway_user { .init("\(__).user") }
}
public final class L_blockchain_api_nabu_gateway_generate: L, I_blockchain_api_nabu_gateway_generate {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.generate", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_generate: I {}
public extension I_blockchain_api_nabu_gateway_generate {
	var `session`: L_blockchain_api_nabu_gateway_generate_session { .init("\(__).session") }
}
public final class L_blockchain_api_nabu_gateway_generate_session: L, I_blockchain_api_nabu_gateway_generate_session {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.generate.session", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_generate_session: I {}
public extension I_blockchain_api_nabu_gateway_generate_session {
	var `headers`: L_blockchain_api_nabu_gateway_generate_session_headers { .init("\(__).headers") }
	var `is`: L_blockchain_api_nabu_gateway_generate_session_is { .init("\(__).is") }
}
public final class L_blockchain_api_nabu_gateway_generate_session_headers: L, I_blockchain_api_nabu_gateway_generate_session_headers {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.generate.session.headers", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_generate_session_headers: I_blockchain_db_type_map, I_blockchain_session_state_value {}
public final class L_blockchain_api_nabu_gateway_generate_session_is: L, I_blockchain_api_nabu_gateway_generate_session_is {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.generate.session.is", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_generate_session_is: I {}
public extension I_blockchain_api_nabu_gateway_generate_session_is {
	var `enabled`: L_blockchain_api_nabu_gateway_generate_session_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_api_nabu_gateway_generate_session_is_enabled: L, I_blockchain_api_nabu_gateway_generate_session_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.generate.session.is.enabled", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_generate_session_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_api_nabu_gateway_price: L, I_blockchain_api_nabu_gateway_price {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.price", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_price: I {}
public extension I_blockchain_api_nabu_gateway_price {
	var `crypto`: L_blockchain_api_nabu_gateway_price_crypto { .init("\(__).crypto") }
	var `index`: L_blockchain_api_nabu_gateway_price_index { .init("\(__).index") }
}
public final class L_blockchain_api_nabu_gateway_price_crypto: L, I_blockchain_api_nabu_gateway_price_crypto {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.price.crypto", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_price_crypto: I_blockchain_db_collection {}
public extension I_blockchain_api_nabu_gateway_price_crypto {
	var `fiat`: L_blockchain_api_nabu_gateway_price_crypto_fiat { .init("\(__).fiat") }
}
public final class L_blockchain_api_nabu_gateway_price_crypto_fiat: L, I_blockchain_api_nabu_gateway_price_crypto_fiat {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.price.crypto.fiat", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_price_crypto_fiat: I_blockchain_db_collection {}
public extension I_blockchain_api_nabu_gateway_price_crypto_fiat {
	var `market`: L_blockchain_api_nabu_gateway_price_crypto_fiat_market { .init("\(__).market") }
	var `quote`: L_blockchain_api_nabu_gateway_price_crypto_fiat_quote { .init("\(__).quote") }
}
public final class L_blockchain_api_nabu_gateway_price_crypto_fiat_market: L, I_blockchain_api_nabu_gateway_price_crypto_fiat_market {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.price.crypto.fiat.market", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_price_crypto_fiat_market: I {}
public extension I_blockchain_api_nabu_gateway_price_crypto_fiat_market {
	var `cap`: L_blockchain_api_nabu_gateway_price_crypto_fiat_market_cap { .init("\(__).cap") }
}
public final class L_blockchain_api_nabu_gateway_price_crypto_fiat_market_cap: L, I_blockchain_api_nabu_gateway_price_crypto_fiat_market_cap {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.price.crypto.fiat.market.cap", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_price_crypto_fiat_market_cap: I_blockchain_db_type_number {}
public final class L_blockchain_api_nabu_gateway_price_crypto_fiat_quote: L, I_blockchain_api_nabu_gateway_price_crypto_fiat_quote {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.price.crypto.fiat.quote", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_price_crypto_fiat_quote: I {}
public extension I_blockchain_api_nabu_gateway_price_crypto_fiat_quote {
	var `timestamp`: L_blockchain_api_nabu_gateway_price_crypto_fiat_quote_timestamp { .init("\(__).timestamp") }
	var `value`: L_blockchain_api_nabu_gateway_price_crypto_fiat_quote_value { .init("\(__).value") }
}
public final class L_blockchain_api_nabu_gateway_price_crypto_fiat_quote_timestamp: L, I_blockchain_api_nabu_gateway_price_crypto_fiat_quote_timestamp {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.price.crypto.fiat.quote.timestamp", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_price_crypto_fiat_quote_timestamp: I_blockchain_db_type_date {}
public final class L_blockchain_api_nabu_gateway_price_crypto_fiat_quote_value: L, I_blockchain_api_nabu_gateway_price_crypto_fiat_quote_value {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.price.crypto.fiat.quote.value", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_price_crypto_fiat_quote_value: I_blockchain_type_money {}
public final class L_blockchain_api_nabu_gateway_price_index: L, I_blockchain_api_nabu_gateway_price_index {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.price.index", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_price_index: I {}
public final class L_blockchain_api_nabu_gateway_products: L, I_blockchain_api_nabu_gateway_products {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.products", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_products: I_blockchain_db_collection {}
public extension I_blockchain_api_nabu_gateway_products {
	var `ineligible`: L_blockchain_api_nabu_gateway_products_ineligible { .init("\(__).ineligible") }
	var `is`: L_blockchain_api_nabu_gateway_products_is { .init("\(__).is") }
}
public final class L_blockchain_api_nabu_gateway_products_ineligible: L, I_blockchain_api_nabu_gateway_products_ineligible {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.products.ineligible", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_products_ineligible: I {}
public extension I_blockchain_api_nabu_gateway_products_ineligible {
	var `learn`: L_blockchain_api_nabu_gateway_products_ineligible_learn { .init("\(__).learn") }
	var `message`: L_blockchain_api_nabu_gateway_products_ineligible_message { .init("\(__).message") }
	var `reason`: L_blockchain_api_nabu_gateway_products_ineligible_reason { .init("\(__).reason") }
	var `type`: L_blockchain_api_nabu_gateway_products_ineligible_type { .init("\(__).type") }
}
public final class L_blockchain_api_nabu_gateway_products_ineligible_learn: L, I_blockchain_api_nabu_gateway_products_ineligible_learn {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.products.ineligible.learn", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_products_ineligible_learn: I {}
public extension I_blockchain_api_nabu_gateway_products_ineligible_learn {
	var `more`: L_blockchain_api_nabu_gateway_products_ineligible_learn_more { .init("\(__).more") }
}
public final class L_blockchain_api_nabu_gateway_products_ineligible_learn_more: L, I_blockchain_api_nabu_gateway_products_ineligible_learn_more {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.products.ineligible.learn.more", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_products_ineligible_learn_more: I_blockchain_db_type_url {}
public final class L_blockchain_api_nabu_gateway_products_ineligible_message: L, I_blockchain_api_nabu_gateway_products_ineligible_message {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.products.ineligible.message", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_products_ineligible_message: I_blockchain_db_type_string {}
public final class L_blockchain_api_nabu_gateway_products_ineligible_reason: L, I_blockchain_api_nabu_gateway_products_ineligible_reason {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.products.ineligible.reason", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_products_ineligible_reason: I_blockchain_db_type_string {}
public final class L_blockchain_api_nabu_gateway_products_ineligible_type: L, I_blockchain_api_nabu_gateway_products_ineligible_type {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.products.ineligible.type", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_products_ineligible_type: I_blockchain_db_type_string {}
public final class L_blockchain_api_nabu_gateway_products_is: L, I_blockchain_api_nabu_gateway_products_is {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.products.is", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_products_is: I {}
public extension I_blockchain_api_nabu_gateway_products_is {
	var `eligible`: L_blockchain_api_nabu_gateway_products_is_eligible { .init("\(__).eligible") }
}
public final class L_blockchain_api_nabu_gateway_products_is_eligible: L, I_blockchain_api_nabu_gateway_products_is_eligible {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.products.is.eligible", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_products_is_eligible: I_blockchain_db_type_boolean {}
public final class L_blockchain_api_nabu_gateway_user: L, I_blockchain_api_nabu_gateway_user {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.user", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_user: I {}
public extension I_blockchain_api_nabu_gateway_user {
	var `tag`: L_blockchain_api_nabu_gateway_user_tag { .init("\(__).tag") }
}
public final class L_blockchain_api_nabu_gateway_user_tag: L, I_blockchain_api_nabu_gateway_user_tag {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.user.tag", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_user_tag: I {}
public extension I_blockchain_api_nabu_gateway_user_tag {
	var `service`: L_blockchain_api_nabu_gateway_user_tag_service { .init("\(__).service") }
}
public final class L_blockchain_api_nabu_gateway_user_tag_service: L, I_blockchain_api_nabu_gateway_user_tag_service {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.user.tag.service", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_user_tag_service: I {}
public extension I_blockchain_api_nabu_gateway_user_tag_service {
	var `is`: L_blockchain_api_nabu_gateway_user_tag_service_is { .init("\(__).is") }
}
public final class L_blockchain_api_nabu_gateway_user_tag_service_is: L, I_blockchain_api_nabu_gateway_user_tag_service_is {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.user.tag.service.is", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_user_tag_service_is: I {}
public extension I_blockchain_api_nabu_gateway_user_tag_service_is {
	var `enabled`: L_blockchain_api_nabu_gateway_user_tag_service_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_api_nabu_gateway_user_tag_service_is_enabled: L, I_blockchain_api_nabu_gateway_user_tag_service_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.api.nabu.gateway.user.tag.service.is.enabled", comment: "") }
}
public protocol I_blockchain_api_nabu_gateway_user_tag_service_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app: L, I_blockchain_app {
	public override class var localized: String { NSLocalizedString("blockchain.app", comment: "") }
}
public protocol I_blockchain_app: I {}
public extension I_blockchain_app {
	var `configuration`: L_blockchain_app_configuration { .init("\(__).configuration") }
	var `deep_link`: L_blockchain_app_deep__link { .init("\(__).deep_link") }
	var `did`: L_blockchain_app_did { .init("\(__).did") }
	var `dynamic`: L_blockchain_app_dynamic { .init("\(__).dynamic") }
	var `enter`: L_blockchain_app_enter { .init("\(__).enter") }
	var `environment`: L_blockchain_app_environment { .init("\(__).environment") }
	var `fraud`: L_blockchain_app_fraud { .init("\(__).fraud") }
	var `is`: L_blockchain_app_is { .init("\(__).is") }
	var `launched`: L_blockchain_app_launched { .init("\(__).launched") }
	var `mode`: L_blockchain_app_mode { .init("\(__).mode") }
	var `number`: L_blockchain_app_number { .init("\(__).number") }
	var `performance`: L_blockchain_app_performance { .init("\(__).performance") }
	var `process`: L_blockchain_app_process { .init("\(__).process") }
	var `version`: L_blockchain_app_version { .init("\(__).version") }
}
public final class L_blockchain_app_configuration: L, I_blockchain_app_configuration {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration", comment: "") }
}
public protocol I_blockchain_app_configuration: I {}
public extension I_blockchain_app_configuration {
	var `action`: L_blockchain_app_configuration_action { .init("\(__).action") }
	var `addresssearch`: L_blockchain_app_configuration_addresssearch { .init("\(__).addresssearch") }
	var `announcements`: L_blockchain_app_configuration_announcements { .init("\(__).announcements") }
	var `app`: L_blockchain_app_configuration_app { .init("\(__).app") }
	var `apple`: L_blockchain_app_configuration_apple { .init("\(__).apple") }
	var `argentinalinkbank`: L_blockchain_app_configuration_argentinalinkbank { .init("\(__).argentinalinkbank") }
	var `asset`: L_blockchain_app_configuration_asset { .init("\(__).asset") }
	var `card`: L_blockchain_app_configuration_card { .init("\(__).card") }
	var `customer`: L_blockchain_app_configuration_customer { .init("\(__).customer") }
	var `debug`: L_blockchain_app_configuration_debug { .init("\(__).debug") }
	var `deep_link`: L_blockchain_app_configuration_deep__link { .init("\(__).deep_link") }
	var `defi`: L_blockchain_app_configuration_defi { .init("\(__).defi") }
	var `dynamicselfcustody`: L_blockchain_app_configuration_dynamicselfcustody { .init("\(__).dynamicselfcustody") }
	var `evm`: L_blockchain_app_configuration_evm { .init("\(__).evm") }
	var `exchange`: L_blockchain_app_configuration_exchange { .init("\(__).exchange") }
	var `firebase`: L_blockchain_app_configuration_firebase { .init("\(__).firebase") }
	var `frequent`: L_blockchain_app_configuration_frequent { .init("\(__).frequent") }
	var `kyc`: L_blockchain_app_configuration_kyc { .init("\(__).kyc") }
	var `localized`: L_blockchain_app_configuration_localized { .init("\(__).localized") }
	var `manual`: L_blockchain_app_configuration_manual { .init("\(__).manual") }
	var `outbound`: L_blockchain_app_configuration_outbound { .init("\(__).outbound") }
	var `performance`: L_blockchain_app_configuration_performance { .init("\(__).performance") }
	var `prefill`: L_blockchain_app_configuration_prefill { .init("\(__).prefill") }
	var `profile`: L_blockchain_app_configuration_profile { .init("\(__).profile") }
	var `pubkey`: L_blockchain_app_configuration_pubkey { .init("\(__).pubkey") }
	var `recurring`: L_blockchain_app_configuration_recurring { .init("\(__).recurring") }
	var `referral`: L_blockchain_app_configuration_referral { .init("\(__).referral") }
	var `remote`: L_blockchain_app_configuration_remote { .init("\(__).remote") }
	var `request`: L_blockchain_app_configuration_request { .init("\(__).request") }
	var `SSL`: L_blockchain_app_configuration_SSL { .init("\(__).SSL") }
	var `staking`: L_blockchain_app_configuration_staking { .init("\(__).staking") }
	var `stx`: L_blockchain_app_configuration_stx { .init("\(__).stx") }
	var `superapp`: L_blockchain_app_configuration_superapp { .init("\(__).superapp") }
	var `swap`: L_blockchain_app_configuration_swap { .init("\(__).swap") }
	var `tabs`: L_blockchain_app_configuration_tabs { .init("\(__).tabs") }
	var `test`: L_blockchain_app_configuration_test { .init("\(__).test") }
	var `transaction`: L_blockchain_app_configuration_transaction { .init("\(__).transaction") }
	var `ui`: L_blockchain_app_configuration_ui { .init("\(__).ui") }
	var `unified`: L_blockchain_app_configuration_unified { .init("\(__).unified") }
	var `unspent`: L_blockchain_app_configuration_unspent { .init("\(__).unspent") }
	var `wallet`: L_blockchain_app_configuration_wallet { .init("\(__).wallet") }
}
public final class L_blockchain_app_configuration_action: L, I_blockchain_app_configuration_action {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.action", comment: "") }
}
public protocol I_blockchain_app_configuration_action: I_blockchain_db_collection, I_blockchain_session_configuration_value, I_blockchain_ux_type_action {}
public final class L_blockchain_app_configuration_addresssearch: L, I_blockchain_app_configuration_addresssearch {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.addresssearch", comment: "") }
}
public protocol I_blockchain_app_configuration_addresssearch: I {}
public extension I_blockchain_app_configuration_addresssearch {
	var `kyc`: L_blockchain_app_configuration_addresssearch_kyc { .init("\(__).kyc") }
}
public final class L_blockchain_app_configuration_addresssearch_kyc: L, I_blockchain_app_configuration_addresssearch_kyc {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.addresssearch.kyc", comment: "") }
}
public protocol I_blockchain_app_configuration_addresssearch_kyc: I {}
public extension I_blockchain_app_configuration_addresssearch_kyc {
	var `is`: L_blockchain_app_configuration_addresssearch_kyc_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_addresssearch_kyc_is: L, I_blockchain_app_configuration_addresssearch_kyc_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.addresssearch.kyc.is", comment: "") }
}
public protocol I_blockchain_app_configuration_addresssearch_kyc_is: I {}
public extension I_blockchain_app_configuration_addresssearch_kyc_is {
	var `enabled`: L_blockchain_app_configuration_addresssearch_kyc_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_addresssearch_kyc_is_enabled: L, I_blockchain_app_configuration_addresssearch_kyc_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.addresssearch.kyc.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_addresssearch_kyc_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_announcements: L, I_blockchain_app_configuration_announcements {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.announcements", comment: "") }
}
public protocol I_blockchain_app_configuration_announcements: I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_app: L, I_blockchain_app_configuration_app {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.app", comment: "") }
}
public protocol I_blockchain_app_configuration_app: I {}
public extension I_blockchain_app_configuration_app {
	var `maintenance`: L_blockchain_app_configuration_app_maintenance { .init("\(__).maintenance") }
	var `superapp`: L_blockchain_app_configuration_app_superapp { .init("\(__).superapp") }
}
public final class L_blockchain_app_configuration_app_maintenance: L, I_blockchain_app_configuration_app_maintenance {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.app.maintenance", comment: "") }
}
public protocol I_blockchain_app_configuration_app_maintenance: I_blockchain_db_type_any, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_app_superapp: L, I_blockchain_app_configuration_app_superapp {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.app.superapp", comment: "") }
}
public protocol I_blockchain_app_configuration_app_superapp: I {}
public extension I_blockchain_app_configuration_app_superapp {
	var `is`: L_blockchain_app_configuration_app_superapp_is { .init("\(__).is") }
	var `v1`: L_blockchain_app_configuration_app_superapp_v1 { .init("\(__).v1") }
}
public final class L_blockchain_app_configuration_app_superapp_is: L, I_blockchain_app_configuration_app_superapp_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.app.superapp.is", comment: "") }
}
public protocol I_blockchain_app_configuration_app_superapp_is: I {}
public extension I_blockchain_app_configuration_app_superapp_is {
	var `enabled`: L_blockchain_app_configuration_app_superapp_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_app_superapp_is_enabled: L, I_blockchain_app_configuration_app_superapp_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.app.superapp.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_app_superapp_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_app_superapp_v1: L, I_blockchain_app_configuration_app_superapp_v1 {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.app.superapp.v1", comment: "") }
}
public protocol I_blockchain_app_configuration_app_superapp_v1: I {}
public extension I_blockchain_app_configuration_app_superapp_v1 {
	var `is`: L_blockchain_app_configuration_app_superapp_v1_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_app_superapp_v1_is: L, I_blockchain_app_configuration_app_superapp_v1_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.app.superapp.v1.is", comment: "") }
}
public protocol I_blockchain_app_configuration_app_superapp_v1_is: I {}
public extension I_blockchain_app_configuration_app_superapp_v1_is {
	var `enabled`: L_blockchain_app_configuration_app_superapp_v1_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_app_superapp_v1_is_enabled: L, I_blockchain_app_configuration_app_superapp_v1_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.app.superapp.v1.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_app_superapp_v1_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_apple: L, I_blockchain_app_configuration_apple {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.apple", comment: "") }
}
public protocol I_blockchain_app_configuration_apple: I {}
public extension I_blockchain_app_configuration_apple {
	var `pay`: L_blockchain_app_configuration_apple_pay { .init("\(__).pay") }
}
public final class L_blockchain_app_configuration_apple_pay: L, I_blockchain_app_configuration_apple_pay {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.apple.pay", comment: "") }
}
public protocol I_blockchain_app_configuration_apple_pay: I {}
public extension I_blockchain_app_configuration_apple_pay {
	var `is`: L_blockchain_app_configuration_apple_pay_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_apple_pay_is: L, I_blockchain_app_configuration_apple_pay_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.apple.pay.is", comment: "") }
}
public protocol I_blockchain_app_configuration_apple_pay_is: I {}
public extension I_blockchain_app_configuration_apple_pay_is {
	var `enabled`: L_blockchain_app_configuration_apple_pay_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_apple_pay_is_enabled: L, I_blockchain_app_configuration_apple_pay_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.apple.pay.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_apple_pay_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_argentinalinkbank: L, I_blockchain_app_configuration_argentinalinkbank {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.argentinalinkbank", comment: "") }
}
public protocol I_blockchain_app_configuration_argentinalinkbank: I {}
public extension I_blockchain_app_configuration_argentinalinkbank {
	var `is`: L_blockchain_app_configuration_argentinalinkbank_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_argentinalinkbank_is: L, I_blockchain_app_configuration_argentinalinkbank_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.argentinalinkbank.is", comment: "") }
}
public protocol I_blockchain_app_configuration_argentinalinkbank_is: I {}
public extension I_blockchain_app_configuration_argentinalinkbank_is {
	var `enabled`: L_blockchain_app_configuration_argentinalinkbank_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_argentinalinkbank_is_enabled: L, I_blockchain_app_configuration_argentinalinkbank_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.argentinalinkbank.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_argentinalinkbank_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_asset: L, I_blockchain_app_configuration_asset {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset", comment: "") }
}
public protocol I_blockchain_app_configuration_asset: I {}
public extension I_blockchain_app_configuration_asset {
	var `chart`: L_blockchain_app_configuration_asset_chart { .init("\(__).chart") }
	var `coming`: L_blockchain_app_configuration_asset_coming { .init("\(__).coming") }
	var `recurring`: L_blockchain_app_configuration_asset_recurring { .init("\(__).recurring") }
}
public final class L_blockchain_app_configuration_asset_chart: L, I_blockchain_app_configuration_asset_chart {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.chart", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_chart: I {}
public extension I_blockchain_app_configuration_asset_chart {
	var `asset`: L_blockchain_app_configuration_asset_chart_asset { .init("\(__).asset") }
}
public final class L_blockchain_app_configuration_asset_chart_asset: L, I_blockchain_app_configuration_asset_chart_asset {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.chart.asset", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_chart_asset: I {}
public extension I_blockchain_app_configuration_asset_chart_asset {
	var `color`: L_blockchain_app_configuration_asset_chart_asset_color { .init("\(__).color") }
}
public final class L_blockchain_app_configuration_asset_chart_asset_color: L, I_blockchain_app_configuration_asset_chart_asset_color {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.chart.asset.color", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_chart_asset_color: I {}
public extension I_blockchain_app_configuration_asset_chart_asset_color {
	var `is`: L_blockchain_app_configuration_asset_chart_asset_color_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_asset_chart_asset_color_is: L, I_blockchain_app_configuration_asset_chart_asset_color_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.chart.asset.color.is", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_chart_asset_color_is: I {}
public extension I_blockchain_app_configuration_asset_chart_asset_color_is {
	var `enabled`: L_blockchain_app_configuration_asset_chart_asset_color_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_asset_chart_asset_color_is_enabled: L, I_blockchain_app_configuration_asset_chart_asset_color_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.chart.asset.color.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_chart_asset_color_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_asset_coming: L, I_blockchain_app_configuration_asset_coming {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.coming", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_coming: I {}
public extension I_blockchain_app_configuration_asset_coming {
	var `soon`: L_blockchain_app_configuration_asset_coming_soon { .init("\(__).soon") }
}
public final class L_blockchain_app_configuration_asset_coming_soon: L, I_blockchain_app_configuration_asset_coming_soon {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.coming.soon", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_coming_soon: I {}
public extension I_blockchain_app_configuration_asset_coming_soon {
	var `learn`: L_blockchain_app_configuration_asset_coming_soon_learn { .init("\(__).learn") }
	var `visit`: L_blockchain_app_configuration_asset_coming_soon_visit { .init("\(__).visit") }
}
public final class L_blockchain_app_configuration_asset_coming_soon_learn: L, I_blockchain_app_configuration_asset_coming_soon_learn {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.coming.soon.learn", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_coming_soon_learn: I {}
public extension I_blockchain_app_configuration_asset_coming_soon_learn {
	var `more`: L_blockchain_app_configuration_asset_coming_soon_learn_more { .init("\(__).more") }
}
public final class L_blockchain_app_configuration_asset_coming_soon_learn_more: L, I_blockchain_app_configuration_asset_coming_soon_learn_more {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.coming.soon.learn.more", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_coming_soon_learn_more: I {}
public extension I_blockchain_app_configuration_asset_coming_soon_learn_more {
	var `url`: L_blockchain_app_configuration_asset_coming_soon_learn_more_url { .init("\(__).url") }
}
public final class L_blockchain_app_configuration_asset_coming_soon_learn_more_url: L, I_blockchain_app_configuration_asset_coming_soon_learn_more_url {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.coming.soon.learn.more.url", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_coming_soon_learn_more_url: I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_asset_coming_soon_visit: L, I_blockchain_app_configuration_asset_coming_soon_visit {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.coming.soon.visit", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_coming_soon_visit: I {}
public extension I_blockchain_app_configuration_asset_coming_soon_visit {
	var `web`: L_blockchain_app_configuration_asset_coming_soon_visit_web { .init("\(__).web") }
}
public final class L_blockchain_app_configuration_asset_coming_soon_visit_web: L, I_blockchain_app_configuration_asset_coming_soon_visit_web {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.coming.soon.visit.web", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_coming_soon_visit_web: I {}
public extension I_blockchain_app_configuration_asset_coming_soon_visit_web {
	var `app`: L_blockchain_app_configuration_asset_coming_soon_visit_web_app { .init("\(__).app") }
}
public final class L_blockchain_app_configuration_asset_coming_soon_visit_web_app: L, I_blockchain_app_configuration_asset_coming_soon_visit_web_app {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.coming.soon.visit.web.app", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_coming_soon_visit_web_app: I {}
public extension I_blockchain_app_configuration_asset_coming_soon_visit_web_app {
	var `url`: L_blockchain_app_configuration_asset_coming_soon_visit_web_app_url { .init("\(__).url") }
}
public final class L_blockchain_app_configuration_asset_coming_soon_visit_web_app_url: L, I_blockchain_app_configuration_asset_coming_soon_visit_web_app_url {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.coming.soon.visit.web.app.url", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_coming_soon_visit_web_app_url: I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_asset_recurring: L, I_blockchain_app_configuration_asset_recurring {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.recurring", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_recurring: I {}
public extension I_blockchain_app_configuration_asset_recurring {
	var `buy`: L_blockchain_app_configuration_asset_recurring_buy { .init("\(__).buy") }
}
public final class L_blockchain_app_configuration_asset_recurring_buy: L, I_blockchain_app_configuration_asset_recurring_buy {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.recurring.buy", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_recurring_buy: I {}
public extension I_blockchain_app_configuration_asset_recurring_buy {
	var `learn`: L_blockchain_app_configuration_asset_recurring_buy_learn { .init("\(__).learn") }
}
public final class L_blockchain_app_configuration_asset_recurring_buy_learn: L, I_blockchain_app_configuration_asset_recurring_buy_learn {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.recurring.buy.learn", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_recurring_buy_learn: I {}
public extension I_blockchain_app_configuration_asset_recurring_buy_learn {
	var `more`: L_blockchain_app_configuration_asset_recurring_buy_learn_more { .init("\(__).more") }
}
public final class L_blockchain_app_configuration_asset_recurring_buy_learn_more: L, I_blockchain_app_configuration_asset_recurring_buy_learn_more {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.recurring.buy.learn.more", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_recurring_buy_learn_more: I {}
public extension I_blockchain_app_configuration_asset_recurring_buy_learn_more {
	var `url`: L_blockchain_app_configuration_asset_recurring_buy_learn_more_url { .init("\(__).url") }
}
public final class L_blockchain_app_configuration_asset_recurring_buy_learn_more_url: L, I_blockchain_app_configuration_asset_recurring_buy_learn_more_url {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.asset.recurring.buy.learn.more.url", comment: "") }
}
public protocol I_blockchain_app_configuration_asset_recurring_buy_learn_more_url: I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_card: L, I_blockchain_app_configuration_card {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.card", comment: "") }
}
public protocol I_blockchain_app_configuration_card: I {}
public extension I_blockchain_app_configuration_card {
	var `success`: L_blockchain_app_configuration_card_success { .init("\(__).success") }
}
public final class L_blockchain_app_configuration_card_success: L, I_blockchain_app_configuration_card_success {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.card.success", comment: "") }
}
public protocol I_blockchain_app_configuration_card_success: I {}
public extension I_blockchain_app_configuration_card_success {
	var `rate`: L_blockchain_app_configuration_card_success_rate { .init("\(__).rate") }
}
public final class L_blockchain_app_configuration_card_success_rate: L, I_blockchain_app_configuration_card_success_rate {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.card.success.rate", comment: "") }
}
public protocol I_blockchain_app_configuration_card_success_rate: I {}
public extension I_blockchain_app_configuration_card_success_rate {
	var `is`: L_blockchain_app_configuration_card_success_rate_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_card_success_rate_is: L, I_blockchain_app_configuration_card_success_rate_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.card.success.rate.is", comment: "") }
}
public protocol I_blockchain_app_configuration_card_success_rate_is: I {}
public extension I_blockchain_app_configuration_card_success_rate_is {
	var `enabled`: L_blockchain_app_configuration_card_success_rate_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_card_success_rate_is_enabled: L, I_blockchain_app_configuration_card_success_rate_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.card.success.rate.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_card_success_rate_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_customer: L, I_blockchain_app_configuration_customer {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.customer", comment: "") }
}
public protocol I_blockchain_app_configuration_customer: I {}
public extension I_blockchain_app_configuration_customer {
	var `support`: L_blockchain_app_configuration_customer_support { .init("\(__).support") }
}
public final class L_blockchain_app_configuration_customer_support: L, I_blockchain_app_configuration_customer_support {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.customer.support", comment: "") }
}
public protocol I_blockchain_app_configuration_customer_support: I {}
public extension I_blockchain_app_configuration_customer_support {
	var `is`: L_blockchain_app_configuration_customer_support_is { .init("\(__).is") }
	var `url`: L_blockchain_app_configuration_customer_support_url { .init("\(__).url") }
}
public final class L_blockchain_app_configuration_customer_support_is: L, I_blockchain_app_configuration_customer_support_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.customer.support.is", comment: "") }
}
public protocol I_blockchain_app_configuration_customer_support_is: I {}
public extension I_blockchain_app_configuration_customer_support_is {
	var `enabled`: L_blockchain_app_configuration_customer_support_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_customer_support_is_enabled: L, I_blockchain_app_configuration_customer_support_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.customer.support.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_customer_support_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_customer_support_url: L, I_blockchain_app_configuration_customer_support_url {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.customer.support.url", comment: "") }
}
public protocol I_blockchain_app_configuration_customer_support_url: I_blockchain_db_type_url, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_debug: L, I_blockchain_app_configuration_debug {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.debug", comment: "") }
}
public protocol I_blockchain_app_configuration_debug: I {}
public extension I_blockchain_app_configuration_debug {
	var `observers`: L_blockchain_app_configuration_debug_observers { .init("\(__).observers") }
}
public final class L_blockchain_app_configuration_debug_observers: L, I_blockchain_app_configuration_debug_observers {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.debug.observers", comment: "") }
}
public protocol I_blockchain_app_configuration_debug_observers: I_blockchain_db_type_array_of_tags, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_deep__link: L, I_blockchain_app_configuration_deep__link {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.deep_link", comment: "") }
}
public protocol I_blockchain_app_configuration_deep__link: I {}
public extension I_blockchain_app_configuration_deep__link {
	var `rules`: L_blockchain_app_configuration_deep__link_rules { .init("\(__).rules") }
}
public final class L_blockchain_app_configuration_deep__link_rules: L, I_blockchain_app_configuration_deep__link_rules {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.deep_link.rules", comment: "") }
}
public protocol I_blockchain_app_configuration_deep__link_rules: I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_defi: L, I_blockchain_app_configuration_defi {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.defi", comment: "") }
}
public protocol I_blockchain_app_configuration_defi: I {}
public extension I_blockchain_app_configuration_defi {
	var `tabs`: L_blockchain_app_configuration_defi_tabs { .init("\(__).tabs") }
}
public final class L_blockchain_app_configuration_defi_tabs: L, I_blockchain_app_configuration_defi_tabs {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.defi.tabs", comment: "") }
}
public protocol I_blockchain_app_configuration_defi_tabs: I_blockchain_db_type_array_of_tags, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_dynamicselfcustody: L, I_blockchain_app_configuration_dynamicselfcustody {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.dynamicselfcustody", comment: "") }
}
public protocol I_blockchain_app_configuration_dynamicselfcustody: I {}
public extension I_blockchain_app_configuration_dynamicselfcustody {
	var `assets`: L_blockchain_app_configuration_dynamicselfcustody_assets { .init("\(__).assets") }
}
public final class L_blockchain_app_configuration_dynamicselfcustody_assets: L, I_blockchain_app_configuration_dynamicselfcustody_assets {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.dynamicselfcustody.assets", comment: "") }
}
public protocol I_blockchain_app_configuration_dynamicselfcustody_assets: I_blockchain_db_array, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_evm: L, I_blockchain_app_configuration_evm {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.evm", comment: "") }
}
public protocol I_blockchain_app_configuration_evm: I {}
public extension I_blockchain_app_configuration_evm {
	var `name`: L_blockchain_app_configuration_evm_name { .init("\(__).name") }
	var `supported`: L_blockchain_app_configuration_evm_supported { .init("\(__).supported") }
}
public final class L_blockchain_app_configuration_evm_name: L, I_blockchain_app_configuration_evm_name {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.evm.name", comment: "") }
}
public protocol I_blockchain_app_configuration_evm_name: I {}
public extension I_blockchain_app_configuration_evm_name {
	var `sanitize`: L_blockchain_app_configuration_evm_name_sanitize { .init("\(__).sanitize") }
}
public final class L_blockchain_app_configuration_evm_name_sanitize: L, I_blockchain_app_configuration_evm_name_sanitize {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.evm.name.sanitize", comment: "") }
}
public protocol I_blockchain_app_configuration_evm_name_sanitize: I {}
public extension I_blockchain_app_configuration_evm_name_sanitize {
	var `is`: L_blockchain_app_configuration_evm_name_sanitize_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_evm_name_sanitize_is: L, I_blockchain_app_configuration_evm_name_sanitize_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.evm.name.sanitize.is", comment: "") }
}
public protocol I_blockchain_app_configuration_evm_name_sanitize_is: I {}
public extension I_blockchain_app_configuration_evm_name_sanitize_is {
	var `enabled`: L_blockchain_app_configuration_evm_name_sanitize_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_evm_name_sanitize_is_enabled: L, I_blockchain_app_configuration_evm_name_sanitize_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.evm.name.sanitize.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_evm_name_sanitize_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_evm_supported: L, I_blockchain_app_configuration_evm_supported {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.evm.supported", comment: "") }
}
public protocol I_blockchain_app_configuration_evm_supported: I_blockchain_db_array, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_exchange: L, I_blockchain_app_configuration_exchange {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.exchange", comment: "") }
}
public protocol I_blockchain_app_configuration_exchange: I {}
public extension I_blockchain_app_configuration_exchange {
	var `walletawareness`: L_blockchain_app_configuration_exchange_walletawareness { .init("\(__).walletawareness") }
}
public final class L_blockchain_app_configuration_exchange_walletawareness: L, I_blockchain_app_configuration_exchange_walletawareness {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.exchange.walletawareness", comment: "") }
}
public protocol I_blockchain_app_configuration_exchange_walletawareness: I {}
public extension I_blockchain_app_configuration_exchange_walletawareness {
	var `prompt`: L_blockchain_app_configuration_exchange_walletawareness_prompt { .init("\(__).prompt") }
}
public final class L_blockchain_app_configuration_exchange_walletawareness_prompt: L, I_blockchain_app_configuration_exchange_walletawareness_prompt {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.exchange.walletawareness.prompt", comment: "") }
}
public protocol I_blockchain_app_configuration_exchange_walletawareness_prompt: I {}
public extension I_blockchain_app_configuration_exchange_walletawareness_prompt {
	var `is`: L_blockchain_app_configuration_exchange_walletawareness_prompt_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_exchange_walletawareness_prompt_is: L, I_blockchain_app_configuration_exchange_walletawareness_prompt_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.exchange.walletawareness.prompt.is", comment: "") }
}
public protocol I_blockchain_app_configuration_exchange_walletawareness_prompt_is: I {}
public extension I_blockchain_app_configuration_exchange_walletawareness_prompt_is {
	var `enabled`: L_blockchain_app_configuration_exchange_walletawareness_prompt_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_exchange_walletawareness_prompt_is_enabled: L, I_blockchain_app_configuration_exchange_walletawareness_prompt_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.exchange.walletawareness.prompt.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_exchange_walletawareness_prompt_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_firebase: L, I_blockchain_app_configuration_firebase {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.firebase", comment: "") }
}
public protocol I_blockchain_app_configuration_firebase: I {}
public extension I_blockchain_app_configuration_firebase {
	var `project`: L_blockchain_app_configuration_firebase_project { .init("\(__).project") }
}
public final class L_blockchain_app_configuration_firebase_project: L, I_blockchain_app_configuration_firebase_project {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.firebase.project", comment: "") }
}
public protocol I_blockchain_app_configuration_firebase_project: I {}
public extension I_blockchain_app_configuration_firebase_project {
	var `id`: L_blockchain_app_configuration_firebase_project_id { .init("\(__).id") }
}
public final class L_blockchain_app_configuration_firebase_project_id: L, I_blockchain_app_configuration_firebase_project_id {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.firebase.project.id", comment: "") }
}
public protocol I_blockchain_app_configuration_firebase_project_id: I_blockchain_db_type_string, I_blockchain_session_state_shared_value {}
public final class L_blockchain_app_configuration_frequent: L, I_blockchain_app_configuration_frequent {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.frequent", comment: "") }
}
public protocol I_blockchain_app_configuration_frequent: I {}
public extension I_blockchain_app_configuration_frequent {
	var `action`: L_blockchain_app_configuration_frequent_action { .init("\(__).action") }
}
public final class L_blockchain_app_configuration_frequent_action: L, I_blockchain_app_configuration_frequent_action {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.frequent.action", comment: "") }
}
public protocol I_blockchain_app_configuration_frequent_action: I_blockchain_db_type_any, I_blockchain_session_configuration_value {}
public extension I_blockchain_app_configuration_frequent_action {
	var `pkw`: L_blockchain_app_configuration_frequent_action_pkw { .init("\(__).pkw") }
	var `trading`: L_blockchain_app_configuration_frequent_action_trading { .init("\(__).trading") }
}
public final class L_blockchain_app_configuration_frequent_action_pkw: L, I_blockchain_app_configuration_frequent_action_pkw {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.frequent.action.pkw", comment: "") }
}
public protocol I_blockchain_app_configuration_frequent_action_pkw: I_blockchain_db_type_any, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_frequent_action_trading: L, I_blockchain_app_configuration_frequent_action_trading {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.frequent.action.trading", comment: "") }
}
public protocol I_blockchain_app_configuration_frequent_action_trading: I_blockchain_db_type_any, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_kyc: L, I_blockchain_app_configuration_kyc {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc: I {}
public extension I_blockchain_app_configuration_kyc {
	var `email`: L_blockchain_app_configuration_kyc_email { .init("\(__).email") }
	var `integration`: L_blockchain_app_configuration_kyc_integration { .init("\(__).integration") }
	var `sdd`: L_blockchain_app_configuration_kyc_sdd { .init("\(__).sdd") }
}
public final class L_blockchain_app_configuration_kyc_email: L, I_blockchain_app_configuration_kyc_email {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.email", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_email: I {}
public extension I_blockchain_app_configuration_kyc_email {
	var `confirmation`: L_blockchain_app_configuration_kyc_email_confirmation { .init("\(__).confirmation") }
}
public final class L_blockchain_app_configuration_kyc_email_confirmation: L, I_blockchain_app_configuration_kyc_email_confirmation {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.email.confirmation", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_email_confirmation: I {}
public extension I_blockchain_app_configuration_kyc_email_confirmation {
	var `announcement`: L_blockchain_app_configuration_kyc_email_confirmation_announcement { .init("\(__).announcement") }
}
public final class L_blockchain_app_configuration_kyc_email_confirmation_announcement: L, I_blockchain_app_configuration_kyc_email_confirmation_announcement {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.email.confirmation.announcement", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_email_confirmation_announcement: I {}
public extension I_blockchain_app_configuration_kyc_email_confirmation_announcement {
	var `is`: L_blockchain_app_configuration_kyc_email_confirmation_announcement_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_kyc_email_confirmation_announcement_is: L, I_blockchain_app_configuration_kyc_email_confirmation_announcement_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.email.confirmation.announcement.is", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_email_confirmation_announcement_is: I {}
public extension I_blockchain_app_configuration_kyc_email_confirmation_announcement_is {
	var `enabled`: L_blockchain_app_configuration_kyc_email_confirmation_announcement_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_kyc_email_confirmation_announcement_is_enabled: L, I_blockchain_app_configuration_kyc_email_confirmation_announcement_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.email.confirmation.announcement.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_email_confirmation_announcement_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_kyc_integration: L, I_blockchain_app_configuration_kyc_integration {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.integration", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_integration: I {}
public extension I_blockchain_app_configuration_kyc_integration {
	var `prove`: L_blockchain_app_configuration_kyc_integration_prove { .init("\(__).prove") }
}
public final class L_blockchain_app_configuration_kyc_integration_prove: L, I_blockchain_app_configuration_kyc_integration_prove {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.integration.prove", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_integration_prove: I {}
public extension I_blockchain_app_configuration_kyc_integration_prove {
	var `begin`: L_blockchain_app_configuration_kyc_integration_prove_begin { .init("\(__).begin") }
	var `is`: L_blockchain_app_configuration_kyc_integration_prove_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_kyc_integration_prove_begin: L, I_blockchain_app_configuration_kyc_integration_prove_begin {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.integration.prove.begin", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_integration_prove_begin: I {}
public extension I_blockchain_app_configuration_kyc_integration_prove_begin {
	var `verification`: L_blockchain_app_configuration_kyc_integration_prove_begin_verification { .init("\(__).verification") }
}
public final class L_blockchain_app_configuration_kyc_integration_prove_begin_verification: L, I_blockchain_app_configuration_kyc_integration_prove_begin_verification {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.integration.prove.begin.verification", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_integration_prove_begin_verification: I {}
public extension I_blockchain_app_configuration_kyc_integration_prove_begin_verification {
	var `privacy`: L_blockchain_app_configuration_kyc_integration_prove_begin_verification_privacy { .init("\(__).privacy") }
}
public final class L_blockchain_app_configuration_kyc_integration_prove_begin_verification_privacy: L, I_blockchain_app_configuration_kyc_integration_prove_begin_verification_privacy {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.integration.prove.begin.verification.privacy", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_integration_prove_begin_verification_privacy: I {}
public extension I_blockchain_app_configuration_kyc_integration_prove_begin_verification_privacy {
	var `url`: L_blockchain_app_configuration_kyc_integration_prove_begin_verification_privacy_url { .init("\(__).url") }
}
public final class L_blockchain_app_configuration_kyc_integration_prove_begin_verification_privacy_url: L, I_blockchain_app_configuration_kyc_integration_prove_begin_verification_privacy_url {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.integration.prove.begin.verification.privacy.url", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_integration_prove_begin_verification_privacy_url: I_blockchain_db_type_url, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_kyc_integration_prove_is: L, I_blockchain_app_configuration_kyc_integration_prove_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.integration.prove.is", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_integration_prove_is: I {}
public extension I_blockchain_app_configuration_kyc_integration_prove_is {
	var `enabled`: L_blockchain_app_configuration_kyc_integration_prove_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_kyc_integration_prove_is_enabled: L, I_blockchain_app_configuration_kyc_integration_prove_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.integration.prove.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_integration_prove_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_kyc_sdd: L, I_blockchain_app_configuration_kyc_sdd {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.sdd", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_sdd: I {}
public extension I_blockchain_app_configuration_kyc_sdd {
	var `cache`: L_blockchain_app_configuration_kyc_sdd_cache { .init("\(__).cache") }
	var `pkw`: L_blockchain_app_configuration_kyc_sdd_pkw { .init("\(__).pkw") }
	var `trading`: L_blockchain_app_configuration_kyc_sdd_trading { .init("\(__).trading") }
}
public final class L_blockchain_app_configuration_kyc_sdd_cache: L, I_blockchain_app_configuration_kyc_sdd_cache {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.sdd.cache", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_sdd_cache: I {}
public extension I_blockchain_app_configuration_kyc_sdd_cache {
	var `is`: L_blockchain_app_configuration_kyc_sdd_cache_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_kyc_sdd_cache_is: L, I_blockchain_app_configuration_kyc_sdd_cache_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.sdd.cache.is", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_sdd_cache_is: I {}
public extension I_blockchain_app_configuration_kyc_sdd_cache_is {
	var `enabled`: L_blockchain_app_configuration_kyc_sdd_cache_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_kyc_sdd_cache_is_enabled: L, I_blockchain_app_configuration_kyc_sdd_cache_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.sdd.cache.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_sdd_cache_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_kyc_sdd_pkw: L, I_blockchain_app_configuration_kyc_sdd_pkw {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.sdd.pkw", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_sdd_pkw: I_blockchain_db_type_any, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_kyc_sdd_trading: L, I_blockchain_app_configuration_kyc_sdd_trading {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.kyc.sdd.trading", comment: "") }
}
public protocol I_blockchain_app_configuration_kyc_sdd_trading: I_blockchain_db_type_any, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_localized: L, I_blockchain_app_configuration_localized {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.localized", comment: "") }
}
public protocol I_blockchain_app_configuration_localized: I {}
public extension I_blockchain_app_configuration_localized {
	var `error`: L_blockchain_app_configuration_localized_error { .init("\(__).error") }
}
public final class L_blockchain_app_configuration_localized_error: L, I_blockchain_app_configuration_localized_error {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.localized.error", comment: "") }
}
public protocol I_blockchain_app_configuration_localized_error: I {}
public extension I_blockchain_app_configuration_localized_error {
	var `override`: L_blockchain_app_configuration_localized_error_override { .init("\(__).override") }
}
public final class L_blockchain_app_configuration_localized_error_override: L, I_blockchain_app_configuration_localized_error_override {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.localized.error.override", comment: "") }
}
public protocol I_blockchain_app_configuration_localized_error_override: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_app_configuration_manual: L, I_blockchain_app_configuration_manual {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.manual", comment: "") }
}
public protocol I_blockchain_app_configuration_manual: I {}
public extension I_blockchain_app_configuration_manual {
	var `login`: L_blockchain_app_configuration_manual_login { .init("\(__).login") }
}
public final class L_blockchain_app_configuration_manual_login: L, I_blockchain_app_configuration_manual_login {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.manual.login", comment: "") }
}
public protocol I_blockchain_app_configuration_manual_login: I {}
public extension I_blockchain_app_configuration_manual_login {
	var `is`: L_blockchain_app_configuration_manual_login_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_manual_login_is: L, I_blockchain_app_configuration_manual_login_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.manual.login.is", comment: "") }
}
public protocol I_blockchain_app_configuration_manual_login_is: I {}
public extension I_blockchain_app_configuration_manual_login_is {
	var `enabled`: L_blockchain_app_configuration_manual_login_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_manual_login_is_enabled: L, I_blockchain_app_configuration_manual_login_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.manual.login.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_manual_login_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_outbound: L, I_blockchain_app_configuration_outbound {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.outbound", comment: "") }
}
public protocol I_blockchain_app_configuration_outbound: I {}
public extension I_blockchain_app_configuration_outbound {
	var `request`: L_blockchain_app_configuration_outbound_request { .init("\(__).request") }
}
public final class L_blockchain_app_configuration_outbound_request: L, I_blockchain_app_configuration_outbound_request {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.outbound.request", comment: "") }
}
public protocol I_blockchain_app_configuration_outbound_request: I {}
public extension I_blockchain_app_configuration_outbound_request {
	var `interceptor`: L_blockchain_app_configuration_outbound_request_interceptor { .init("\(__).interceptor") }
}
public final class L_blockchain_app_configuration_outbound_request_interceptor: L, I_blockchain_app_configuration_outbound_request_interceptor {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.outbound.request.interceptor", comment: "") }
}
public protocol I_blockchain_app_configuration_outbound_request_interceptor: I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_performance: L, I_blockchain_app_configuration_performance {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.performance", comment: "") }
}
public protocol I_blockchain_app_configuration_performance: I {}
public extension I_blockchain_app_configuration_performance {
	var `tracing`: L_blockchain_app_configuration_performance_tracing { .init("\(__).tracing") }
}
public final class L_blockchain_app_configuration_performance_tracing: L, I_blockchain_app_configuration_performance_tracing {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.performance.tracing", comment: "") }
}
public protocol I_blockchain_app_configuration_performance_tracing: I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_prefill: L, I_blockchain_app_configuration_prefill {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.prefill", comment: "") }
}
public protocol I_blockchain_app_configuration_prefill: I {}
public extension I_blockchain_app_configuration_prefill {
	var `is`: L_blockchain_app_configuration_prefill_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_prefill_is: L, I_blockchain_app_configuration_prefill_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.prefill.is", comment: "") }
}
public protocol I_blockchain_app_configuration_prefill_is: I {}
public extension I_blockchain_app_configuration_prefill_is {
	var `enabled`: L_blockchain_app_configuration_prefill_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_prefill_is_enabled: L, I_blockchain_app_configuration_prefill_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.prefill.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_prefill_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_profile: L, I_blockchain_app_configuration_profile {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.profile", comment: "") }
}
public protocol I_blockchain_app_configuration_profile: I {}
public extension I_blockchain_app_configuration_profile {
	var `kyc`: L_blockchain_app_configuration_profile_kyc { .init("\(__).kyc") }
}
public final class L_blockchain_app_configuration_profile_kyc: L, I_blockchain_app_configuration_profile_kyc {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.profile.kyc", comment: "") }
}
public protocol I_blockchain_app_configuration_profile_kyc: I {}
public extension I_blockchain_app_configuration_profile_kyc {
	var `is`: L_blockchain_app_configuration_profile_kyc_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_profile_kyc_is: L, I_blockchain_app_configuration_profile_kyc_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.profile.kyc.is", comment: "") }
}
public protocol I_blockchain_app_configuration_profile_kyc_is: I {}
public extension I_blockchain_app_configuration_profile_kyc_is {
	var `enabled`: L_blockchain_app_configuration_profile_kyc_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_profile_kyc_is_enabled: L, I_blockchain_app_configuration_profile_kyc_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.profile.kyc.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_profile_kyc_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_pubkey: L, I_blockchain_app_configuration_pubkey {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.pubkey", comment: "") }
}
public protocol I_blockchain_app_configuration_pubkey: I {}
public extension I_blockchain_app_configuration_pubkey {
	var `service`: L_blockchain_app_configuration_pubkey_service { .init("\(__).service") }
}
public final class L_blockchain_app_configuration_pubkey_service: L, I_blockchain_app_configuration_pubkey_service {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.pubkey.service", comment: "") }
}
public protocol I_blockchain_app_configuration_pubkey_service: I {}
public extension I_blockchain_app_configuration_pubkey_service {
	var `auth`: L_blockchain_app_configuration_pubkey_service_auth { .init("\(__).auth") }
}
public final class L_blockchain_app_configuration_pubkey_service_auth: L, I_blockchain_app_configuration_pubkey_service_auth {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.pubkey.service.auth", comment: "") }
}
public protocol I_blockchain_app_configuration_pubkey_service_auth: I_blockchain_db_type_array_of_strings, I_blockchain_session_state_preference_value {}
public final class L_blockchain_app_configuration_recurring: L, I_blockchain_app_configuration_recurring {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.recurring", comment: "") }
}
public protocol I_blockchain_app_configuration_recurring: I {}
public extension I_blockchain_app_configuration_recurring {
	var `buy`: L_blockchain_app_configuration_recurring_buy { .init("\(__).buy") }
}
public final class L_blockchain_app_configuration_recurring_buy: L, I_blockchain_app_configuration_recurring_buy {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.recurring.buy", comment: "") }
}
public protocol I_blockchain_app_configuration_recurring_buy: I {}
public extension I_blockchain_app_configuration_recurring_buy {
	var `is`: L_blockchain_app_configuration_recurring_buy_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_recurring_buy_is: L, I_blockchain_app_configuration_recurring_buy_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.recurring.buy.is", comment: "") }
}
public protocol I_blockchain_app_configuration_recurring_buy_is: I {}
public extension I_blockchain_app_configuration_recurring_buy_is {
	var `enabled`: L_blockchain_app_configuration_recurring_buy_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_recurring_buy_is_enabled: L, I_blockchain_app_configuration_recurring_buy_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.recurring.buy.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_recurring_buy_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_referral: L, I_blockchain_app_configuration_referral {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.referral", comment: "") }
}
public protocol I_blockchain_app_configuration_referral: I {}
public extension I_blockchain_app_configuration_referral {
	var `is`: L_blockchain_app_configuration_referral_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_referral_is: L, I_blockchain_app_configuration_referral_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.referral.is", comment: "") }
}
public protocol I_blockchain_app_configuration_referral_is: I {}
public extension I_blockchain_app_configuration_referral_is {
	var `enabled`: L_blockchain_app_configuration_referral_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_referral_is_enabled: L, I_blockchain_app_configuration_referral_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.referral.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_referral_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_remote: L, I_blockchain_app_configuration_remote {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.remote", comment: "") }
}
public protocol I_blockchain_app_configuration_remote: I {}
public extension I_blockchain_app_configuration_remote {
	var `is`: L_blockchain_app_configuration_remote_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_remote_is: L, I_blockchain_app_configuration_remote_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.remote.is", comment: "") }
}
public protocol I_blockchain_app_configuration_remote_is: I {}
public extension I_blockchain_app_configuration_remote_is {
	var `stale`: L_blockchain_app_configuration_remote_is_stale { .init("\(__).stale") }
}
public final class L_blockchain_app_configuration_remote_is_stale: L, I_blockchain_app_configuration_remote_is_stale {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.remote.is.stale", comment: "") }
}
public protocol I_blockchain_app_configuration_remote_is_stale: I_blockchain_db_type_boolean, I_blockchain_session_state_preference_value, I_blockchain_session_state_shared_value {}
public final class L_blockchain_app_configuration_request: L, I_blockchain_app_configuration_request {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.request", comment: "") }
}
public protocol I_blockchain_app_configuration_request: I {}
public extension I_blockchain_app_configuration_request {
	var `console`: L_blockchain_app_configuration_request_console { .init("\(__).console") }
}
public final class L_blockchain_app_configuration_request_console: L, I_blockchain_app_configuration_request_console {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.request.console", comment: "") }
}
public protocol I_blockchain_app_configuration_request_console: I {}
public extension I_blockchain_app_configuration_request_console {
	var `logging`: L_blockchain_app_configuration_request_console_logging { .init("\(__).logging") }
}
public final class L_blockchain_app_configuration_request_console_logging: L, I_blockchain_app_configuration_request_console_logging {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.request.console.logging", comment: "") }
}
public protocol I_blockchain_app_configuration_request_console_logging: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_SSL: L, I_blockchain_app_configuration_SSL {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.SSL", comment: "") }
}
public protocol I_blockchain_app_configuration_SSL: I {}
public extension I_blockchain_app_configuration_SSL {
	var `pinning`: L_blockchain_app_configuration_SSL_pinning { .init("\(__).pinning") }
}
public final class L_blockchain_app_configuration_SSL_pinning: L, I_blockchain_app_configuration_SSL_pinning {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.SSL.pinning", comment: "") }
}
public protocol I_blockchain_app_configuration_SSL_pinning: I {}
public extension I_blockchain_app_configuration_SSL_pinning {
	var `is`: L_blockchain_app_configuration_SSL_pinning_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_SSL_pinning_is: L, I_blockchain_app_configuration_SSL_pinning_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.SSL.pinning.is", comment: "") }
}
public protocol I_blockchain_app_configuration_SSL_pinning_is: I {}
public extension I_blockchain_app_configuration_SSL_pinning_is {
	var `enabled`: L_blockchain_app_configuration_SSL_pinning_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_SSL_pinning_is_enabled: L, I_blockchain_app_configuration_SSL_pinning_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.SSL.pinning.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_SSL_pinning_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_staking: L, I_blockchain_app_configuration_staking {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.staking", comment: "") }
}
public protocol I_blockchain_app_configuration_staking: I {}
public extension I_blockchain_app_configuration_staking {
	var `is`: L_blockchain_app_configuration_staking_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_staking_is: L, I_blockchain_app_configuration_staking_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.staking.is", comment: "") }
}
public protocol I_blockchain_app_configuration_staking_is: I {}
public extension I_blockchain_app_configuration_staking_is {
	var `enabled`: L_blockchain_app_configuration_staking_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_staking_is_enabled: L, I_blockchain_app_configuration_staking_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.staking.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_staking_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_stx: L, I_blockchain_app_configuration_stx {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx", comment: "") }
}
public protocol I_blockchain_app_configuration_stx: I {}
public extension I_blockchain_app_configuration_stx {
	var `airdrop`: L_blockchain_app_configuration_stx_airdrop { .init("\(__).airdrop") }
	var `all`: L_blockchain_app_configuration_stx_all { .init("\(__).all") }
}
public final class L_blockchain_app_configuration_stx_airdrop: L, I_blockchain_app_configuration_stx_airdrop {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx.airdrop", comment: "") }
}
public protocol I_blockchain_app_configuration_stx_airdrop: I {}
public extension I_blockchain_app_configuration_stx_airdrop {
	var `users`: L_blockchain_app_configuration_stx_airdrop_users { .init("\(__).users") }
}
public final class L_blockchain_app_configuration_stx_airdrop_users: L, I_blockchain_app_configuration_stx_airdrop_users {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx.airdrop.users", comment: "") }
}
public protocol I_blockchain_app_configuration_stx_airdrop_users: I {}
public extension I_blockchain_app_configuration_stx_airdrop_users {
	var `is`: L_blockchain_app_configuration_stx_airdrop_users_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_stx_airdrop_users_is: L, I_blockchain_app_configuration_stx_airdrop_users_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx.airdrop.users.is", comment: "") }
}
public protocol I_blockchain_app_configuration_stx_airdrop_users_is: I {}
public extension I_blockchain_app_configuration_stx_airdrop_users_is {
	var `enabled`: L_blockchain_app_configuration_stx_airdrop_users_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_stx_airdrop_users_is_enabled: L, I_blockchain_app_configuration_stx_airdrop_users_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx.airdrop.users.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_stx_airdrop_users_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_stx_all: L, I_blockchain_app_configuration_stx_all {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx.all", comment: "") }
}
public protocol I_blockchain_app_configuration_stx_all: I {}
public extension I_blockchain_app_configuration_stx_all {
	var `users`: L_blockchain_app_configuration_stx_all_users { .init("\(__).users") }
}
public final class L_blockchain_app_configuration_stx_all_users: L, I_blockchain_app_configuration_stx_all_users {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx.all.users", comment: "") }
}
public protocol I_blockchain_app_configuration_stx_all_users: I {}
public extension I_blockchain_app_configuration_stx_all_users {
	var `is`: L_blockchain_app_configuration_stx_all_users_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_stx_all_users_is: L, I_blockchain_app_configuration_stx_all_users_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx.all.users.is", comment: "") }
}
public protocol I_blockchain_app_configuration_stx_all_users_is: I {}
public extension I_blockchain_app_configuration_stx_all_users_is {
	var `enabled`: L_blockchain_app_configuration_stx_all_users_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_stx_all_users_is_enabled: L, I_blockchain_app_configuration_stx_all_users_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.stx.all.users.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_stx_all_users_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_superapp: L, I_blockchain_app_configuration_superapp {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.superapp", comment: "") }
}
public protocol I_blockchain_app_configuration_superapp: I {}
public extension I_blockchain_app_configuration_superapp {
	var `brokerage`: L_blockchain_app_configuration_superapp_brokerage { .init("\(__).brokerage") }
	var `defi`: L_blockchain_app_configuration_superapp_defi { .init("\(__).defi") }
}
public final class L_blockchain_app_configuration_superapp_brokerage: L, I_blockchain_app_configuration_superapp_brokerage {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.superapp.brokerage", comment: "") }
}
public protocol I_blockchain_app_configuration_superapp_brokerage: I {}
public extension I_blockchain_app_configuration_superapp_brokerage {
	var `frequent`: L_blockchain_app_configuration_superapp_brokerage_frequent { .init("\(__).frequent") }
	var `tabs`: L_blockchain_app_configuration_superapp_brokerage_tabs { .init("\(__).tabs") }
}
public final class L_blockchain_app_configuration_superapp_brokerage_frequent: L, I_blockchain_app_configuration_superapp_brokerage_frequent {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.superapp.brokerage.frequent", comment: "") }
}
public protocol I_blockchain_app_configuration_superapp_brokerage_frequent: I {}
public extension I_blockchain_app_configuration_superapp_brokerage_frequent {
	var `action`: L_blockchain_app_configuration_superapp_brokerage_frequent_action { .init("\(__).action") }
}
public final class L_blockchain_app_configuration_superapp_brokerage_frequent_action: L, I_blockchain_app_configuration_superapp_brokerage_frequent_action {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.superapp.brokerage.frequent.action", comment: "") }
}
public protocol I_blockchain_app_configuration_superapp_brokerage_frequent_action: I_blockchain_db_type_any, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_superapp_brokerage_tabs: L, I_blockchain_app_configuration_superapp_brokerage_tabs {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.superapp.brokerage.tabs", comment: "") }
}
public protocol I_blockchain_app_configuration_superapp_brokerage_tabs: I_blockchain_app_configuration_tabs {}
public final class L_blockchain_app_configuration_superapp_defi: L, I_blockchain_app_configuration_superapp_defi {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.superapp.defi", comment: "") }
}
public protocol I_blockchain_app_configuration_superapp_defi: I {}
public extension I_blockchain_app_configuration_superapp_defi {
	var `frequent`: L_blockchain_app_configuration_superapp_defi_frequent { .init("\(__).frequent") }
	var `tabs`: L_blockchain_app_configuration_superapp_defi_tabs { .init("\(__).tabs") }
}
public final class L_blockchain_app_configuration_superapp_defi_frequent: L, I_blockchain_app_configuration_superapp_defi_frequent {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.superapp.defi.frequent", comment: "") }
}
public protocol I_blockchain_app_configuration_superapp_defi_frequent: I {}
public extension I_blockchain_app_configuration_superapp_defi_frequent {
	var `action`: L_blockchain_app_configuration_superapp_defi_frequent_action { .init("\(__).action") }
}
public final class L_blockchain_app_configuration_superapp_defi_frequent_action: L, I_blockchain_app_configuration_superapp_defi_frequent_action {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.superapp.defi.frequent.action", comment: "") }
}
public protocol I_blockchain_app_configuration_superapp_defi_frequent_action: I_blockchain_db_type_any, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_superapp_defi_tabs: L, I_blockchain_app_configuration_superapp_defi_tabs {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.superapp.defi.tabs", comment: "") }
}
public protocol I_blockchain_app_configuration_superapp_defi_tabs: I_blockchain_app_configuration_tabs {}
public final class L_blockchain_app_configuration_swap: L, I_blockchain_app_configuration_swap {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.swap", comment: "") }
}
public protocol I_blockchain_app_configuration_swap: I {}
public extension I_blockchain_app_configuration_swap {
	var `search`: L_blockchain_app_configuration_swap_search { .init("\(__).search") }
	var `switch`: L_blockchain_app_configuration_swap_switch { .init("\(__).switch") }
}
public final class L_blockchain_app_configuration_swap_search: L, I_blockchain_app_configuration_swap_search {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.swap.search", comment: "") }
}
public protocol I_blockchain_app_configuration_swap_search: I {}
public extension I_blockchain_app_configuration_swap_search {
	var `is`: L_blockchain_app_configuration_swap_search_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_swap_search_is: L, I_blockchain_app_configuration_swap_search_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.swap.search.is", comment: "") }
}
public protocol I_blockchain_app_configuration_swap_search_is: I {}
public extension I_blockchain_app_configuration_swap_search_is {
	var `enabled`: L_blockchain_app_configuration_swap_search_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_swap_search_is_enabled: L, I_blockchain_app_configuration_swap_search_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.swap.search.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_swap_search_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_swap_switch: L, I_blockchain_app_configuration_swap_switch {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.swap.switch", comment: "") }
}
public protocol I_blockchain_app_configuration_swap_switch: I {}
public extension I_blockchain_app_configuration_swap_switch {
	var `pkw`: L_blockchain_app_configuration_swap_switch_pkw { .init("\(__).pkw") }
}
public final class L_blockchain_app_configuration_swap_switch_pkw: L, I_blockchain_app_configuration_swap_switch_pkw {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.swap.switch.pkw", comment: "") }
}
public protocol I_blockchain_app_configuration_swap_switch_pkw: I {}
public extension I_blockchain_app_configuration_swap_switch_pkw {
	var `is`: L_blockchain_app_configuration_swap_switch_pkw_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_swap_switch_pkw_is: L, I_blockchain_app_configuration_swap_switch_pkw_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.swap.switch.pkw.is", comment: "") }
}
public protocol I_blockchain_app_configuration_swap_switch_pkw_is: I {}
public extension I_blockchain_app_configuration_swap_switch_pkw_is {
	var `enabled`: L_blockchain_app_configuration_swap_switch_pkw_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_swap_switch_pkw_is_enabled: L, I_blockchain_app_configuration_swap_switch_pkw_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.swap.switch.pkw.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_swap_switch_pkw_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_tabs: L, I_blockchain_app_configuration_tabs {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.tabs", comment: "") }
}
public protocol I_blockchain_app_configuration_tabs: I_blockchain_db_type_array_of_tags, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_test: L, I_blockchain_app_configuration_test {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.test", comment: "") }
}
public protocol I_blockchain_app_configuration_test: I {}
public extension I_blockchain_app_configuration_test {
	var `shared`: L_blockchain_app_configuration_test_shared { .init("\(__).shared") }
}
public final class L_blockchain_app_configuration_test_shared: L, I_blockchain_app_configuration_test_shared {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.test.shared", comment: "") }
}
public protocol I_blockchain_app_configuration_test_shared: I {}
public extension I_blockchain_app_configuration_test_shared {
	var `preference`: L_blockchain_app_configuration_test_shared_preference { .init("\(__).preference") }
}
public final class L_blockchain_app_configuration_test_shared_preference: L, I_blockchain_app_configuration_test_shared_preference {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.test.shared.preference", comment: "") }
}
public protocol I_blockchain_app_configuration_test_shared_preference: I_blockchain_db_type_boolean, I_blockchain_session_state_preference_value, I_blockchain_session_state_shared_value {}
public final class L_blockchain_app_configuration_transaction: L, I_blockchain_app_configuration_transaction {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction: I_blockchain_db_collection {}
public extension I_blockchain_app_configuration_transaction {
	var `quickfill`: L_blockchain_app_configuration_transaction_quickfill { .init("\(__).quickfill") }
	var `recurring`: L_blockchain_app_configuration_transaction_recurring { .init("\(__).recurring") }
	var `should`: L_blockchain_app_configuration_transaction_should { .init("\(__).should") }
}
public final class L_blockchain_app_configuration_transaction_quickfill: L, I_blockchain_app_configuration_transaction_quickfill {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.quickfill", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_quickfill: I {}
public extension I_blockchain_app_configuration_transaction_quickfill {
	var `amount`: L_blockchain_app_configuration_transaction_quickfill_amount { .init("\(__).amount") }
	var `configuration`: L_blockchain_app_configuration_transaction_quickfill_configuration { .init("\(__).configuration") }
	var `is`: L_blockchain_app_configuration_transaction_quickfill_is { .init("\(__).is") }
	var `type`: L_blockchain_app_configuration_transaction_quickfill_type { .init("\(__).type") }
}
public final class L_blockchain_app_configuration_transaction_quickfill_amount: L, I_blockchain_app_configuration_transaction_quickfill_amount {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.quickfill.amount", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_quickfill_amount: I_blockchain_db_type_string {}
public final class L_blockchain_app_configuration_transaction_quickfill_configuration: L, I_blockchain_app_configuration_transaction_quickfill_configuration {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.quickfill.configuration", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_quickfill_configuration: I_blockchain_db_array, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_transaction_quickfill_is: L, I_blockchain_app_configuration_transaction_quickfill_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.quickfill.is", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_quickfill_is: I {}
public extension I_blockchain_app_configuration_transaction_quickfill_is {
	var `enabled`: L_blockchain_app_configuration_transaction_quickfill_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_transaction_quickfill_is_enabled: L, I_blockchain_app_configuration_transaction_quickfill_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.quickfill.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_quickfill_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_transaction_quickfill_type: L, I_blockchain_app_configuration_transaction_quickfill_type {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.quickfill.type", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_quickfill_type: I_blockchain_db_type_string {}
public final class L_blockchain_app_configuration_transaction_recurring: L, I_blockchain_app_configuration_transaction_recurring {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.recurring", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_recurring: I {}
public extension I_blockchain_app_configuration_transaction_recurring {
	var `buy`: L_blockchain_app_configuration_transaction_recurring_buy { .init("\(__).buy") }
}
public final class L_blockchain_app_configuration_transaction_recurring_buy: L, I_blockchain_app_configuration_transaction_recurring_buy {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.recurring.buy", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_recurring_buy: I {}
public extension I_blockchain_app_configuration_transaction_recurring_buy {
	var `is`: L_blockchain_app_configuration_transaction_recurring_buy_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_transaction_recurring_buy_is: L, I_blockchain_app_configuration_transaction_recurring_buy_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.recurring.buy.is", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_recurring_buy_is: I {}
public extension I_blockchain_app_configuration_transaction_recurring_buy_is {
	var `enabled`: L_blockchain_app_configuration_transaction_recurring_buy_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_transaction_recurring_buy_is_enabled: L, I_blockchain_app_configuration_transaction_recurring_buy_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.recurring.buy.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_recurring_buy_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_transaction_should: L, I_blockchain_app_configuration_transaction_should {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.should", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_should: I {}
public extension I_blockchain_app_configuration_transaction_should {
	var `prefill`: L_blockchain_app_configuration_transaction_should_prefill { .init("\(__).prefill") }
}
public final class L_blockchain_app_configuration_transaction_should_prefill: L, I_blockchain_app_configuration_transaction_should_prefill {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.should.prefill", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_should_prefill: I {}
public extension I_blockchain_app_configuration_transaction_should_prefill {
	var `with`: L_blockchain_app_configuration_transaction_should_prefill_with { .init("\(__).with") }
}
public final class L_blockchain_app_configuration_transaction_should_prefill_with: L, I_blockchain_app_configuration_transaction_should_prefill_with {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.should.prefill.with", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_should_prefill_with: I {}
public extension I_blockchain_app_configuration_transaction_should_prefill_with {
	var `previous`: L_blockchain_app_configuration_transaction_should_prefill_with_previous { .init("\(__).previous") }
}
public final class L_blockchain_app_configuration_transaction_should_prefill_with_previous: L, I_blockchain_app_configuration_transaction_should_prefill_with_previous {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.should.prefill.with.previous", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_should_prefill_with_previous: I {}
public extension I_blockchain_app_configuration_transaction_should_prefill_with_previous {
	var `amount`: L_blockchain_app_configuration_transaction_should_prefill_with_previous_amount { .init("\(__).amount") }
}
public final class L_blockchain_app_configuration_transaction_should_prefill_with_previous_amount: L, I_blockchain_app_configuration_transaction_should_prefill_with_previous_amount {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.transaction.should.prefill.with.previous.amount", comment: "") }
}
public protocol I_blockchain_app_configuration_transaction_should_prefill_with_previous_amount: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_ui: L, I_blockchain_app_configuration_ui {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.ui", comment: "") }
}
public protocol I_blockchain_app_configuration_ui: I {}
public extension I_blockchain_app_configuration_ui {
	var `payments`: L_blockchain_app_configuration_ui_payments { .init("\(__).payments") }
}
public final class L_blockchain_app_configuration_ui_payments: L, I_blockchain_app_configuration_ui_payments {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.ui.payments", comment: "") }
}
public protocol I_blockchain_app_configuration_ui_payments: I {}
public extension I_blockchain_app_configuration_ui_payments {
	var `improvements`: L_blockchain_app_configuration_ui_payments_improvements { .init("\(__).improvements") }
}
public final class L_blockchain_app_configuration_ui_payments_improvements: L, I_blockchain_app_configuration_ui_payments_improvements {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.ui.payments.improvements", comment: "") }
}
public protocol I_blockchain_app_configuration_ui_payments_improvements: I {}
public extension I_blockchain_app_configuration_ui_payments_improvements {
	var `assets`: L_blockchain_app_configuration_ui_payments_improvements_assets { .init("\(__).assets") }
	var `is`: L_blockchain_app_configuration_ui_payments_improvements_is { .init("\(__).is") }
	var `wallet`: L_blockchain_app_configuration_ui_payments_improvements_wallet { .init("\(__).wallet") }
}
public final class L_blockchain_app_configuration_ui_payments_improvements_assets: L, I_blockchain_app_configuration_ui_payments_improvements_assets {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.ui.payments.improvements.assets", comment: "") }
}
public protocol I_blockchain_app_configuration_ui_payments_improvements_assets: I {}
public extension I_blockchain_app_configuration_ui_payments_improvements_assets {
	var `balances`: L_blockchain_app_configuration_ui_payments_improvements_assets_balances { .init("\(__).balances") }
}
public final class L_blockchain_app_configuration_ui_payments_improvements_assets_balances: L, I_blockchain_app_configuration_ui_payments_improvements_assets_balances {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.ui.payments.improvements.assets.balances", comment: "") }
}
public protocol I_blockchain_app_configuration_ui_payments_improvements_assets_balances: I {}
public extension I_blockchain_app_configuration_ui_payments_improvements_assets_balances {
	var `is`: L_blockchain_app_configuration_ui_payments_improvements_assets_balances_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_ui_payments_improvements_assets_balances_is: L, I_blockchain_app_configuration_ui_payments_improvements_assets_balances_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.ui.payments.improvements.assets.balances.is", comment: "") }
}
public protocol I_blockchain_app_configuration_ui_payments_improvements_assets_balances_is: I {}
public extension I_blockchain_app_configuration_ui_payments_improvements_assets_balances_is {
	var `enabled`: L_blockchain_app_configuration_ui_payments_improvements_assets_balances_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_ui_payments_improvements_assets_balances_is_enabled: L, I_blockchain_app_configuration_ui_payments_improvements_assets_balances_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.ui.payments.improvements.assets.balances.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_ui_payments_improvements_assets_balances_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_ui_payments_improvements_is: L, I_blockchain_app_configuration_ui_payments_improvements_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.ui.payments.improvements.is", comment: "") }
}
public protocol I_blockchain_app_configuration_ui_payments_improvements_is: I {}
public extension I_blockchain_app_configuration_ui_payments_improvements_is {
	var `enabled`: L_blockchain_app_configuration_ui_payments_improvements_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_ui_payments_improvements_is_enabled: L, I_blockchain_app_configuration_ui_payments_improvements_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.ui.payments.improvements.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_ui_payments_improvements_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_ui_payments_improvements_wallet: L, I_blockchain_app_configuration_ui_payments_improvements_wallet {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.ui.payments.improvements.wallet", comment: "") }
}
public protocol I_blockchain_app_configuration_ui_payments_improvements_wallet: I {}
public extension I_blockchain_app_configuration_ui_payments_improvements_wallet {
	var `balances`: L_blockchain_app_configuration_ui_payments_improvements_wallet_balances { .init("\(__).balances") }
}
public final class L_blockchain_app_configuration_ui_payments_improvements_wallet_balances: L, I_blockchain_app_configuration_ui_payments_improvements_wallet_balances {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.ui.payments.improvements.wallet.balances", comment: "") }
}
public protocol I_blockchain_app_configuration_ui_payments_improvements_wallet_balances: I {}
public extension I_blockchain_app_configuration_ui_payments_improvements_wallet_balances {
	var `is`: L_blockchain_app_configuration_ui_payments_improvements_wallet_balances_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_ui_payments_improvements_wallet_balances_is: L, I_blockchain_app_configuration_ui_payments_improvements_wallet_balances_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.ui.payments.improvements.wallet.balances.is", comment: "") }
}
public protocol I_blockchain_app_configuration_ui_payments_improvements_wallet_balances_is: I {}
public extension I_blockchain_app_configuration_ui_payments_improvements_wallet_balances_is {
	var `enabled`: L_blockchain_app_configuration_ui_payments_improvements_wallet_balances_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_ui_payments_improvements_wallet_balances_is_enabled: L, I_blockchain_app_configuration_ui_payments_improvements_wallet_balances_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.ui.payments.improvements.wallet.balances.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_ui_payments_improvements_wallet_balances_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_unified: L, I_blockchain_app_configuration_unified {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.unified", comment: "") }
}
public protocol I_blockchain_app_configuration_unified: I {}
public extension I_blockchain_app_configuration_unified {
	var `balance`: L_blockchain_app_configuration_unified_balance { .init("\(__).balance") }
	var `sign_in`: L_blockchain_app_configuration_unified_sign__in { .init("\(__).sign_in") }
}
public final class L_blockchain_app_configuration_unified_balance: L, I_blockchain_app_configuration_unified_balance {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.unified.balance", comment: "") }
}
public protocol I_blockchain_app_configuration_unified_balance: I {}
public extension I_blockchain_app_configuration_unified_balance {
	var `coincore`: L_blockchain_app_configuration_unified_balance_coincore { .init("\(__).coincore") }
}
public final class L_blockchain_app_configuration_unified_balance_coincore: L, I_blockchain_app_configuration_unified_balance_coincore {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.unified.balance.coincore", comment: "") }
}
public protocol I_blockchain_app_configuration_unified_balance_coincore: I {}
public extension I_blockchain_app_configuration_unified_balance_coincore {
	var `is`: L_blockchain_app_configuration_unified_balance_coincore_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_unified_balance_coincore_is: L, I_blockchain_app_configuration_unified_balance_coincore_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.unified.balance.coincore.is", comment: "") }
}
public protocol I_blockchain_app_configuration_unified_balance_coincore_is: I {}
public extension I_blockchain_app_configuration_unified_balance_coincore_is {
	var `enabled`: L_blockchain_app_configuration_unified_balance_coincore_is_enabled { .init("\(__).enabled") }
	var `setup`: L_blockchain_app_configuration_unified_balance_coincore_is_setup { .init("\(__).setup") }
}
public final class L_blockchain_app_configuration_unified_balance_coincore_is_enabled: L, I_blockchain_app_configuration_unified_balance_coincore_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.unified.balance.coincore.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_unified_balance_coincore_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_unified_balance_coincore_is_setup: L, I_blockchain_app_configuration_unified_balance_coincore_is_setup {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.unified.balance.coincore.is.setup", comment: "") }
}
public protocol I_blockchain_app_configuration_unified_balance_coincore_is_setup: I_blockchain_db_type_boolean {}
public final class L_blockchain_app_configuration_unified_sign__in: L, I_blockchain_app_configuration_unified_sign__in {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.unified.sign_in", comment: "") }
}
public protocol I_blockchain_app_configuration_unified_sign__in: I {}
public extension I_blockchain_app_configuration_unified_sign__in {
	var `is`: L_blockchain_app_configuration_unified_sign__in_is { .init("\(__).is") }
}
public final class L_blockchain_app_configuration_unified_sign__in_is: L, I_blockchain_app_configuration_unified_sign__in_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.unified.sign_in.is", comment: "") }
}
public protocol I_blockchain_app_configuration_unified_sign__in_is: I {}
public extension I_blockchain_app_configuration_unified_sign__in_is {
	var `enabled`: L_blockchain_app_configuration_unified_sign__in_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_configuration_unified_sign__in_is_enabled: L, I_blockchain_app_configuration_unified_sign__in_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.unified.sign_in.is.enabled", comment: "") }
}
public protocol I_blockchain_app_configuration_unified_sign__in_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_unspent: L, I_blockchain_app_configuration_unspent {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.unspent", comment: "") }
}
public protocol I_blockchain_app_configuration_unspent: I {}
public extension I_blockchain_app_configuration_unspent {
	var `outputs`: L_blockchain_app_configuration_unspent_outputs { .init("\(__).outputs") }
}
public final class L_blockchain_app_configuration_unspent_outputs: L, I_blockchain_app_configuration_unspent_outputs {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.unspent.outputs", comment: "") }
}
public protocol I_blockchain_app_configuration_unspent_outputs: I {}
public extension I_blockchain_app_configuration_unspent_outputs {
	var `cache`: L_blockchain_app_configuration_unspent_outputs_cache { .init("\(__).cache") }
}
public final class L_blockchain_app_configuration_unspent_outputs_cache: L, I_blockchain_app_configuration_unspent_outputs_cache {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.unspent.outputs.cache", comment: "") }
}
public protocol I_blockchain_app_configuration_unspent_outputs_cache: I {}
public extension I_blockchain_app_configuration_unspent_outputs_cache {
	var `config`: L_blockchain_app_configuration_unspent_outputs_cache_config { .init("\(__).config") }
}
public final class L_blockchain_app_configuration_unspent_outputs_cache_config: L, I_blockchain_app_configuration_unspent_outputs_cache_config {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.unspent.outputs.cache.config", comment: "") }
}
public protocol I_blockchain_app_configuration_unspent_outputs_cache_config: I_blockchain_session_configuration_value {}
public final class L_blockchain_app_configuration_wallet: L, I_blockchain_app_configuration_wallet {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.wallet", comment: "") }
}
public protocol I_blockchain_app_configuration_wallet: I {}
public extension I_blockchain_app_configuration_wallet {
	var `country`: L_blockchain_app_configuration_wallet_country { .init("\(__).country") }
}
public final class L_blockchain_app_configuration_wallet_country: L, I_blockchain_app_configuration_wallet_country {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.wallet.country", comment: "") }
}
public protocol I_blockchain_app_configuration_wallet_country: I {}
public extension I_blockchain_app_configuration_wallet_country {
	var `to`: L_blockchain_app_configuration_wallet_country_to { .init("\(__).to") }
}
public final class L_blockchain_app_configuration_wallet_country_to: L, I_blockchain_app_configuration_wallet_country_to {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.wallet.country.to", comment: "") }
}
public protocol I_blockchain_app_configuration_wallet_country_to: I {}
public extension I_blockchain_app_configuration_wallet_country_to {
	var `currency`: L_blockchain_app_configuration_wallet_country_to_currency { .init("\(__).currency") }
}
public final class L_blockchain_app_configuration_wallet_country_to_currency: L, I_blockchain_app_configuration_wallet_country_to_currency {
	public override class var localized: String { NSLocalizedString("blockchain.app.configuration.wallet.country.to.currency", comment: "") }
}
public protocol I_blockchain_app_configuration_wallet_country_to_currency: I_blockchain_db_type_map, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_deep__link: L, I_blockchain_app_deep__link {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link", comment: "") }
}
public protocol I_blockchain_app_deep__link: I {}
public extension I_blockchain_app_deep__link {
	var `activity`: L_blockchain_app_deep__link_activity { .init("\(__).activity") }
	var `asset`: L_blockchain_app_deep__link_asset { .init("\(__).asset") }
	var `buy`: L_blockchain_app_deep__link_buy { .init("\(__).buy") }
	var `dsl`: L_blockchain_app_deep__link_dsl { .init("\(__).dsl") }
	var `kyc`: L_blockchain_app_deep__link_kyc { .init("\(__).kyc") }
	var `onboarding`: L_blockchain_app_deep__link_onboarding { .init("\(__).onboarding") }
	var `plaid`: L_blockchain_app_deep__link_plaid { .init("\(__).plaid") }
	var `qr`: L_blockchain_app_deep__link_qr { .init("\(__).qr") }
	var `referral`: L_blockchain_app_deep__link_referral { .init("\(__).referral") }
	var `send`: L_blockchain_app_deep__link_send { .init("\(__).send") }
	var `settings`: L_blockchain_app_deep__link_settings { .init("\(__).settings") }
	var `walletconnect`: L_blockchain_app_deep__link_walletconnect { .init("\(__).walletconnect") }
}
public final class L_blockchain_app_deep__link_activity: L, I_blockchain_app_deep__link_activity {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.activity", comment: "") }
}
public protocol I_blockchain_app_deep__link_activity: I {}
public extension I_blockchain_app_deep__link_activity {
	var `transaction`: L_blockchain_app_deep__link_activity_transaction { .init("\(__).transaction") }
}
public final class L_blockchain_app_deep__link_activity_transaction: L, I_blockchain_app_deep__link_activity_transaction {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.activity.transaction", comment: "") }
}
public protocol I_blockchain_app_deep__link_activity_transaction: I {}
public extension I_blockchain_app_deep__link_activity_transaction {
	var `id`: L_blockchain_app_deep__link_activity_transaction_id { .init("\(__).id") }
}
public final class L_blockchain_app_deep__link_activity_transaction_id: L, I_blockchain_app_deep__link_activity_transaction_id {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.activity.transaction.id", comment: "") }
}
public protocol I_blockchain_app_deep__link_activity_transaction_id: I_blockchain_db_type_string {}
public final class L_blockchain_app_deep__link_asset: L, I_blockchain_app_deep__link_asset {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.asset", comment: "") }
}
public protocol I_blockchain_app_deep__link_asset: I {}
public extension I_blockchain_app_deep__link_asset {
	var `code`: L_blockchain_app_deep__link_asset_code { .init("\(__).code") }
}
public final class L_blockchain_app_deep__link_asset_code: L, I_blockchain_app_deep__link_asset_code {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.asset.code", comment: "") }
}
public protocol I_blockchain_app_deep__link_asset_code: I_blockchain_db_type_string {}
public final class L_blockchain_app_deep__link_buy: L, I_blockchain_app_deep__link_buy {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.buy", comment: "") }
}
public protocol I_blockchain_app_deep__link_buy: I {}
public extension I_blockchain_app_deep__link_buy {
	var `amount`: L_blockchain_app_deep__link_buy_amount { .init("\(__).amount") }
	var `crypto`: L_blockchain_app_deep__link_buy_crypto { .init("\(__).crypto") }
}
public final class L_blockchain_app_deep__link_buy_amount: L, I_blockchain_app_deep__link_buy_amount {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.buy.amount", comment: "") }
}
public protocol I_blockchain_app_deep__link_buy_amount: I_blockchain_db_type_integer {}
public final class L_blockchain_app_deep__link_buy_crypto: L, I_blockchain_app_deep__link_buy_crypto {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.buy.crypto", comment: "") }
}
public protocol I_blockchain_app_deep__link_buy_crypto: I {}
public extension I_blockchain_app_deep__link_buy_crypto {
	var `code`: L_blockchain_app_deep__link_buy_crypto_code { .init("\(__).code") }
}
public final class L_blockchain_app_deep__link_buy_crypto_code: L, I_blockchain_app_deep__link_buy_crypto_code {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.buy.crypto.code", comment: "") }
}
public protocol I_blockchain_app_deep__link_buy_crypto_code: I_blockchain_db_type_string {}
public final class L_blockchain_app_deep__link_dsl: L, I_blockchain_app_deep__link_dsl {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.dsl", comment: "") }
}
public protocol I_blockchain_app_deep__link_dsl: I {}
public extension I_blockchain_app_deep__link_dsl {
	var `is`: L_blockchain_app_deep__link_dsl_is { .init("\(__).is") }
}
public final class L_blockchain_app_deep__link_dsl_is: L, I_blockchain_app_deep__link_dsl_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.dsl.is", comment: "") }
}
public protocol I_blockchain_app_deep__link_dsl_is: I {}
public extension I_blockchain_app_deep__link_dsl_is {
	var `enabled`: L_blockchain_app_deep__link_dsl_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_app_deep__link_dsl_is_enabled: L, I_blockchain_app_deep__link_dsl_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.dsl.is.enabled", comment: "") }
}
public protocol I_blockchain_app_deep__link_dsl_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_state_shared_value {}
public final class L_blockchain_app_deep__link_kyc: L, I_blockchain_app_deep__link_kyc {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.kyc", comment: "") }
}
public protocol I_blockchain_app_deep__link_kyc: I {}
public extension I_blockchain_app_deep__link_kyc {
	var `tier`: L_blockchain_app_deep__link_kyc_tier { .init("\(__).tier") }
	var `verify`: L_blockchain_app_deep__link_kyc_verify { .init("\(__).verify") }
}
public final class L_blockchain_app_deep__link_kyc_tier: L, I_blockchain_app_deep__link_kyc_tier {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.kyc.tier", comment: "") }
}
public protocol I_blockchain_app_deep__link_kyc_tier: I_blockchain_db_type_integer {}
public final class L_blockchain_app_deep__link_kyc_verify: L, I_blockchain_app_deep__link_kyc_verify {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.kyc.verify", comment: "") }
}
public protocol I_blockchain_app_deep__link_kyc_verify: I {}
public extension I_blockchain_app_deep__link_kyc_verify {
	var `email`: L_blockchain_app_deep__link_kyc_verify_email { .init("\(__).email") }
}
public final class L_blockchain_app_deep__link_kyc_verify_email: L, I_blockchain_app_deep__link_kyc_verify_email {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.kyc.verify.email", comment: "") }
}
public protocol I_blockchain_app_deep__link_kyc_verify_email: I {}
public final class L_blockchain_app_deep__link_onboarding: L, I_blockchain_app_deep__link_onboarding {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.onboarding", comment: "") }
}
public protocol I_blockchain_app_deep__link_onboarding: I {}
public extension I_blockchain_app_deep__link_onboarding {
	var `post`: L_blockchain_app_deep__link_onboarding_post { .init("\(__).post") }
}
public final class L_blockchain_app_deep__link_onboarding_post: L, I_blockchain_app_deep__link_onboarding_post {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.onboarding.post", comment: "") }
}
public protocol I_blockchain_app_deep__link_onboarding_post: I {}
public extension I_blockchain_app_deep__link_onboarding_post {
	var `sign`: L_blockchain_app_deep__link_onboarding_post_sign { .init("\(__).sign") }
}
public final class L_blockchain_app_deep__link_onboarding_post_sign: L, I_blockchain_app_deep__link_onboarding_post_sign {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.onboarding.post.sign", comment: "") }
}
public protocol I_blockchain_app_deep__link_onboarding_post_sign: I {}
public extension I_blockchain_app_deep__link_onboarding_post_sign {
	var `up`: L_blockchain_app_deep__link_onboarding_post_sign_up { .init("\(__).up") }
}
public final class L_blockchain_app_deep__link_onboarding_post_sign_up: L, I_blockchain_app_deep__link_onboarding_post_sign_up {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.onboarding.post.sign.up", comment: "") }
}
public protocol I_blockchain_app_deep__link_onboarding_post_sign_up: I {}
public final class L_blockchain_app_deep__link_plaid: L, I_blockchain_app_deep__link_plaid {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.plaid", comment: "") }
}
public protocol I_blockchain_app_deep__link_plaid: I {}
public extension I_blockchain_app_deep__link_plaid {
	var `oauth_token`: L_blockchain_app_deep__link_plaid_oauth__token { .init("\(__).oauth_token") }
}
public final class L_blockchain_app_deep__link_plaid_oauth__token: L, I_blockchain_app_deep__link_plaid_oauth__token {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.plaid.oauth_token", comment: "") }
}
public protocol I_blockchain_app_deep__link_plaid_oauth__token: I {}
public final class L_blockchain_app_deep__link_qr: L, I_blockchain_app_deep__link_qr {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.qr", comment: "") }
}
public protocol I_blockchain_app_deep__link_qr: I {}
public final class L_blockchain_app_deep__link_referral: L, I_blockchain_app_deep__link_referral {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.referral", comment: "") }
}
public protocol I_blockchain_app_deep__link_referral: I {}
public final class L_blockchain_app_deep__link_send: L, I_blockchain_app_deep__link_send {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.send", comment: "") }
}
public protocol I_blockchain_app_deep__link_send: I {}
public extension I_blockchain_app_deep__link_send {
	var `amount`: L_blockchain_app_deep__link_send_amount { .init("\(__).amount") }
	var `crypto`: L_blockchain_app_deep__link_send_crypto { .init("\(__).crypto") }
	var `destination`: L_blockchain_app_deep__link_send_destination { .init("\(__).destination") }
}
public final class L_blockchain_app_deep__link_send_amount: L, I_blockchain_app_deep__link_send_amount {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.send.amount", comment: "") }
}
public protocol I_blockchain_app_deep__link_send_amount: I_blockchain_db_type_integer {}
public final class L_blockchain_app_deep__link_send_crypto: L, I_blockchain_app_deep__link_send_crypto {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.send.crypto", comment: "") }
}
public protocol I_blockchain_app_deep__link_send_crypto: I {}
public extension I_blockchain_app_deep__link_send_crypto {
	var `code`: L_blockchain_app_deep__link_send_crypto_code { .init("\(__).code") }
}
public final class L_blockchain_app_deep__link_send_crypto_code: L, I_blockchain_app_deep__link_send_crypto_code {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.send.crypto.code", comment: "") }
}
public protocol I_blockchain_app_deep__link_send_crypto_code: I_blockchain_db_type_string {}
public final class L_blockchain_app_deep__link_send_destination: L, I_blockchain_app_deep__link_send_destination {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.send.destination", comment: "") }
}
public protocol I_blockchain_app_deep__link_send_destination: I_blockchain_db_type_string {}
public final class L_blockchain_app_deep__link_settings: L, I_blockchain_app_deep__link_settings {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.settings", comment: "") }
}
public protocol I_blockchain_app_deep__link_settings: I {}
public extension I_blockchain_app_deep__link_settings {
	var `add`: L_blockchain_app_deep__link_settings_add { .init("\(__).add") }
}
public final class L_blockchain_app_deep__link_settings_add: L, I_blockchain_app_deep__link_settings_add {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.settings.add", comment: "") }
}
public protocol I_blockchain_app_deep__link_settings_add: I {}
public extension I_blockchain_app_deep__link_settings_add {
	var `payment`: L_blockchain_app_deep__link_settings_add_payment { .init("\(__).payment") }
}
public final class L_blockchain_app_deep__link_settings_add_payment: L, I_blockchain_app_deep__link_settings_add_payment {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.settings.add.payment", comment: "") }
}
public protocol I_blockchain_app_deep__link_settings_add_payment: I {}
public extension I_blockchain_app_deep__link_settings_add_payment {
	var `method`: L_blockchain_app_deep__link_settings_add_payment_method { .init("\(__).method") }
}
public final class L_blockchain_app_deep__link_settings_add_payment_method: L, I_blockchain_app_deep__link_settings_add_payment_method {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.settings.add.payment.method", comment: "") }
}
public protocol I_blockchain_app_deep__link_settings_add_payment_method: I {}
public extension I_blockchain_app_deep__link_settings_add_payment_method {
	var `bank`: L_blockchain_app_deep__link_settings_add_payment_method_bank { .init("\(__).bank") }
	var `card`: L_blockchain_app_deep__link_settings_add_payment_method_card { .init("\(__).card") }
}
public final class L_blockchain_app_deep__link_settings_add_payment_method_bank: L, I_blockchain_app_deep__link_settings_add_payment_method_bank {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.settings.add.payment.method.bank", comment: "") }
}
public protocol I_blockchain_app_deep__link_settings_add_payment_method_bank: I {}
public final class L_blockchain_app_deep__link_settings_add_payment_method_card: L, I_blockchain_app_deep__link_settings_add_payment_method_card {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.settings.add.payment.method.card", comment: "") }
}
public protocol I_blockchain_app_deep__link_settings_add_payment_method_card: I {}
public final class L_blockchain_app_deep__link_walletconnect: L, I_blockchain_app_deep__link_walletconnect {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.walletconnect", comment: "") }
}
public protocol I_blockchain_app_deep__link_walletconnect: I {}
public extension I_blockchain_app_deep__link_walletconnect {
	var `uri`: L_blockchain_app_deep__link_walletconnect_uri { .init("\(__).uri") }
}
public final class L_blockchain_app_deep__link_walletconnect_uri: L, I_blockchain_app_deep__link_walletconnect_uri {
	public override class var localized: String { NSLocalizedString("blockchain.app.deep_link.walletconnect.uri", comment: "") }
}
public protocol I_blockchain_app_deep__link_walletconnect_uri: I_blockchain_db_type_string {}
public final class L_blockchain_app_did: L, I_blockchain_app_did {
	public override class var localized: String { NSLocalizedString("blockchain.app.did", comment: "") }
}
public protocol I_blockchain_app_did: I {}
public extension I_blockchain_app_did {
	var `finish`: L_blockchain_app_did_finish { .init("\(__).finish") }
	var `update`: L_blockchain_app_did_update { .init("\(__).update") }
}
public final class L_blockchain_app_did_finish: L, I_blockchain_app_did_finish {
	public override class var localized: String { NSLocalizedString("blockchain.app.did.finish", comment: "") }
}
public protocol I_blockchain_app_did_finish: I {}
public extension I_blockchain_app_did_finish {
	var `launching`: L_blockchain_app_did_finish_launching { .init("\(__).launching") }
}
public final class L_blockchain_app_did_finish_launching: L, I_blockchain_app_did_finish_launching {
	public override class var localized: String { NSLocalizedString("blockchain.app.did.finish.launching", comment: "") }
}
public protocol I_blockchain_app_did_finish_launching: I_blockchain_db_type_boolean {}
public final class L_blockchain_app_did_update: L, I_blockchain_app_did_update {
	public override class var localized: String { NSLocalizedString("blockchain.app.did.update", comment: "") }
}
public protocol I_blockchain_app_did_update: I_blockchain_db_type_boolean, I_blockchain_session_state_preference_value, I_blockchain_session_state_shared_value {}
public final class L_blockchain_app_dynamic: L, I_blockchain_app_dynamic {
	public override class var localized: String { NSLocalizedString("blockchain.app.dynamic", comment: "") }
}
public protocol I_blockchain_app_dynamic: I_blockchain_db_collection {}
public extension I_blockchain_app_dynamic {
	var `session`: L_blockchain_app_dynamic_session { .init("\(__).session") }
	var `ux`: L_blockchain_app_dynamic_ux { .init("\(__).ux") }
}
public final class L_blockchain_app_dynamic_session: L, I_blockchain_app_dynamic_session {
	public override class var localized: String { NSLocalizedString("blockchain.app.dynamic.session", comment: "") }
}
public protocol I_blockchain_app_dynamic_session: I {}
public extension I_blockchain_app_dynamic_session {
	var `state`: L_blockchain_app_dynamic_session_state { .init("\(__).state") }
}
public final class L_blockchain_app_dynamic_session_state: L, I_blockchain_app_dynamic_session_state {
	public override class var localized: String { NSLocalizedString("blockchain.app.dynamic.session.state", comment: "") }
}
public protocol I_blockchain_app_dynamic_session_state: I_blockchain_session_state {}
public final class L_blockchain_app_dynamic_ux: L, I_blockchain_app_dynamic_ux {
	public override class var localized: String { NSLocalizedString("blockchain.app.dynamic.ux", comment: "") }
}
public protocol I_blockchain_app_dynamic_ux: I {}
public extension I_blockchain_app_dynamic_ux {
	var `action`: L_blockchain_app_dynamic_ux_action { .init("\(__).action") }
	var `analytics`: L_blockchain_app_dynamic_ux_analytics { .init("\(__).analytics") }
}
public final class L_blockchain_app_dynamic_ux_action: L, I_blockchain_app_dynamic_ux_action {
	public override class var localized: String { NSLocalizedString("blockchain.app.dynamic.ux.action", comment: "") }
}
public protocol I_blockchain_app_dynamic_ux_action: I_blockchain_session_configuration_value, I_blockchain_ux_type_action {}
public final class L_blockchain_app_dynamic_ux_analytics: L, I_blockchain_app_dynamic_ux_analytics {
	public override class var localized: String { NSLocalizedString("blockchain.app.dynamic.ux.analytics", comment: "") }
}
public protocol I_blockchain_app_dynamic_ux_analytics: I_blockchain_ux_type_analytics {}
public final class L_blockchain_app_enter: L, I_blockchain_app_enter {
	public override class var localized: String { NSLocalizedString("blockchain.app.enter", comment: "") }
}
public protocol I_blockchain_app_enter: I {}
public extension I_blockchain_app_enter {
	var `into`: L_blockchain_app_enter_into { .init("\(__).into") }
}
public final class L_blockchain_app_enter_into: L, I_blockchain_app_enter_into {
	public override class var localized: String { NSLocalizedString("blockchain.app.enter.into", comment: "") }
}
public protocol I_blockchain_app_enter_into: I_blockchain_ux_type_story {}
public final class L_blockchain_app_environment: L, I_blockchain_app_environment {
	public override class var localized: String { NSLocalizedString("blockchain.app.environment", comment: "") }
}
public protocol I_blockchain_app_environment: I_blockchain_db_type_enum, I_blockchain_session_state_shared_value {}
public extension I_blockchain_app_environment {
	var `debug`: L_blockchain_app_environment_debug { .init("\(__).debug") }
	var `production`: L_blockchain_app_environment_production { .init("\(__).production") }
}
public final class L_blockchain_app_environment_debug: L, I_blockchain_app_environment_debug {
	public override class var localized: String { NSLocalizedString("blockchain.app.environment.debug", comment: "") }
}
public protocol I_blockchain_app_environment_debug: I {}
public final class L_blockchain_app_environment_production: L, I_blockchain_app_environment_production {
	public override class var localized: String { NSLocalizedString("blockchain.app.environment.production", comment: "") }
}
public protocol I_blockchain_app_environment_production: I {}
public final class L_blockchain_app_fraud: L, I_blockchain_app_fraud {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud", comment: "") }
}
public protocol I_blockchain_app_fraud: I {}
public extension I_blockchain_app_fraud {
	var `sardine`: L_blockchain_app_fraud_sardine { .init("\(__).sardine") }
}
public final class L_blockchain_app_fraud_sardine: L, I_blockchain_app_fraud_sardine {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine: I {}
public extension I_blockchain_app_fraud_sardine {
	var `client`: L_blockchain_app_fraud_sardine_client { .init("\(__).client") }
	var `current`: L_blockchain_app_fraud_sardine_current { .init("\(__).current") }
	var `flow`: L_blockchain_app_fraud_sardine_flow { .init("\(__).flow") }
	var `session`: L_blockchain_app_fraud_sardine_session { .init("\(__).session") }
	var `submit`: L_blockchain_app_fraud_sardine_submit { .init("\(__).submit") }
	var `supported`: L_blockchain_app_fraud_sardine_supported { .init("\(__).supported") }
	var `trigger`: L_blockchain_app_fraud_sardine_trigger { .init("\(__).trigger") }
	var `user`: L_blockchain_app_fraud_sardine_user { .init("\(__).user") }
}
public final class L_blockchain_app_fraud_sardine_client: L, I_blockchain_app_fraud_sardine_client {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.client", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_client: I {}
public extension I_blockchain_app_fraud_sardine_client {
	var `identifier`: L_blockchain_app_fraud_sardine_client_identifier { .init("\(__).identifier") }
}
public final class L_blockchain_app_fraud_sardine_client_identifier: L, I_blockchain_app_fraud_sardine_client_identifier {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.client.identifier", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_client_identifier: I_blockchain_db_type_string, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_fraud_sardine_current: L, I_blockchain_app_fraud_sardine_current {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.current", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_current: I {}
public extension I_blockchain_app_fraud_sardine_current {
	var `flow`: L_blockchain_app_fraud_sardine_current_flow { .init("\(__).flow") }
}
public final class L_blockchain_app_fraud_sardine_current_flow: L, I_blockchain_app_fraud_sardine_current_flow {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.current.flow", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_current_flow: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_app_fraud_sardine_flow: L, I_blockchain_app_fraud_sardine_flow {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.flow", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_flow: I_blockchain_db_type_any, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_fraud_sardine_session: L, I_blockchain_app_fraud_sardine_session {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.session", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_session: I_blockchain_db_type_string, I_blockchain_session_state_shared_value, I_blockchain_session_state_value {}
public final class L_blockchain_app_fraud_sardine_submit: L, I_blockchain_app_fraud_sardine_submit {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.submit", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_submit: I_blockchain_ux_type_analytics_event {}
public extension I_blockchain_app_fraud_sardine_submit {
	var `failure`: L_blockchain_app_fraud_sardine_submit_failure { .init("\(__).failure") }
	var `success`: L_blockchain_app_fraud_sardine_submit_success { .init("\(__).success") }
}
public final class L_blockchain_app_fraud_sardine_submit_failure: L, I_blockchain_app_fraud_sardine_submit_failure {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.submit.failure", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_submit_failure: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_app_fraud_sardine_submit_success: L, I_blockchain_app_fraud_sardine_submit_success {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.submit.success", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_submit_success: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_app_fraud_sardine_supported: L, I_blockchain_app_fraud_sardine_supported {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.supported", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_supported: I {}
public extension I_blockchain_app_fraud_sardine_supported {
	var `flows`: L_blockchain_app_fraud_sardine_supported_flows { .init("\(__).flows") }
}
public final class L_blockchain_app_fraud_sardine_supported_flows: L, I_blockchain_app_fraud_sardine_supported_flows {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.supported.flows", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_supported_flows: I_blockchain_db_type_array_of_strings, I_blockchain_session_state_value {}
public final class L_blockchain_app_fraud_sardine_trigger: L, I_blockchain_app_fraud_sardine_trigger {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.trigger", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_trigger: I_blockchain_db_type_any, I_blockchain_session_configuration_value {}
public final class L_blockchain_app_fraud_sardine_user: L, I_blockchain_app_fraud_sardine_user {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.user", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_user: I {}
public extension I_blockchain_app_fraud_sardine_user {
	var `identifier`: L_blockchain_app_fraud_sardine_user_identifier { .init("\(__).identifier") }
}
public final class L_blockchain_app_fraud_sardine_user_identifier: L, I_blockchain_app_fraud_sardine_user_identifier {
	public override class var localized: String { NSLocalizedString("blockchain.app.fraud.sardine.user.identifier", comment: "") }
}
public protocol I_blockchain_app_fraud_sardine_user_identifier: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_app_is: L, I_blockchain_app_is {
	public override class var localized: String { NSLocalizedString("blockchain.app.is", comment: "") }
}
public protocol I_blockchain_app_is: I {}
public extension I_blockchain_app_is {
	var `first`: L_blockchain_app_is_first { .init("\(__).first") }
	var `in`: L_blockchain_app_is_in { .init("\(__).in") }
	var `mode`: L_blockchain_app_is_mode { .init("\(__).mode") }
	var `ready`: L_blockchain_app_is_ready { .init("\(__).ready") }
}
public final class L_blockchain_app_is_first: L, I_blockchain_app_is_first {
	public override class var localized: String { NSLocalizedString("blockchain.app.is.first", comment: "") }
}
public protocol I_blockchain_app_is_first: I {}
public extension I_blockchain_app_is_first {
	var `install`: L_blockchain_app_is_first_install { .init("\(__).install") }
}
public final class L_blockchain_app_is_first_install: L, I_blockchain_app_is_first_install {
	public override class var localized: String { NSLocalizedString("blockchain.app.is.first.install", comment: "") }
}
public protocol I_blockchain_app_is_first_install: I_blockchain_db_type_boolean, I_blockchain_session_state_shared_value {}
public final class L_blockchain_app_is_in: L, I_blockchain_app_is_in {
	public override class var localized: String { NSLocalizedString("blockchain.app.is.in", comment: "") }
}
public protocol I_blockchain_app_is_in: I {}
public extension I_blockchain_app_is_in {
	var `background`: L_blockchain_app_is_in_background { .init("\(__).background") }
}
public final class L_blockchain_app_is_in_background: L, I_blockchain_app_is_in_background {
	public override class var localized: String { NSLocalizedString("blockchain.app.is.in.background", comment: "") }
}
public protocol I_blockchain_app_is_in_background: I_blockchain_db_type_boolean, I_blockchain_session_state_shared_value {}
public final class L_blockchain_app_is_mode: L, I_blockchain_app_is_mode {
	public override class var localized: String { NSLocalizedString("blockchain.app.is.mode", comment: "") }
}
public protocol I_blockchain_app_is_mode: I {}
public extension I_blockchain_app_is_mode {
	var `pkw`: L_blockchain_app_is_mode_pkw { .init("\(__).pkw") }
	var `trading`: L_blockchain_app_is_mode_trading { .init("\(__).trading") }
}
public final class L_blockchain_app_is_mode_pkw: L, I_blockchain_app_is_mode_pkw {
	public override class var localized: String { NSLocalizedString("blockchain.app.is.mode.pkw", comment: "") }
}
public protocol I_blockchain_app_is_mode_pkw: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_app_is_mode_trading: L, I_blockchain_app_is_mode_trading {
	public override class var localized: String { NSLocalizedString("blockchain.app.is.mode.trading", comment: "") }
}
public protocol I_blockchain_app_is_mode_trading: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_app_is_ready: L, I_blockchain_app_is_ready {
	public override class var localized: String { NSLocalizedString("blockchain.app.is.ready", comment: "") }
}
public protocol I_blockchain_app_is_ready: I {}
public extension I_blockchain_app_is_ready {
	var `for`: L_blockchain_app_is_ready_for { .init("\(__).for") }
}
public final class L_blockchain_app_is_ready_for: L, I_blockchain_app_is_ready_for {
	public override class var localized: String { NSLocalizedString("blockchain.app.is.ready.for", comment: "") }
}
public protocol I_blockchain_app_is_ready_for: I {}
public extension I_blockchain_app_is_ready_for {
	var `deep_link`: L_blockchain_app_is_ready_for_deep__link { .init("\(__).deep_link") }
}
public final class L_blockchain_app_is_ready_for_deep__link: L, I_blockchain_app_is_ready_for_deep__link {
	public override class var localized: String { NSLocalizedString("blockchain.app.is.ready.for.deep_link", comment: "") }
}
public protocol I_blockchain_app_is_ready_for_deep__link: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_app_launched: L, I_blockchain_app_launched {
	public override class var localized: String { NSLocalizedString("blockchain.app.launched", comment: "") }
}
public protocol I_blockchain_app_launched: I {}
public extension I_blockchain_app_launched {
	var `at`: L_blockchain_app_launched_at { .init("\(__).at") }
}
public final class L_blockchain_app_launched_at: L, I_blockchain_app_launched_at {
	public override class var localized: String { NSLocalizedString("blockchain.app.launched.at", comment: "") }
}
public protocol I_blockchain_app_launched_at: I {}
public extension I_blockchain_app_launched_at {
	var `time`: L_blockchain_app_launched_at_time { .init("\(__).time") }
}
public final class L_blockchain_app_launched_at_time: L, I_blockchain_app_launched_at_time {
	public override class var localized: String { NSLocalizedString("blockchain.app.launched.at.time", comment: "") }
}
public protocol I_blockchain_app_launched_at_time: I_blockchain_db_type_date, I_blockchain_session_state_shared_value {}
public final class L_blockchain_app_mode: L, I_blockchain_app_mode {
	public override class var localized: String { NSLocalizedString("blockchain.app.mode", comment: "") }
}
public protocol I_blockchain_app_mode: I_blockchain_session_state_preference_value {}
public extension I_blockchain_app_mode {
	var `has`: L_blockchain_app_mode_has { .init("\(__).has") }
}
public final class L_blockchain_app_mode_has: L, I_blockchain_app_mode_has {
	public override class var localized: String { NSLocalizedString("blockchain.app.mode.has", comment: "") }
}
public protocol I_blockchain_app_mode_has: I {}
public extension I_blockchain_app_mode_has {
	var `been`: L_blockchain_app_mode_has_been { .init("\(__).been") }
}
public final class L_blockchain_app_mode_has_been: L, I_blockchain_app_mode_has_been {
	public override class var localized: String { NSLocalizedString("blockchain.app.mode.has.been", comment: "") }
}
public protocol I_blockchain_app_mode_has_been: I {}
public extension I_blockchain_app_mode_has_been {
	var `force`: L_blockchain_app_mode_has_been_force { .init("\(__).force") }
}
public final class L_blockchain_app_mode_has_been_force: L, I_blockchain_app_mode_has_been_force {
	public override class var localized: String { NSLocalizedString("blockchain.app.mode.has.been.force", comment: "") }
}
public protocol I_blockchain_app_mode_has_been_force: I {}
public extension I_blockchain_app_mode_has_been_force {
	var `defaulted`: L_blockchain_app_mode_has_been_force_defaulted { .init("\(__).defaulted") }
}
public final class L_blockchain_app_mode_has_been_force_defaulted: L, I_blockchain_app_mode_has_been_force_defaulted {
	public override class var localized: String { NSLocalizedString("blockchain.app.mode.has.been.force.defaulted", comment: "") }
}
public protocol I_blockchain_app_mode_has_been_force_defaulted: I_blockchain_db_type_boolean, I_blockchain_session_state_preference_value {}
public extension I_blockchain_app_mode_has_been_force_defaulted {
	var `to`: L_blockchain_app_mode_has_been_force_defaulted_to { .init("\(__).to") }
}
public final class L_blockchain_app_mode_has_been_force_defaulted_to: L, I_blockchain_app_mode_has_been_force_defaulted_to {
	public override class var localized: String { NSLocalizedString("blockchain.app.mode.has.been.force.defaulted.to", comment: "") }
}
public protocol I_blockchain_app_mode_has_been_force_defaulted_to: I {}
public extension I_blockchain_app_mode_has_been_force_defaulted_to {
	var `mode`: L_blockchain_app_mode_has_been_force_defaulted_to_mode { .init("\(__).mode") }
}
public final class L_blockchain_app_mode_has_been_force_defaulted_to_mode: L, I_blockchain_app_mode_has_been_force_defaulted_to_mode {
	public override class var localized: String { NSLocalizedString("blockchain.app.mode.has.been.force.defaulted.to.mode", comment: "") }
}
public protocol I_blockchain_app_mode_has_been_force_defaulted_to_mode: I_blockchain_session_state_preference_value {}
public final class L_blockchain_app_number: L, I_blockchain_app_number {
	public override class var localized: String { NSLocalizedString("blockchain.app.number", comment: "") }
}
public protocol I_blockchain_app_number: I {}
public extension I_blockchain_app_number {
	var `of`: L_blockchain_app_number_of { .init("\(__).of") }
}
public final class L_blockchain_app_number_of: L, I_blockchain_app_number_of {
	public override class var localized: String { NSLocalizedString("blockchain.app.number.of", comment: "") }
}
public protocol I_blockchain_app_number_of: I {}
public extension I_blockchain_app_number_of {
	var `launches`: L_blockchain_app_number_of_launches { .init("\(__).launches") }
}
public final class L_blockchain_app_number_of_launches: L, I_blockchain_app_number_of_launches {
	public override class var localized: String { NSLocalizedString("blockchain.app.number.of.launches", comment: "") }
}
public protocol I_blockchain_app_number_of_launches: I_blockchain_db_type_integer, I_blockchain_session_state_preference_value, I_blockchain_session_state_shared_value {}
public final class L_blockchain_app_performance: L, I_blockchain_app_performance {
	public override class var localized: String { NSLocalizedString("blockchain.app.performance", comment: "") }
}
public protocol I_blockchain_app_performance: I {}
public extension I_blockchain_app_performance {
	var `trace`: L_blockchain_app_performance_trace { .init("\(__).trace") }
}
public final class L_blockchain_app_performance_trace: L, I_blockchain_app_performance_trace {
	public override class var localized: String { NSLocalizedString("blockchain.app.performance.trace", comment: "") }
}
public protocol I_blockchain_app_performance_trace: I {}
public extension I_blockchain_app_performance_trace {
	var `transaction`: L_blockchain_app_performance_trace_transaction { .init("\(__).transaction") }
}
public final class L_blockchain_app_performance_trace_transaction: L, I_blockchain_app_performance_trace_transaction {
	public override class var localized: String { NSLocalizedString("blockchain.app.performance.trace.transaction", comment: "") }
}
public protocol I_blockchain_app_performance_trace_transaction: I {}
public extension I_blockchain_app_performance_trace_transaction {
	var `start`: L_blockchain_app_performance_trace_transaction_start { .init("\(__).start") }
}
public final class L_blockchain_app_performance_trace_transaction_start: L, I_blockchain_app_performance_trace_transaction_start {
	public override class var localized: String { NSLocalizedString("blockchain.app.performance.trace.transaction.start", comment: "") }
}
public protocol I_blockchain_app_performance_trace_transaction_start: I {}
public extension I_blockchain_app_performance_trace_transaction_start {
	var `to`: L_blockchain_app_performance_trace_transaction_start_to { .init("\(__).to") }
}
public final class L_blockchain_app_performance_trace_transaction_start_to: L, I_blockchain_app_performance_trace_transaction_start_to {
	public override class var localized: String { NSLocalizedString("blockchain.app.performance.trace.transaction.start.to", comment: "") }
}
public protocol I_blockchain_app_performance_trace_transaction_start_to: I {}
public extension I_blockchain_app_performance_trace_transaction_start_to {
	var `enter`: L_blockchain_app_performance_trace_transaction_start_to_enter { .init("\(__).enter") }
}
public final class L_blockchain_app_performance_trace_transaction_start_to_enter: L, I_blockchain_app_performance_trace_transaction_start_to_enter {
	public override class var localized: String { NSLocalizedString("blockchain.app.performance.trace.transaction.start.to.enter", comment: "") }
}
public protocol I_blockchain_app_performance_trace_transaction_start_to_enter: I {}
public extension I_blockchain_app_performance_trace_transaction_start_to_enter {
	var `amount`: L_blockchain_app_performance_trace_transaction_start_to_enter_amount { .init("\(__).amount") }
}
public final class L_blockchain_app_performance_trace_transaction_start_to_enter_amount: L, I_blockchain_app_performance_trace_transaction_start_to_enter_amount {
	public override class var localized: String { NSLocalizedString("blockchain.app.performance.trace.transaction.start.to.enter.amount", comment: "") }
}
public protocol I_blockchain_app_performance_trace_transaction_start_to_enter_amount: I {}
public final class L_blockchain_app_process: L, I_blockchain_app_process {
	public override class var localized: String { NSLocalizedString("blockchain.app.process", comment: "") }
}
public protocol I_blockchain_app_process: I {}
public extension I_blockchain_app_process {
	var `deep_link`: L_blockchain_app_process_deep__link { .init("\(__).deep_link") }
}
public final class L_blockchain_app_process_deep__link: L, I_blockchain_app_process_deep__link {
	public override class var localized: String { NSLocalizedString("blockchain.app.process.deep_link", comment: "") }
}
public protocol I_blockchain_app_process_deep__link: I {}
public extension I_blockchain_app_process_deep__link {
	var `error`: L_blockchain_app_process_deep__link_error { .init("\(__).error") }
	var `url`: L_blockchain_app_process_deep__link_url { .init("\(__).url") }
}
public final class L_blockchain_app_process_deep__link_error: L, I_blockchain_app_process_deep__link_error {
	public override class var localized: String { NSLocalizedString("blockchain.app.process.deep_link.error", comment: "") }
}
public protocol I_blockchain_app_process_deep__link_error: I_blockchain_ux_type_analytics_error {}
public final class L_blockchain_app_process_deep__link_url: L, I_blockchain_app_process_deep__link_url {
	public override class var localized: String { NSLocalizedString("blockchain.app.process.deep_link.url", comment: "") }
}
public protocol I_blockchain_app_process_deep__link_url: I_blockchain_db_type_url, I_blockchain_session_state_value {}
public final class L_blockchain_app_version: L, I_blockchain_app_version {
	public override class var localized: String { NSLocalizedString("blockchain.app.version", comment: "") }
}
public protocol I_blockchain_app_version: I_blockchain_session_state_preference_value, I_blockchain_session_state_shared_value {}
public final class L_blockchain_db: L, I_blockchain_db {
	public override class var localized: String { NSLocalizedString("blockchain.db", comment: "") }
}
public protocol I_blockchain_db: I {}
public extension I_blockchain_db {
	var `array`: L_blockchain_db_array { .init("\(__).array") }
	var `collection`: L_blockchain_db_collection { .init("\(__).collection") }
	var `field`: L_blockchain_db_field { .init("\(__).field") }
	var `leaf`: L_blockchain_db_leaf { .init("\(__).leaf") }
	var `type`: L_blockchain_db_type { .init("\(__).type") }
}
public final class L_blockchain_db_array: L, I_blockchain_db_array {
	public override class var localized: String { NSLocalizedString("blockchain.db.array", comment: "") }
}
public protocol I_blockchain_db_array: I {}
public final class L_blockchain_db_collection: L, I_blockchain_db_collection {
	public override class var localized: String { NSLocalizedString("blockchain.db.collection", comment: "") }
}
public protocol I_blockchain_db_collection: I {}
public extension I_blockchain_db_collection {
	var `id`: L_blockchain_db_collection_id { .init("\(__).id") }
}
public final class L_blockchain_db_collection_id: L, I_blockchain_db_collection_id {
	public override class var localized: String { NSLocalizedString("blockchain.db.collection.id", comment: "") }
}
public protocol I_blockchain_db_collection_id: I_blockchain_db_type_string {}
public final class L_blockchain_db_field: L, I_blockchain_db_field {
	public override class var localized: String { NSLocalizedString("blockchain.db.field", comment: "") }
}
public protocol I_blockchain_db_field: I {}
public final class L_blockchain_db_leaf: L, I_blockchain_db_leaf {
	public override class var localized: String { NSLocalizedString("blockchain.db.leaf", comment: "") }
}
public protocol I_blockchain_db_leaf: I {}
public final class L_blockchain_db_type: L, I_blockchain_db_type {
	public override class var localized: String { NSLocalizedString("blockchain.db.type", comment: "") }
}
public protocol I_blockchain_db_type: I {}
public extension I_blockchain_db_type {
	var `any`: L_blockchain_db_type_any { .init("\(__).any") }
	var `array`: L_blockchain_db_type_array { .init("\(__).array") }
	var `bigint`: L_blockchain_db_type_bigint { .init("\(__).bigint") }
	var `boolean`: L_blockchain_db_type_boolean { .init("\(__).boolean") }
	var `data`: L_blockchain_db_type_data { .init("\(__).data") }
	var `date`: L_blockchain_db_type_date { .init("\(__).date") }
	var `enum`: L_blockchain_db_type_enum { .init("\(__).enum") }
	var `integer`: L_blockchain_db_type_integer { .init("\(__).integer") }
	var `map`: L_blockchain_db_type_map { .init("\(__).map") }
	var `number`: L_blockchain_db_type_number { .init("\(__).number") }
	var `string`: L_blockchain_db_type_string { .init("\(__).string") }
	var `tag`: L_blockchain_db_type_tag { .init("\(__).tag") }
	var `url`: L_blockchain_db_type_url { .init("\(__).url") }
}
public final class L_blockchain_db_type_any: L, I_blockchain_db_type_any {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.any", comment: "") }
}
public protocol I_blockchain_db_type_any: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_array: L, I_blockchain_db_type_array {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array", comment: "") }
}
public protocol I_blockchain_db_type_array: I {}
public extension I_blockchain_db_type_array {
	var `of`: L_blockchain_db_type_array_of { .init("\(__).of") }
}
public final class L_blockchain_db_type_array_of: L, I_blockchain_db_type_array_of {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of", comment: "") }
}
public protocol I_blockchain_db_type_array_of: I {}
public extension I_blockchain_db_type_array_of {
	var `booleans`: L_blockchain_db_type_array_of_booleans { .init("\(__).booleans") }
	var `dates`: L_blockchain_db_type_array_of_dates { .init("\(__).dates") }
	var `integers`: L_blockchain_db_type_array_of_integers { .init("\(__).integers") }
	var `maps`: L_blockchain_db_type_array_of_maps { .init("\(__).maps") }
	var `numbers`: L_blockchain_db_type_array_of_numbers { .init("\(__).numbers") }
	var `strings`: L_blockchain_db_type_array_of_strings { .init("\(__).strings") }
	var `tags`: L_blockchain_db_type_array_of_tags { .init("\(__).tags") }
	var `urls`: L_blockchain_db_type_array_of_urls { .init("\(__).urls") }
}
public final class L_blockchain_db_type_array_of_booleans: L, I_blockchain_db_type_array_of_booleans {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of.booleans", comment: "") }
}
public protocol I_blockchain_db_type_array_of_booleans: I_blockchain_db_array {}
public final class L_blockchain_db_type_array_of_dates: L, I_blockchain_db_type_array_of_dates {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of.dates", comment: "") }
}
public protocol I_blockchain_db_type_array_of_dates: I_blockchain_db_array {}
public final class L_blockchain_db_type_array_of_integers: L, I_blockchain_db_type_array_of_integers {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of.integers", comment: "") }
}
public protocol I_blockchain_db_type_array_of_integers: I_blockchain_db_array {}
public final class L_blockchain_db_type_array_of_maps: L, I_blockchain_db_type_array_of_maps {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of.maps", comment: "") }
}
public protocol I_blockchain_db_type_array_of_maps: I_blockchain_db_array {}
public final class L_blockchain_db_type_array_of_numbers: L, I_blockchain_db_type_array_of_numbers {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of.numbers", comment: "") }
}
public protocol I_blockchain_db_type_array_of_numbers: I_blockchain_db_array {}
public final class L_blockchain_db_type_array_of_strings: L, I_blockchain_db_type_array_of_strings {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of.strings", comment: "") }
}
public protocol I_blockchain_db_type_array_of_strings: I_blockchain_db_array {}
public final class L_blockchain_db_type_array_of_tags: L, I_blockchain_db_type_array_of_tags {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of.tags", comment: "") }
}
public protocol I_blockchain_db_type_array_of_tags: I_blockchain_db_array {}
public final class L_blockchain_db_type_array_of_urls: L, I_blockchain_db_type_array_of_urls {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.array.of.urls", comment: "") }
}
public protocol I_blockchain_db_type_array_of_urls: I_blockchain_db_array {}
public final class L_blockchain_db_type_bigint: L, I_blockchain_db_type_bigint {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.bigint", comment: "") }
}
public protocol I_blockchain_db_type_bigint: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_boolean: L, I_blockchain_db_type_boolean {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.boolean", comment: "") }
}
public protocol I_blockchain_db_type_boolean: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_data: L, I_blockchain_db_type_data {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.data", comment: "") }
}
public protocol I_blockchain_db_type_data: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_date: L, I_blockchain_db_type_date {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.date", comment: "") }
}
public protocol I_blockchain_db_type_date: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_enum: L, I_blockchain_db_type_enum {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.enum", comment: "") }
}
public protocol I_blockchain_db_type_enum: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_integer: L, I_blockchain_db_type_integer {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.integer", comment: "") }
}
public protocol I_blockchain_db_type_integer: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_map: L, I_blockchain_db_type_map {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.map", comment: "") }
}
public protocol I_blockchain_db_type_map: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_number: L, I_blockchain_db_type_number {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.number", comment: "") }
}
public protocol I_blockchain_db_type_number: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_string: L, I_blockchain_db_type_string {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.string", comment: "") }
}
public protocol I_blockchain_db_type_string: I_blockchain_db_leaf {}
public final class L_blockchain_db_type_tag: L, I_blockchain_db_type_tag {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.tag", comment: "") }
}
public protocol I_blockchain_db_type_tag: I_blockchain_db_leaf {}
public extension I_blockchain_db_type_tag {
	var `none`: L_blockchain_db_type_tag_none { .init("\(__).none") }
}
public final class L_blockchain_db_type_tag_none: L, I_blockchain_db_type_tag_none {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.tag.none", comment: "") }
}
public protocol I_blockchain_db_type_tag_none: I {}
public final class L_blockchain_db_type_url: L, I_blockchain_db_type_url {
	public override class var localized: String { NSLocalizedString("blockchain.db.type.url", comment: "") }
}
public protocol I_blockchain_db_type_url: I_blockchain_db_leaf {}
public final class L_blockchain_nabu: L, I_blockchain_nabu {
	public override class var localized: String { NSLocalizedString("blockchain.nabu", comment: "") }
}
public protocol I_blockchain_nabu: I {}
public extension I_blockchain_nabu {
	var `error`: L_blockchain_nabu_error { .init("\(__).error") }
}
public final class L_blockchain_nabu_error: L, I_blockchain_nabu_error {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error", comment: "") }
}
public protocol I_blockchain_nabu_error: I {}
public extension I_blockchain_nabu_error {
	var `payment`: L_blockchain_nabu_error_payment { .init("\(__).payment") }
}
public final class L_blockchain_nabu_error_payment: L, I_blockchain_nabu_error_payment {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment", comment: "") }
}
public protocol I_blockchain_nabu_error_payment: I {}
public extension I_blockchain_nabu_error_payment {
	var `card`: L_blockchain_nabu_error_payment_card { .init("\(__).card") }
}
public final class L_blockchain_nabu_error_payment_card: L, I_blockchain_nabu_error_payment_card {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card: I {}
public extension I_blockchain_nabu_error_payment_card {
	var `authorization`: L_blockchain_nabu_error_payment_card_authorization { .init("\(__).authorization") }
	var `blocked`: L_blockchain_nabu_error_payment_card_blocked { .init("\(__).blocked") }
	var `declined`: L_blockchain_nabu_error_payment_card_declined { .init("\(__).declined") }
	var `failed`: L_blockchain_nabu_error_payment_card_failed { .init("\(__).failed") }
	var `has`: L_blockchain_nabu_error_payment_card_has { .init("\(__).has") }
	var `information`: L_blockchain_nabu_error_payment_card_information { .init("\(__).information") }
	var `system`: L_blockchain_nabu_error_payment_card_system { .init("\(__).system") }
}
public final class L_blockchain_nabu_error_payment_card_authorization: L, I_blockchain_nabu_error_payment_card_authorization {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.authorization", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_authorization: I {}
public extension I_blockchain_nabu_error_payment_card_authorization {
	var `declined`: L_blockchain_nabu_error_payment_card_authorization_declined { .init("\(__).declined") }
	var `expired`: L_blockchain_nabu_error_payment_card_authorization_expired { .init("\(__).expired") }
}
public final class L_blockchain_nabu_error_payment_card_authorization_declined: L, I_blockchain_nabu_error_payment_card_authorization_declined {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.authorization.declined", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_authorization_declined: I {}
public final class L_blockchain_nabu_error_payment_card_authorization_expired: L, I_blockchain_nabu_error_payment_card_authorization_expired {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.authorization.expired", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_authorization_expired: I {}
public final class L_blockchain_nabu_error_payment_card_blocked: L, I_blockchain_nabu_error_payment_card_blocked {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.blocked", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_blocked: I {}
public extension I_blockchain_nabu_error_payment_card_blocked {
	var `suspected`: L_blockchain_nabu_error_payment_card_blocked_suspected { .init("\(__).suspected") }
}
public final class L_blockchain_nabu_error_payment_card_blocked_suspected: L, I_blockchain_nabu_error_payment_card_blocked_suspected {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.blocked.suspected", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_blocked_suspected: I {}
public extension I_blockchain_nabu_error_payment_card_blocked_suspected {
	var `fraud`: L_blockchain_nabu_error_payment_card_blocked_suspected_fraud { .init("\(__).fraud") }
}
public final class L_blockchain_nabu_error_payment_card_blocked_suspected_fraud: L, I_blockchain_nabu_error_payment_card_blocked_suspected_fraud {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.blocked.suspected.fraud", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_blocked_suspected_fraud: I {}
public final class L_blockchain_nabu_error_payment_card_declined: L, I_blockchain_nabu_error_payment_card_declined {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined: I {}
public extension I_blockchain_nabu_error_payment_card_declined {
	var `by`: L_blockchain_nabu_error_payment_card_declined_by { .init("\(__).by") }
}
public final class L_blockchain_nabu_error_payment_card_declined_by: L, I_blockchain_nabu_error_payment_card_declined_by {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined.by", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined_by: I {}
public extension I_blockchain_nabu_error_payment_card_declined_by {
	var `bank`: L_blockchain_nabu_error_payment_card_declined_by_bank { .init("\(__).bank") }
}
public final class L_blockchain_nabu_error_payment_card_declined_by_bank: L, I_blockchain_nabu_error_payment_card_declined_by_bank {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined.by.bank", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined_by_bank: I {}
public extension I_blockchain_nabu_error_payment_card_declined_by_bank {
	var `should`: L_blockchain_nabu_error_payment_card_declined_by_bank_should { .init("\(__).should") }
}
public final class L_blockchain_nabu_error_payment_card_declined_by_bank_should: L, I_blockchain_nabu_error_payment_card_declined_by_bank_should {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined.by.bank.should", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined_by_bank_should: I {}
public extension I_blockchain_nabu_error_payment_card_declined_by_bank_should {
	var `not`: L_blockchain_nabu_error_payment_card_declined_by_bank_should_not { .init("\(__).not") }
	var `retry`: L_blockchain_nabu_error_payment_card_declined_by_bank_should_retry { .init("\(__).retry") }
}
public final class L_blockchain_nabu_error_payment_card_declined_by_bank_should_not: L, I_blockchain_nabu_error_payment_card_declined_by_bank_should_not {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined.by.bank.should.not", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined_by_bank_should_not: I {}
public extension I_blockchain_nabu_error_payment_card_declined_by_bank_should_not {
	var `retry`: L_blockchain_nabu_error_payment_card_declined_by_bank_should_not_retry { .init("\(__).retry") }
}
public final class L_blockchain_nabu_error_payment_card_declined_by_bank_should_not_retry: L, I_blockchain_nabu_error_payment_card_declined_by_bank_should_not_retry {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined.by.bank.should.not.retry", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined_by_bank_should_not_retry: I {}
public final class L_blockchain_nabu_error_payment_card_declined_by_bank_should_retry: L, I_blockchain_nabu_error_payment_card_declined_by_bank_should_retry {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined.by.bank.should.retry", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined_by_bank_should_retry: I {}
public extension I_blockchain_nabu_error_payment_card_declined_by_bank_should_retry {
	var `immediately`: L_blockchain_nabu_error_payment_card_declined_by_bank_should_retry_immediately { .init("\(__).immediately") }
	var `later`: L_blockchain_nabu_error_payment_card_declined_by_bank_should_retry_later { .init("\(__).later") }
}
public final class L_blockchain_nabu_error_payment_card_declined_by_bank_should_retry_immediately: L, I_blockchain_nabu_error_payment_card_declined_by_bank_should_retry_immediately {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined.by.bank.should.retry.immediately", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined_by_bank_should_retry_immediately: I {}
public final class L_blockchain_nabu_error_payment_card_declined_by_bank_should_retry_later: L, I_blockchain_nabu_error_payment_card_declined_by_bank_should_retry_later {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.declined.by.bank.should.retry.later", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_declined_by_bank_should_retry_later: I {}
public final class L_blockchain_nabu_error_payment_card_failed: L, I_blockchain_nabu_error_payment_card_failed {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.failed", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_failed: I {}
public extension I_blockchain_nabu_error_payment_card_failed {
	var `should`: L_blockchain_nabu_error_payment_card_failed_should { .init("\(__).should") }
}
public final class L_blockchain_nabu_error_payment_card_failed_should: L, I_blockchain_nabu_error_payment_card_failed_should {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.failed.should", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_failed_should: I {}
public extension I_blockchain_nabu_error_payment_card_failed_should {
	var `not`: L_blockchain_nabu_error_payment_card_failed_should_not { .init("\(__).not") }
	var `retry`: L_blockchain_nabu_error_payment_card_failed_should_retry { .init("\(__).retry") }
}
public final class L_blockchain_nabu_error_payment_card_failed_should_not: L, I_blockchain_nabu_error_payment_card_failed_should_not {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.failed.should.not", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_failed_should_not: I {}
public extension I_blockchain_nabu_error_payment_card_failed_should_not {
	var `retry`: L_blockchain_nabu_error_payment_card_failed_should_not_retry { .init("\(__).retry") }
}
public final class L_blockchain_nabu_error_payment_card_failed_should_not_retry: L, I_blockchain_nabu_error_payment_card_failed_should_not_retry {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.failed.should.not.retry", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_failed_should_not_retry: I {}
public final class L_blockchain_nabu_error_payment_card_failed_should_retry: L, I_blockchain_nabu_error_payment_card_failed_should_retry {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.failed.should.retry", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_failed_should_retry: I {}
public extension I_blockchain_nabu_error_payment_card_failed_should_retry {
	var `immediately`: L_blockchain_nabu_error_payment_card_failed_should_retry_immediately { .init("\(__).immediately") }
	var `later`: L_blockchain_nabu_error_payment_card_failed_should_retry_later { .init("\(__).later") }
}
public final class L_blockchain_nabu_error_payment_card_failed_should_retry_immediately: L, I_blockchain_nabu_error_payment_card_failed_should_retry_immediately {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.failed.should.retry.immediately", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_failed_should_retry_immediately: I {}
public final class L_blockchain_nabu_error_payment_card_failed_should_retry_later: L, I_blockchain_nabu_error_payment_card_failed_should_retry_later {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.failed.should.retry.later", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_failed_should_retry_later: I {}
public final class L_blockchain_nabu_error_payment_card_has: L, I_blockchain_nabu_error_payment_card_has {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.has", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_has: I {}
public extension I_blockchain_nabu_error_payment_card_has {
	var `expired`: L_blockchain_nabu_error_payment_card_has_expired { .init("\(__).expired") }
	var `insufficient`: L_blockchain_nabu_error_payment_card_has_insufficient { .init("\(__).insufficient") }
}
public final class L_blockchain_nabu_error_payment_card_has_expired: L, I_blockchain_nabu_error_payment_card_has_expired {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.has.expired", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_has_expired: I {}
public final class L_blockchain_nabu_error_payment_card_has_insufficient: L, I_blockchain_nabu_error_payment_card_has_insufficient {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.has.insufficient", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_has_insufficient: I {}
public extension I_blockchain_nabu_error_payment_card_has_insufficient {
	var `funds`: L_blockchain_nabu_error_payment_card_has_insufficient_funds { .init("\(__).funds") }
}
public final class L_blockchain_nabu_error_payment_card_has_insufficient_funds: L, I_blockchain_nabu_error_payment_card_has_insufficient_funds {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.has.insufficient.funds", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_has_insufficient_funds: I {}
public final class L_blockchain_nabu_error_payment_card_information: L, I_blockchain_nabu_error_payment_card_information {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information: I {}
public extension I_blockchain_nabu_error_payment_card_information {
	var `cvv`: L_blockchain_nabu_error_payment_card_information_cvv { .init("\(__).cvv") }
	var `does`: L_blockchain_nabu_error_payment_card_information_does { .init("\(__).does") }
	var `number`: L_blockchain_nabu_error_payment_card_information_number { .init("\(__).number") }
}
public final class L_blockchain_nabu_error_payment_card_information_cvv: L, I_blockchain_nabu_error_payment_card_information_cvv {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.cvv", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_cvv: I {}
public extension I_blockchain_nabu_error_payment_card_information_cvv {
	var `does`: L_blockchain_nabu_error_payment_card_information_cvv_does { .init("\(__).does") }
}
public final class L_blockchain_nabu_error_payment_card_information_cvv_does: L, I_blockchain_nabu_error_payment_card_information_cvv_does {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.cvv.does", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_cvv_does: I {}
public extension I_blockchain_nabu_error_payment_card_information_cvv_does {
	var `not`: L_blockchain_nabu_error_payment_card_information_cvv_does_not { .init("\(__).not") }
}
public final class L_blockchain_nabu_error_payment_card_information_cvv_does_not: L, I_blockchain_nabu_error_payment_card_information_cvv_does_not {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.cvv.does.not", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_cvv_does_not: I {}
public extension I_blockchain_nabu_error_payment_card_information_cvv_does_not {
	var `match`: L_blockchain_nabu_error_payment_card_information_cvv_does_not_match { .init("\(__).match") }
}
public final class L_blockchain_nabu_error_payment_card_information_cvv_does_not_match: L, I_blockchain_nabu_error_payment_card_information_cvv_does_not_match {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.cvv.does.not.match", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_cvv_does_not_match: I {}
public final class L_blockchain_nabu_error_payment_card_information_does: L, I_blockchain_nabu_error_payment_card_information_does {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.does", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_does: I {}
public extension I_blockchain_nabu_error_payment_card_information_does {
	var `not`: L_blockchain_nabu_error_payment_card_information_does_not { .init("\(__).not") }
}
public final class L_blockchain_nabu_error_payment_card_information_does_not: L, I_blockchain_nabu_error_payment_card_information_does_not {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.does.not", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_does_not: I {}
public extension I_blockchain_nabu_error_payment_card_information_does_not {
	var `match`: L_blockchain_nabu_error_payment_card_information_does_not_match { .init("\(__).match") }
}
public final class L_blockchain_nabu_error_payment_card_information_does_not_match: L, I_blockchain_nabu_error_payment_card_information_does_not_match {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.does.not.match", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_does_not_match: I {}
public final class L_blockchain_nabu_error_payment_card_information_number: L, I_blockchain_nabu_error_payment_card_information_number {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.number", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_number: I {}
public extension I_blockchain_nabu_error_payment_card_information_number {
	var `does`: L_blockchain_nabu_error_payment_card_information_number_does { .init("\(__).does") }
}
public final class L_blockchain_nabu_error_payment_card_information_number_does: L, I_blockchain_nabu_error_payment_card_information_number_does {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.number.does", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_number_does: I {}
public extension I_blockchain_nabu_error_payment_card_information_number_does {
	var `not`: L_blockchain_nabu_error_payment_card_information_number_does_not { .init("\(__).not") }
}
public final class L_blockchain_nabu_error_payment_card_information_number_does_not: L, I_blockchain_nabu_error_payment_card_information_number_does_not {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.number.does.not", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_number_does_not: I {}
public extension I_blockchain_nabu_error_payment_card_information_number_does_not {
	var `match`: L_blockchain_nabu_error_payment_card_information_number_does_not_match { .init("\(__).match") }
}
public final class L_blockchain_nabu_error_payment_card_information_number_does_not_match: L, I_blockchain_nabu_error_payment_card_information_number_does_not_match {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.information.number.does.not.match", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_information_number_does_not_match: I {}
public final class L_blockchain_nabu_error_payment_card_system: L, I_blockchain_nabu_error_payment_card_system {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.system", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_system: I {}
public extension I_blockchain_nabu_error_payment_card_system {
	var `failure`: L_blockchain_nabu_error_payment_card_system_failure { .init("\(__).failure") }
}
public final class L_blockchain_nabu_error_payment_card_system_failure: L, I_blockchain_nabu_error_payment_card_system_failure {
	public override class var localized: String { NSLocalizedString("blockchain.nabu.error.payment.card.system.failure", comment: "") }
}
public protocol I_blockchain_nabu_error_payment_card_system_failure: I {}
public final class L_blockchain_namespace: L, I_blockchain_namespace {
	public override class var localized: String { NSLocalizedString("blockchain.namespace", comment: "") }
}
public protocol I_blockchain_namespace: I {}
public extension I_blockchain_namespace {
	var `language`: L_blockchain_namespace_language { .init("\(__).language") }
	var `test`: L_blockchain_namespace_test { .init("\(__).test") }
}
public final class L_blockchain_namespace_language: L, I_blockchain_namespace_language {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.language", comment: "") }
}
public protocol I_blockchain_namespace_language: I {}
public extension I_blockchain_namespace_language {
	var `error`: L_blockchain_namespace_language_error { .init("\(__).error") }
	var `state`: L_blockchain_namespace_language_state { .init("\(__).state") }
	var `taskpaper`: L_blockchain_namespace_language_taskpaper { .init("\(__).taskpaper") }
}
public final class L_blockchain_namespace_language_error: L, I_blockchain_namespace_language_error {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.language.error", comment: "") }
}
public protocol I_blockchain_namespace_language_error: I_blockchain_ux_type_analytics_error {}
public final class L_blockchain_namespace_language_state: L, I_blockchain_namespace_language_state {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.language.state", comment: "") }
}
public protocol I_blockchain_namespace_language_state: I_blockchain_db_type_enum, I_blockchain_session_state_value {}
public extension I_blockchain_namespace_language_state {
	var `grammar`: L_blockchain_namespace_language_state_grammar { .init("\(__).grammar") }
	var `language`: L_blockchain_namespace_language_state_language { .init("\(__).language") }
}
public final class L_blockchain_namespace_language_state_grammar: L, I_blockchain_namespace_language_state_grammar {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.language.state.grammar", comment: "") }
}
public protocol I_blockchain_namespace_language_state_grammar: I {}
public final class L_blockchain_namespace_language_state_language: L, I_blockchain_namespace_language_state_language {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.language.state.language", comment: "") }
}
public protocol I_blockchain_namespace_language_state_language: I {}
public final class L_blockchain_namespace_language_taskpaper: L, I_blockchain_namespace_language_taskpaper {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.language.taskpaper", comment: "") }
}
public protocol I_blockchain_namespace_language_taskpaper: I_blockchain_db_type_any, I_blockchain_session_configuration_value {}
public final class L_blockchain_namespace_test: L, I_blockchain_namespace_test {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.test", comment: "") }
}
public protocol I_blockchain_namespace_test: I {}
public extension I_blockchain_namespace_test {
	var `session`: L_blockchain_namespace_test_session { .init("\(__).session") }
}
public final class L_blockchain_namespace_test_session: L, I_blockchain_namespace_test_session {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.test.session", comment: "") }
}
public protocol I_blockchain_namespace_test_session: I {}
public extension I_blockchain_namespace_test_session {
	var `state`: L_blockchain_namespace_test_session_state { .init("\(__).state") }
}
public final class L_blockchain_namespace_test_session_state: L, I_blockchain_namespace_test_session_state {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.test.session.state", comment: "") }
}
public protocol I_blockchain_namespace_test_session_state: I {}
public extension I_blockchain_namespace_test_session_state {
	var `stored`: L_blockchain_namespace_test_session_state_stored { .init("\(__).stored") }
}
public final class L_blockchain_namespace_test_session_state_stored: L, I_blockchain_namespace_test_session_state_stored {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.test.session.state.stored", comment: "") }
}
public protocol I_blockchain_namespace_test_session_state_stored: I {}
public extension I_blockchain_namespace_test_session_state_stored {
	var `shared`: L_blockchain_namespace_test_session_state_stored_shared { .init("\(__).shared") }
	var `user`: L_blockchain_namespace_test_session_state_stored_user { .init("\(__).user") }
}
public final class L_blockchain_namespace_test_session_state_stored_shared: L, I_blockchain_namespace_test_session_state_stored_shared {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.test.session.state.stored.shared", comment: "") }
}
public protocol I_blockchain_namespace_test_session_state_stored_shared: I {}
public extension I_blockchain_namespace_test_session_state_stored_shared {
	var `value`: L_blockchain_namespace_test_session_state_stored_shared_value { .init("\(__).value") }
}
public final class L_blockchain_namespace_test_session_state_stored_shared_value: L, I_blockchain_namespace_test_session_state_stored_shared_value {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.test.session.state.stored.shared.value", comment: "") }
}
public protocol I_blockchain_namespace_test_session_state_stored_shared_value: I_blockchain_session_state_shared_value, I_blockchain_session_state_stored_value {}
public final class L_blockchain_namespace_test_session_state_stored_user: L, I_blockchain_namespace_test_session_state_stored_user {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.test.session.state.stored.user", comment: "") }
}
public protocol I_blockchain_namespace_test_session_state_stored_user: I {}
public extension I_blockchain_namespace_test_session_state_stored_user {
	var `value`: L_blockchain_namespace_test_session_state_stored_user_value { .init("\(__).value") }
}
public final class L_blockchain_namespace_test_session_state_stored_user_value: L, I_blockchain_namespace_test_session_state_stored_user_value {
	public override class var localized: String { NSLocalizedString("blockchain.namespace.test.session.state.stored.user.value", comment: "") }
}
public protocol I_blockchain_namespace_test_session_state_stored_user_value: I_blockchain_session_state_stored_value {}
public final class L_blockchain_session: L, I_blockchain_session {
	public override class var localized: String { NSLocalizedString("blockchain.session", comment: "") }
}
public protocol I_blockchain_session: I {}
public extension I_blockchain_session {
	var `configuration`: L_blockchain_session_configuration { .init("\(__).configuration") }
	var `event`: L_blockchain_session_event { .init("\(__).event") }
	var `state`: L_blockchain_session_state { .init("\(__).state") }
}
public final class L_blockchain_session_configuration: L, I_blockchain_session_configuration {
	public override class var localized: String { NSLocalizedString("blockchain.session.configuration", comment: "") }
}
public protocol I_blockchain_session_configuration: I {}
public extension I_blockchain_session_configuration {
	var `value`: L_blockchain_session_configuration_value { .init("\(__).value") }
}
public final class L_blockchain_session_configuration_value: L, I_blockchain_session_configuration_value {
	public override class var localized: String { NSLocalizedString("blockchain.session.configuration.value", comment: "") }
}
public protocol I_blockchain_session_configuration_value: I {}
public final class L_blockchain_session_event: L, I_blockchain_session_event {
	public override class var localized: String { NSLocalizedString("blockchain.session.event", comment: "") }
}
public protocol I_blockchain_session_event: I {}
public extension I_blockchain_session_event {
	var `did`: L_blockchain_session_event_did { .init("\(__).did") }
	var `will`: L_blockchain_session_event_will { .init("\(__).will") }
}
public final class L_blockchain_session_event_did: L, I_blockchain_session_event_did {
	public override class var localized: String { NSLocalizedString("blockchain.session.event.did", comment: "") }
}
public protocol I_blockchain_session_event_did: I {}
public extension I_blockchain_session_event_did {
	var `sign`: L_blockchain_session_event_did_sign { .init("\(__).sign") }
}
public final class L_blockchain_session_event_did_sign: L, I_blockchain_session_event_did_sign {
	public override class var localized: String { NSLocalizedString("blockchain.session.event.did.sign", comment: "") }
}
public protocol I_blockchain_session_event_did_sign: I {}
public extension I_blockchain_session_event_did_sign {
	var `in`: L_blockchain_session_event_did_sign_in { .init("\(__).in") }
	var `out`: L_blockchain_session_event_did_sign_out { .init("\(__).out") }
}
public final class L_blockchain_session_event_did_sign_in: L, I_blockchain_session_event_did_sign_in {
	public override class var localized: String { NSLocalizedString("blockchain.session.event.did.sign.in", comment: "") }
}
public protocol I_blockchain_session_event_did_sign_in: I_blockchain_ux_type_analytics_state {}
public final class L_blockchain_session_event_did_sign_out: L, I_blockchain_session_event_did_sign_out {
	public override class var localized: String { NSLocalizedString("blockchain.session.event.did.sign.out", comment: "") }
}
public protocol I_blockchain_session_event_did_sign_out: I_blockchain_ux_type_analytics_state {}
public final class L_blockchain_session_event_will: L, I_blockchain_session_event_will {
	public override class var localized: String { NSLocalizedString("blockchain.session.event.will", comment: "") }
}
public protocol I_blockchain_session_event_will: I {}
public extension I_blockchain_session_event_will {
	var `sign`: L_blockchain_session_event_will_sign { .init("\(__).sign") }
}
public final class L_blockchain_session_event_will_sign: L, I_blockchain_session_event_will_sign {
	public override class var localized: String { NSLocalizedString("blockchain.session.event.will.sign", comment: "") }
}
public protocol I_blockchain_session_event_will_sign: I {}
public extension I_blockchain_session_event_will_sign {
	var `in`: L_blockchain_session_event_will_sign_in { .init("\(__).in") }
	var `out`: L_blockchain_session_event_will_sign_out { .init("\(__).out") }
}
public final class L_blockchain_session_event_will_sign_in: L, I_blockchain_session_event_will_sign_in {
	public override class var localized: String { NSLocalizedString("blockchain.session.event.will.sign.in", comment: "") }
}
public protocol I_blockchain_session_event_will_sign_in: I_blockchain_ux_type_analytics_state {}
public final class L_blockchain_session_event_will_sign_out: L, I_blockchain_session_event_will_sign_out {
	public override class var localized: String { NSLocalizedString("blockchain.session.event.will.sign.out", comment: "") }
}
public protocol I_blockchain_session_event_will_sign_out: I_blockchain_ux_type_analytics_state {}
public final class L_blockchain_session_state: L, I_blockchain_session_state {
	public override class var localized: String { NSLocalizedString("blockchain.session.state", comment: "") }
}
public protocol I_blockchain_session_state: I {}
public extension I_blockchain_session_state {
	var `key`: L_blockchain_session_state_key { .init("\(__).key") }
	var `observers`: L_blockchain_session_state_observers { .init("\(__).observers") }
	var `preference`: L_blockchain_session_state_preference { .init("\(__).preference") }
	var `shared`: L_blockchain_session_state_shared { .init("\(__).shared") }
	var `stored`: L_blockchain_session_state_stored { .init("\(__).stored") }
	var `value`: L_blockchain_session_state_value { .init("\(__).value") }
}
public final class L_blockchain_session_state_key: L, I_blockchain_session_state_key {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.key", comment: "") }
}
public protocol I_blockchain_session_state_key: I {}
public extension I_blockchain_session_state_key {
	var `value`: L_blockchain_session_state_key_value { .init("\(__).value") }
}
public final class L_blockchain_session_state_key_value: L, I_blockchain_session_state_key_value {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.key.value", comment: "") }
}
public protocol I_blockchain_session_state_key_value: I {}
public extension I_blockchain_session_state_key_value {
	var `pair`: L_blockchain_session_state_key_value_pair { .init("\(__).pair") }
}
public final class L_blockchain_session_state_key_value_pair: L, I_blockchain_session_state_key_value_pair {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.key.value.pair", comment: "") }
}
public protocol I_blockchain_session_state_key_value_pair: I {}
public extension I_blockchain_session_state_key_value_pair {
	var `key`: L_blockchain_session_state_key_value_pair_key { .init("\(__).key") }
	var `value`: L_blockchain_session_state_key_value_pair_value { .init("\(__).value") }
}
public final class L_blockchain_session_state_key_value_pair_key: L, I_blockchain_session_state_key_value_pair_key {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.key.value.pair.key", comment: "") }
}
public protocol I_blockchain_session_state_key_value_pair_key: I_blockchain_type_key {}
public final class L_blockchain_session_state_key_value_pair_value: L, I_blockchain_session_state_key_value_pair_value {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.key.value.pair.value", comment: "") }
}
public protocol I_blockchain_session_state_key_value_pair_value: I_blockchain_db_type_any {}
public final class L_blockchain_session_state_observers: L, I_blockchain_session_state_observers {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.observers", comment: "") }
}
public protocol I_blockchain_session_state_observers: I_blockchain_db_type_array_of_maps, I_blockchain_session_configuration_value {}
public extension I_blockchain_session_state_observers {
	var `action`: L_blockchain_session_state_observers_action { .init("\(__).action") }
	var `event`: L_blockchain_session_state_observers_event { .init("\(__).event") }
}
public final class L_blockchain_session_state_observers_action: L, I_blockchain_session_state_observers_action {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.observers.action", comment: "") }
}
public protocol I_blockchain_session_state_observers_action: I_blockchain_db_type_any {}
public final class L_blockchain_session_state_observers_event: L, I_blockchain_session_state_observers_event {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.observers.event", comment: "") }
}
public protocol I_blockchain_session_state_observers_event: I {}
public extension I_blockchain_session_state_observers_event {
	var `context`: L_blockchain_session_state_observers_event_context { .init("\(__).context") }
	var `tag`: L_blockchain_session_state_observers_event_tag { .init("\(__).tag") }
}
public final class L_blockchain_session_state_observers_event_context: L, I_blockchain_session_state_observers_event_context {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.observers.event.context", comment: "") }
}
public protocol I_blockchain_session_state_observers_event_context: I_blockchain_db_type_map {}
public final class L_blockchain_session_state_observers_event_tag: L, I_blockchain_session_state_observers_event_tag {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.observers.event.tag", comment: "") }
}
public protocol I_blockchain_session_state_observers_event_tag: I_blockchain_db_type_tag {}
public final class L_blockchain_session_state_preference: L, I_blockchain_session_state_preference {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.preference", comment: "") }
}
public protocol I_blockchain_session_state_preference: I {}
public extension I_blockchain_session_state_preference {
	var `value`: L_blockchain_session_state_preference_value { .init("\(__).value") }
}
public final class L_blockchain_session_state_preference_value: L, I_blockchain_session_state_preference_value {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.preference.value", comment: "") }
}
public protocol I_blockchain_session_state_preference_value: I_blockchain_session_state_value {}
public final class L_blockchain_session_state_shared: L, I_blockchain_session_state_shared {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.shared", comment: "") }
}
public protocol I_blockchain_session_state_shared: I {}
public extension I_blockchain_session_state_shared {
	var `value`: L_blockchain_session_state_shared_value { .init("\(__).value") }
}
public final class L_blockchain_session_state_shared_value: L, I_blockchain_session_state_shared_value {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.shared.value", comment: "") }
}
public protocol I_blockchain_session_state_shared_value: I_blockchain_session_state_value {}
public final class L_blockchain_session_state_stored: L, I_blockchain_session_state_stored {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.stored", comment: "") }
}
public protocol I_blockchain_session_state_stored: I {}
public extension I_blockchain_session_state_stored {
	var `value`: L_blockchain_session_state_stored_value { .init("\(__).value") }
}
public final class L_blockchain_session_state_stored_value: L, I_blockchain_session_state_stored_value {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.stored.value", comment: "") }
}
public protocol I_blockchain_session_state_stored_value: I_blockchain_session_state_value {}
public final class L_blockchain_session_state_value: L, I_blockchain_session_state_value {
	public override class var localized: String { NSLocalizedString("blockchain.session.state.value", comment: "") }
}
public protocol I_blockchain_session_state_value: I {}
public final class L_blockchain_type: L, I_blockchain_type {
	public override class var localized: String { NSLocalizedString("blockchain.type", comment: "") }
}
public protocol I_blockchain_type: I {}
public extension I_blockchain_type {
	var `currency`: L_blockchain_type_currency { .init("\(__).currency") }
	var `key`: L_blockchain_type_key { .init("\(__).key") }
	var `money`: L_blockchain_type_money { .init("\(__).money") }
}
public final class L_blockchain_type_currency: L, I_blockchain_type_currency {
	public override class var localized: String { NSLocalizedString("blockchain.type.currency", comment: "") }
}
public protocol I_blockchain_type_currency: I_blockchain_db_type_string {}
public final class L_blockchain_type_key: L, I_blockchain_type_key {
	public override class var localized: String { NSLocalizedString("blockchain.type.key", comment: "") }
}
public protocol I_blockchain_type_key: I {}
public extension I_blockchain_type_key {
	var `context`: L_blockchain_type_key_context { .init("\(__).context") }
	var `tag`: L_blockchain_type_key_tag { .init("\(__).tag") }
}
public final class L_blockchain_type_key_context: L, I_blockchain_type_key_context {
	public override class var localized: String { NSLocalizedString("blockchain.type.key.context", comment: "") }
}
public protocol I_blockchain_type_key_context: I_blockchain_db_type_array_of_maps {}
public extension I_blockchain_type_key_context {
	var `key`: L_blockchain_type_key_context_key { .init("\(__).key") }
	var `value`: L_blockchain_type_key_context_value { .init("\(__).value") }
}
public final class L_blockchain_type_key_context_key: L, I_blockchain_type_key_context_key {
	public override class var localized: String { NSLocalizedString("blockchain.type.key.context.key", comment: "") }
}
public protocol I_blockchain_type_key_context_key: I_blockchain_db_type_tag {}
public final class L_blockchain_type_key_context_value: L, I_blockchain_type_key_context_value {
	public override class var localized: String { NSLocalizedString("blockchain.type.key.context.value", comment: "") }
}
public protocol I_blockchain_type_key_context_value: I_blockchain_db_type_string {}
public final class L_blockchain_type_key_tag: L, I_blockchain_type_key_tag {
	public override class var localized: String { NSLocalizedString("blockchain.type.key.tag", comment: "") }
}
public protocol I_blockchain_type_key_tag: I_blockchain_db_type_tag {}
public final class L_blockchain_type_money: L, I_blockchain_type_money {
	public override class var localized: String { NSLocalizedString("blockchain.type.money", comment: "") }
}
public protocol I_blockchain_type_money: I {}
public extension I_blockchain_type_money {
	var `amount`: L_blockchain_type_money_amount { .init("\(__).amount") }
	var `currency`: L_blockchain_type_money_currency { .init("\(__).currency") }
}
public final class L_blockchain_type_money_amount: L, I_blockchain_type_money_amount {
	public override class var localized: String { NSLocalizedString("blockchain.type.money.amount", comment: "") }
}
public protocol I_blockchain_type_money_amount: I_blockchain_db_type_bigint {}
public final class L_blockchain_type_money_currency: L, I_blockchain_type_money_currency {
	public override class var localized: String { NSLocalizedString("blockchain.type.money.currency", comment: "") }
}
public protocol I_blockchain_type_money_currency: I_blockchain_type_currency {}
public final class L_blockchain_ui: L, I_blockchain_ui {
	public override class var localized: String { NSLocalizedString("blockchain.ui", comment: "") }
}
public protocol I_blockchain_ui: I {}
public extension I_blockchain_ui {
	var `device`: L_blockchain_ui_device { .init("\(__).device") }
	var `type`: L_blockchain_ui_type { .init("\(__).type") }
}
public final class L_blockchain_ui_device: L, I_blockchain_ui_device {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device", comment: "") }
}
public protocol I_blockchain_ui_device: I {}
public extension I_blockchain_ui_device {
	var `connection`: L_blockchain_ui_device_connection { .init("\(__).connection") }
	var `current`: L_blockchain_ui_device_current { .init("\(__).current") }
	var `haptic`: L_blockchain_ui_device_haptic { .init("\(__).haptic") }
	var `id`: L_blockchain_ui_device_id { .init("\(__).id") }
	var `locale`: L_blockchain_ui_device_locale { .init("\(__).locale") }
	var `os`: L_blockchain_ui_device_os { .init("\(__).os") }
	var `settings`: L_blockchain_ui_device_settings { .init("\(__).settings") }
}
public final class L_blockchain_ui_device_connection: L, I_blockchain_ui_device_connection {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.connection", comment: "") }
}
public protocol I_blockchain_ui_device_connection: I_blockchain_db_type_enum, I_blockchain_session_state_shared_value {}
public extension I_blockchain_ui_device_connection {
	var `cellular`: L_blockchain_ui_device_connection_cellular { .init("\(__).cellular") }
	var `unavailable`: L_blockchain_ui_device_connection_unavailable { .init("\(__).unavailable") }
	var `WiFi`: L_blockchain_ui_device_connection_WiFi { .init("\(__).WiFi") }
}
public final class L_blockchain_ui_device_connection_cellular: L, I_blockchain_ui_device_connection_cellular {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.connection.cellular", comment: "") }
}
public protocol I_blockchain_ui_device_connection_cellular: I {}
public final class L_blockchain_ui_device_connection_unavailable: L, I_blockchain_ui_device_connection_unavailable {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.connection.unavailable", comment: "") }
}
public protocol I_blockchain_ui_device_connection_unavailable: I {}
public final class L_blockchain_ui_device_connection_WiFi: L, I_blockchain_ui_device_connection_WiFi {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.connection.WiFi", comment: "") }
}
public protocol I_blockchain_ui_device_connection_WiFi: I {}
public final class L_blockchain_ui_device_current: L, I_blockchain_ui_device_current {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.current", comment: "") }
}
public protocol I_blockchain_ui_device_current: I {}
public extension I_blockchain_ui_device_current {
	var `local`: L_blockchain_ui_device_current_local { .init("\(__).local") }
}
public final class L_blockchain_ui_device_current_local: L, I_blockchain_ui_device_current_local {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.current.local", comment: "") }
}
public protocol I_blockchain_ui_device_current_local: I {}
public extension I_blockchain_ui_device_current_local {
	var `time`: L_blockchain_ui_device_current_local_time { .init("\(__).time") }
}
public final class L_blockchain_ui_device_current_local_time: L, I_blockchain_ui_device_current_local_time {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.current.local.time", comment: "") }
}
public protocol I_blockchain_ui_device_current_local_time: I_blockchain_db_type_date, I_blockchain_session_state_shared_value {}
public final class L_blockchain_ui_device_haptic: L, I_blockchain_ui_device_haptic {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.haptic", comment: "") }
}
public protocol I_blockchain_ui_device_haptic: I {}
public extension I_blockchain_ui_device_haptic {
	var `feedback`: L_blockchain_ui_device_haptic_feedback { .init("\(__).feedback") }
}
public final class L_blockchain_ui_device_haptic_feedback: L, I_blockchain_ui_device_haptic_feedback {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.haptic.feedback", comment: "") }
}
public protocol I_blockchain_ui_device_haptic_feedback: I {}
public extension I_blockchain_ui_device_haptic_feedback {
	var `impact`: L_blockchain_ui_device_haptic_feedback_impact { .init("\(__).impact") }
	var `notification`: L_blockchain_ui_device_haptic_feedback_notification { .init("\(__).notification") }
}
public final class L_blockchain_ui_device_haptic_feedback_impact: L, I_blockchain_ui_device_haptic_feedback_impact {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.haptic.feedback.impact", comment: "") }
}
public protocol I_blockchain_ui_device_haptic_feedback_impact: I {}
public extension I_blockchain_ui_device_haptic_feedback_impact {
	var `heavy`: L_blockchain_ui_device_haptic_feedback_impact_heavy { .init("\(__).heavy") }
	var `light`: L_blockchain_ui_device_haptic_feedback_impact_light { .init("\(__).light") }
	var `medium`: L_blockchain_ui_device_haptic_feedback_impact_medium { .init("\(__).medium") }
	var `rigid`: L_blockchain_ui_device_haptic_feedback_impact_rigid { .init("\(__).rigid") }
	var `soft`: L_blockchain_ui_device_haptic_feedback_impact_soft { .init("\(__).soft") }
}
public final class L_blockchain_ui_device_haptic_feedback_impact_heavy: L, I_blockchain_ui_device_haptic_feedback_impact_heavy {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.haptic.feedback.impact.heavy", comment: "") }
}
public protocol I_blockchain_ui_device_haptic_feedback_impact_heavy: I {}
public final class L_blockchain_ui_device_haptic_feedback_impact_light: L, I_blockchain_ui_device_haptic_feedback_impact_light {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.haptic.feedback.impact.light", comment: "") }
}
public protocol I_blockchain_ui_device_haptic_feedback_impact_light: I {}
public final class L_blockchain_ui_device_haptic_feedback_impact_medium: L, I_blockchain_ui_device_haptic_feedback_impact_medium {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.haptic.feedback.impact.medium", comment: "") }
}
public protocol I_blockchain_ui_device_haptic_feedback_impact_medium: I {}
public final class L_blockchain_ui_device_haptic_feedback_impact_rigid: L, I_blockchain_ui_device_haptic_feedback_impact_rigid {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.haptic.feedback.impact.rigid", comment: "") }
}
public protocol I_blockchain_ui_device_haptic_feedback_impact_rigid: I {}
public final class L_blockchain_ui_device_haptic_feedback_impact_soft: L, I_blockchain_ui_device_haptic_feedback_impact_soft {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.haptic.feedback.impact.soft", comment: "") }
}
public protocol I_blockchain_ui_device_haptic_feedback_impact_soft: I {}
public final class L_blockchain_ui_device_haptic_feedback_notification: L, I_blockchain_ui_device_haptic_feedback_notification {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.haptic.feedback.notification", comment: "") }
}
public protocol I_blockchain_ui_device_haptic_feedback_notification: I {}
public extension I_blockchain_ui_device_haptic_feedback_notification {
	var `error`: L_blockchain_ui_device_haptic_feedback_notification_error { .init("\(__).error") }
	var `success`: L_blockchain_ui_device_haptic_feedback_notification_success { .init("\(__).success") }
	var `warning`: L_blockchain_ui_device_haptic_feedback_notification_warning { .init("\(__).warning") }
}
public final class L_blockchain_ui_device_haptic_feedback_notification_error: L, I_blockchain_ui_device_haptic_feedback_notification_error {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.haptic.feedback.notification.error", comment: "") }
}
public protocol I_blockchain_ui_device_haptic_feedback_notification_error: I {}
public final class L_blockchain_ui_device_haptic_feedback_notification_success: L, I_blockchain_ui_device_haptic_feedback_notification_success {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.haptic.feedback.notification.success", comment: "") }
}
public protocol I_blockchain_ui_device_haptic_feedback_notification_success: I {}
public final class L_blockchain_ui_device_haptic_feedback_notification_warning: L, I_blockchain_ui_device_haptic_feedback_notification_warning {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.haptic.feedback.notification.warning", comment: "") }
}
public protocol I_blockchain_ui_device_haptic_feedback_notification_warning: I {}
public final class L_blockchain_ui_device_id: L, I_blockchain_ui_device_id {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.id", comment: "") }
}
public protocol I_blockchain_ui_device_id: I_blockchain_db_type_string, I_blockchain_session_state_shared_value {}
public final class L_blockchain_ui_device_locale: L, I_blockchain_ui_device_locale {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.locale", comment: "") }
}
public protocol I_blockchain_ui_device_locale: I {}
public extension I_blockchain_ui_device_locale {
	var `language`: L_blockchain_ui_device_locale_language { .init("\(__).language") }
}
public final class L_blockchain_ui_device_locale_language: L, I_blockchain_ui_device_locale_language {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.locale.language", comment: "") }
}
public protocol I_blockchain_ui_device_locale_language: I {}
public extension I_blockchain_ui_device_locale_language {
	var `code`: L_blockchain_ui_device_locale_language_code { .init("\(__).code") }
}
public final class L_blockchain_ui_device_locale_language_code: L, I_blockchain_ui_device_locale_language_code {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.locale.language.code", comment: "") }
}
public protocol I_blockchain_ui_device_locale_language_code: I_blockchain_db_type_string, I_blockchain_session_state_shared_value {}
public final class L_blockchain_ui_device_os: L, I_blockchain_ui_device_os {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.os", comment: "") }
}
public protocol I_blockchain_ui_device_os: I {}
public extension I_blockchain_ui_device_os {
	var `name`: L_blockchain_ui_device_os_name { .init("\(__).name") }
	var `version`: L_blockchain_ui_device_os_version { .init("\(__).version") }
}
public final class L_blockchain_ui_device_os_name: L, I_blockchain_ui_device_os_name {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.os.name", comment: "") }
}
public protocol I_blockchain_ui_device_os_name: I_blockchain_db_type_string, I_blockchain_session_state_shared_value {}
public final class L_blockchain_ui_device_os_version: L, I_blockchain_ui_device_os_version {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.os.version", comment: "") }
}
public protocol I_blockchain_ui_device_os_version: I_blockchain_db_type_string, I_blockchain_session_state_shared_value {}
public final class L_blockchain_ui_device_settings: L, I_blockchain_ui_device_settings {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.settings", comment: "") }
}
public protocol I_blockchain_ui_device_settings: I {}
public extension I_blockchain_ui_device_settings {
	var `accessibility`: L_blockchain_ui_device_settings_accessibility { .init("\(__).accessibility") }
}
public final class L_blockchain_ui_device_settings_accessibility: L, I_blockchain_ui_device_settings_accessibility {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.settings.accessibility", comment: "") }
}
public protocol I_blockchain_ui_device_settings_accessibility: I {}
public extension I_blockchain_ui_device_settings_accessibility {
	var `large_text`: L_blockchain_ui_device_settings_accessibility_large__text { .init("\(__).large_text") }
}
public final class L_blockchain_ui_device_settings_accessibility_large__text: L, I_blockchain_ui_device_settings_accessibility_large__text {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.settings.accessibility.large_text", comment: "") }
}
public protocol I_blockchain_ui_device_settings_accessibility_large__text: I {}
public extension I_blockchain_ui_device_settings_accessibility_large__text {
	var `is`: L_blockchain_ui_device_settings_accessibility_large__text_is { .init("\(__).is") }
}
public final class L_blockchain_ui_device_settings_accessibility_large__text_is: L, I_blockchain_ui_device_settings_accessibility_large__text_is {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.settings.accessibility.large_text.is", comment: "") }
}
public protocol I_blockchain_ui_device_settings_accessibility_large__text_is: I {}
public extension I_blockchain_ui_device_settings_accessibility_large__text_is {
	var `enabled`: L_blockchain_ui_device_settings_accessibility_large__text_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_ui_device_settings_accessibility_large__text_is_enabled: L, I_blockchain_ui_device_settings_accessibility_large__text_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.ui.device.settings.accessibility.large_text.is.enabled", comment: "") }
}
public protocol I_blockchain_ui_device_settings_accessibility_large__text_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_state_shared_value {}
public final class L_blockchain_ui_type: L, I_blockchain_ui_type {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type", comment: "") }
}
public protocol I_blockchain_ui_type: I {}
public extension I_blockchain_ui_type {
	var `accessibility`: L_blockchain_ui_type_accessibility { .init("\(__).accessibility") }
	var `action`: L_blockchain_ui_type_action { .init("\(__).action") }
	var `angle`: L_blockchain_ui_type_angle { .init("\(__).angle") }
	var `article`: L_blockchain_ui_type_article { .init("\(__).article") }
	var `button`: L_blockchain_ui_type_button { .init("\(__).button") }
	var `color`: L_blockchain_ui_type_color { .init("\(__).color") }
	var `control`: L_blockchain_ui_type_control { .init("\(__).control") }
	var `element`: L_blockchain_ui_type_element { .init("\(__).element") }
	var `gradient`: L_blockchain_ui_type_gradient { .init("\(__).gradient") }
	var `input`: L_blockchain_ui_type_input { .init("\(__).input") }
	var `label`: L_blockchain_ui_type_label { .init("\(__).label") }
	var `media`: L_blockchain_ui_type_media { .init("\(__).media") }
	var `navigation`: L_blockchain_ui_type_navigation { .init("\(__).navigation") }
	var `page`: L_blockchain_ui_type_page { .init("\(__).page") }
	var `row`: L_blockchain_ui_type_row { .init("\(__).row") }
	var `state`: L_blockchain_ui_type_state { .init("\(__).state") }
	var `story`: L_blockchain_ui_type_story { .init("\(__).story") }
	var `style`: L_blockchain_ui_type_style { .init("\(__).style") }
	var `tab`: L_blockchain_ui_type_tab { .init("\(__).tab") }
	var `task`: L_blockchain_ui_type_task { .init("\(__).task") }
	var `text`: L_blockchain_ui_type_text { .init("\(__).text") }
	var `texture`: L_blockchain_ui_type_texture { .init("\(__).texture") }
}
public final class L_blockchain_ui_type_accessibility: L, I_blockchain_ui_type_accessibility {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility: I {}
public extension I_blockchain_ui_type_accessibility {
	var `children`: L_blockchain_ui_type_accessibility_children { .init("\(__).children") }
	var `hint`: L_blockchain_ui_type_accessibility_hint { .init("\(__).hint") }
	var `is`: L_blockchain_ui_type_accessibility_is { .init("\(__).is") }
	var `label`: L_blockchain_ui_type_accessibility_label { .init("\(__).label") }
	var `trait`: L_blockchain_ui_type_accessibility_trait { .init("\(__).trait") }
}
public final class L_blockchain_ui_type_accessibility_children: L, I_blockchain_ui_type_accessibility_children {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.children", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_children: I {}
public extension I_blockchain_ui_type_accessibility_children {
	var `are`: L_blockchain_ui_type_accessibility_children_are { .init("\(__).are") }
}
public final class L_blockchain_ui_type_accessibility_children_are: L, I_blockchain_ui_type_accessibility_children_are {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.children.are", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_children_are: I {}
public extension I_blockchain_ui_type_accessibility_children_are {
	var `grouped`: L_blockchain_ui_type_accessibility_children_are_grouped { .init("\(__).grouped") }
}
public final class L_blockchain_ui_type_accessibility_children_are_grouped: L, I_blockchain_ui_type_accessibility_children_are_grouped {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.children.are.grouped", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_children_are_grouped: I_blockchain_db_type_boolean {}
public final class L_blockchain_ui_type_accessibility_hint: L, I_blockchain_ui_type_accessibility_hint {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.hint", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_hint: I_blockchain_db_type_string {}
public final class L_blockchain_ui_type_accessibility_is: L, I_blockchain_ui_type_accessibility_is {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.is", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_is: I {}
public extension I_blockchain_ui_type_accessibility_is {
	var `enabled`: L_blockchain_ui_type_accessibility_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_ui_type_accessibility_is_enabled: L, I_blockchain_ui_type_accessibility_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.is.enabled", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_is_enabled: I_blockchain_db_type_boolean {}
public final class L_blockchain_ui_type_accessibility_label: L, I_blockchain_ui_type_accessibility_label {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.label", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_label: I_blockchain_db_type_string {}
public final class L_blockchain_ui_type_accessibility_trait: L, I_blockchain_ui_type_accessibility_trait {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.trait", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_trait: I_blockchain_db_type_enum {}
public extension I_blockchain_ui_type_accessibility_trait {
	var `button`: L_blockchain_ui_type_accessibility_trait_button { .init("\(__).button") }
	var `header`: L_blockchain_ui_type_accessibility_trait_header { .init("\(__).header") }
	var `image`: L_blockchain_ui_type_accessibility_trait_image { .init("\(__).image") }
	var `link`: L_blockchain_ui_type_accessibility_trait_link { .init("\(__).link") }
	var `none`: L_blockchain_ui_type_accessibility_trait_none { .init("\(__).none") }
	var `search`: L_blockchain_ui_type_accessibility_trait_search { .init("\(__).search") }
	var `selected`: L_blockchain_ui_type_accessibility_trait_selected { .init("\(__).selected") }
	var `static`: L_blockchain_ui_type_accessibility_trait_static { .init("\(__).static") }
	var `updates`: L_blockchain_ui_type_accessibility_trait_updates { .init("\(__).updates") }
}
public final class L_blockchain_ui_type_accessibility_trait_button: L, I_blockchain_ui_type_accessibility_trait_button {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.trait.button", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_trait_button: I {}
public final class L_blockchain_ui_type_accessibility_trait_header: L, I_blockchain_ui_type_accessibility_trait_header {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.trait.header", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_trait_header: I {}
public final class L_blockchain_ui_type_accessibility_trait_image: L, I_blockchain_ui_type_accessibility_trait_image {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.trait.image", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_trait_image: I {}
public final class L_blockchain_ui_type_accessibility_trait_link: L, I_blockchain_ui_type_accessibility_trait_link {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.trait.link", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_trait_link: I {}
public final class L_blockchain_ui_type_accessibility_trait_none: L, I_blockchain_ui_type_accessibility_trait_none {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.trait.none", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_trait_none: I {}
public final class L_blockchain_ui_type_accessibility_trait_search: L, I_blockchain_ui_type_accessibility_trait_search {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.trait.search", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_trait_search: I {}
public final class L_blockchain_ui_type_accessibility_trait_selected: L, I_blockchain_ui_type_accessibility_trait_selected {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.trait.selected", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_trait_selected: I {}
public final class L_blockchain_ui_type_accessibility_trait_static: L, I_blockchain_ui_type_accessibility_trait_static {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.trait.static", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_trait_static: I {}
public final class L_blockchain_ui_type_accessibility_trait_updates: L, I_blockchain_ui_type_accessibility_trait_updates {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.trait.updates", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_trait_updates: I {}
public extension I_blockchain_ui_type_accessibility_trait_updates {
	var `frequently`: L_blockchain_ui_type_accessibility_trait_updates_frequently { .init("\(__).frequently") }
}
public final class L_blockchain_ui_type_accessibility_trait_updates_frequently: L, I_blockchain_ui_type_accessibility_trait_updates_frequently {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.accessibility.trait.updates.frequently", comment: "") }
}
public protocol I_blockchain_ui_type_accessibility_trait_updates_frequently: I {}
public final class L_blockchain_ui_type_action: L, I_blockchain_ui_type_action {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action", comment: "") }
}
public protocol I_blockchain_ui_type_action: I_blockchain_ux_type_analytics_action {}
public extension I_blockchain_ui_type_action {
	var `policy`: L_blockchain_ui_type_action_policy { .init("\(__).policy") }
	var `then`: L_blockchain_ui_type_action_then { .init("\(__).then") }
	var `was`: L_blockchain_ui_type_action_was { .init("\(__).was") }
}
public final class L_blockchain_ui_type_action_policy: L, I_blockchain_ui_type_action_policy {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.policy", comment: "") }
}
public protocol I_blockchain_ui_type_action_policy: I {}
public extension I_blockchain_ui_type_action_policy {
	var `discard`: L_blockchain_ui_type_action_policy_discard { .init("\(__).discard") }
	var `perform`: L_blockchain_ui_type_action_policy_perform { .init("\(__).perform") }
}
public final class L_blockchain_ui_type_action_policy_discard: L, I_blockchain_ui_type_action_policy_discard {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.policy.discard", comment: "") }
}
public protocol I_blockchain_ui_type_action_policy_discard: I {}
public extension I_blockchain_ui_type_action_policy_discard {
	var `if`: L_blockchain_ui_type_action_policy_discard_if { .init("\(__).if") }
	var `when`: L_blockchain_ui_type_action_policy_discard_when { .init("\(__).when") }
}
public final class L_blockchain_ui_type_action_policy_discard_if: L, I_blockchain_ui_type_action_policy_discard_if {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.policy.discard.if", comment: "") }
}
public protocol I_blockchain_ui_type_action_policy_discard_if: I_blockchain_db_type_boolean {}
public final class L_blockchain_ui_type_action_policy_discard_when: L, I_blockchain_ui_type_action_policy_discard_when {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.policy.discard.when", comment: "") }
}
public protocol I_blockchain_ui_type_action_policy_discard_when: I_blockchain_db_type_boolean {}
public final class L_blockchain_ui_type_action_policy_perform: L, I_blockchain_ui_type_action_policy_perform {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.policy.perform", comment: "") }
}
public protocol I_blockchain_ui_type_action_policy_perform: I {}
public extension I_blockchain_ui_type_action_policy_perform {
	var `if`: L_blockchain_ui_type_action_policy_perform_if { .init("\(__).if") }
	var `when`: L_blockchain_ui_type_action_policy_perform_when { .init("\(__).when") }
}
public final class L_blockchain_ui_type_action_policy_perform_if: L, I_blockchain_ui_type_action_policy_perform_if {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.policy.perform.if", comment: "") }
}
public protocol I_blockchain_ui_type_action_policy_perform_if: I_blockchain_db_type_boolean {}
public final class L_blockchain_ui_type_action_policy_perform_when: L, I_blockchain_ui_type_action_policy_perform_when {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.policy.perform.when", comment: "") }
}
public protocol I_blockchain_ui_type_action_policy_perform_when: I_blockchain_db_type_boolean {}
public final class L_blockchain_ui_type_action_then: L, I_blockchain_ui_type_action_then {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then", comment: "") }
}
public protocol I_blockchain_ui_type_action_then: I {}
public extension I_blockchain_ui_type_action_then {
	var `close`: L_blockchain_ui_type_action_then_close { .init("\(__).close") }
	var `copy`: L_blockchain_ui_type_action_then_copy { .init("\(__).copy") }
	var `emit`: L_blockchain_ui_type_action_then_emit { .init("\(__).emit") }
	var `enter`: L_blockchain_ui_type_action_then_enter { .init("\(__).enter") }
	var `launch`: L_blockchain_ui_type_action_then_launch { .init("\(__).launch") }
	var `navigate`: L_blockchain_ui_type_action_then_navigate { .init("\(__).navigate") }
	var `replace`: L_blockchain_ui_type_action_then_replace { .init("\(__).replace") }
	var `set`: L_blockchain_ui_type_action_then_set { .init("\(__).set") }
}
public final class L_blockchain_ui_type_action_then_close: L, I_blockchain_ui_type_action_then_close {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.close", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_close: I_blockchain_db_type_boolean {}
public final class L_blockchain_ui_type_action_then_copy: L, I_blockchain_ui_type_action_then_copy {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.copy", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_copy: I_blockchain_db_type_string {}
public final class L_blockchain_ui_type_action_then_emit: L, I_blockchain_ui_type_action_then_emit {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.emit", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_emit: I_blockchain_db_type_tag {}
public final class L_blockchain_ui_type_action_then_enter: L, I_blockchain_ui_type_action_then_enter {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.enter", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_enter: I {}
public extension I_blockchain_ui_type_action_then_enter {
	var `into`: L_blockchain_ui_type_action_then_enter_into { .init("\(__).into") }
}
public final class L_blockchain_ui_type_action_then_enter_into: L, I_blockchain_ui_type_action_then_enter_into {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.enter.into", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_enter_into: I_blockchain_db_type_tag {}
public extension I_blockchain_ui_type_action_then_enter_into {
	var `detents`: L_blockchain_ui_type_action_then_enter_into_detents { .init("\(__).detents") }
	var `embed`: L_blockchain_ui_type_action_then_enter_into_embed { .init("\(__).embed") }
	var `grabber`: L_blockchain_ui_type_action_then_enter_into_grabber { .init("\(__).grabber") }
}
public final class L_blockchain_ui_type_action_then_enter_into_detents: L, I_blockchain_ui_type_action_then_enter_into_detents {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.enter.into.detents", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_enter_into_detents: I_blockchain_db_type_enum {}
public extension I_blockchain_ui_type_action_then_enter_into_detents {
	var `automatic`: L_blockchain_ui_type_action_then_enter_into_detents_automatic { .init("\(__).automatic") }
	var `large`: L_blockchain_ui_type_action_then_enter_into_detents_large { .init("\(__).large") }
	var `medium`: L_blockchain_ui_type_action_then_enter_into_detents_medium { .init("\(__).medium") }
	var `small`: L_blockchain_ui_type_action_then_enter_into_detents_small { .init("\(__).small") }
}
public final class L_blockchain_ui_type_action_then_enter_into_detents_automatic: L, I_blockchain_ui_type_action_then_enter_into_detents_automatic {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.enter.into.detents.automatic", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_enter_into_detents_automatic: I {}
public extension I_blockchain_ui_type_action_then_enter_into_detents_automatic {
	var `dimension`: L_blockchain_ui_type_action_then_enter_into_detents_automatic_dimension { .init("\(__).dimension") }
}
public final class L_blockchain_ui_type_action_then_enter_into_detents_automatic_dimension: L, I_blockchain_ui_type_action_then_enter_into_detents_automatic_dimension {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.enter.into.detents.automatic.dimension", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_enter_into_detents_automatic_dimension: I {}
public final class L_blockchain_ui_type_action_then_enter_into_detents_large: L, I_blockchain_ui_type_action_then_enter_into_detents_large {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.enter.into.detents.large", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_enter_into_detents_large: I {}
public final class L_blockchain_ui_type_action_then_enter_into_detents_medium: L, I_blockchain_ui_type_action_then_enter_into_detents_medium {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.enter.into.detents.medium", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_enter_into_detents_medium: I {}
public final class L_blockchain_ui_type_action_then_enter_into_detents_small: L, I_blockchain_ui_type_action_then_enter_into_detents_small {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.enter.into.detents.small", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_enter_into_detents_small: I {}
public final class L_blockchain_ui_type_action_then_enter_into_embed: L, I_blockchain_ui_type_action_then_enter_into_embed {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.enter.into.embed", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_enter_into_embed: I {}
public extension I_blockchain_ui_type_action_then_enter_into_embed {
	var `in`: L_blockchain_ui_type_action_then_enter_into_embed_in { .init("\(__).in") }
}
public final class L_blockchain_ui_type_action_then_enter_into_embed_in: L, I_blockchain_ui_type_action_then_enter_into_embed_in {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.enter.into.embed.in", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_enter_into_embed_in: I {}
public extension I_blockchain_ui_type_action_then_enter_into_embed_in {
	var `navigation`: L_blockchain_ui_type_action_then_enter_into_embed_in_navigation { .init("\(__).navigation") }
}
public final class L_blockchain_ui_type_action_then_enter_into_embed_in_navigation: L, I_blockchain_ui_type_action_then_enter_into_embed_in_navigation {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.enter.into.embed.in.navigation", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_enter_into_embed_in_navigation: I_blockchain_db_type_boolean {}
public final class L_blockchain_ui_type_action_then_enter_into_grabber: L, I_blockchain_ui_type_action_then_enter_into_grabber {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.enter.into.grabber", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_enter_into_grabber: I {}
public extension I_blockchain_ui_type_action_then_enter_into_grabber {
	var `visible`: L_blockchain_ui_type_action_then_enter_into_grabber_visible { .init("\(__).visible") }
}
public final class L_blockchain_ui_type_action_then_enter_into_grabber_visible: L, I_blockchain_ui_type_action_then_enter_into_grabber_visible {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.enter.into.grabber.visible", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_enter_into_grabber_visible: I_blockchain_db_type_boolean {}
public final class L_blockchain_ui_type_action_then_launch: L, I_blockchain_ui_type_action_then_launch {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.launch", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_launch: I {}
public extension I_blockchain_ui_type_action_then_launch {
	var `url`: L_blockchain_ui_type_action_then_launch_url { .init("\(__).url") }
}
public final class L_blockchain_ui_type_action_then_launch_url: L, I_blockchain_ui_type_action_then_launch_url {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.launch.url", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_launch_url: I_blockchain_db_type_url {}
public final class L_blockchain_ui_type_action_then_navigate: L, I_blockchain_ui_type_action_then_navigate {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.navigate", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_navigate: I {}
public extension I_blockchain_ui_type_action_then_navigate {
	var `to`: L_blockchain_ui_type_action_then_navigate_to { .init("\(__).to") }
}
public final class L_blockchain_ui_type_action_then_navigate_to: L, I_blockchain_ui_type_action_then_navigate_to {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.navigate.to", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_navigate_to: I_blockchain_db_type_tag {}
public final class L_blockchain_ui_type_action_then_replace: L, I_blockchain_ui_type_action_then_replace {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.replace", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_replace: I {}
public extension I_blockchain_ui_type_action_then_replace {
	var `current`: L_blockchain_ui_type_action_then_replace_current { .init("\(__).current") }
	var `root`: L_blockchain_ui_type_action_then_replace_root { .init("\(__).root") }
}
public final class L_blockchain_ui_type_action_then_replace_current: L, I_blockchain_ui_type_action_then_replace_current {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.replace.current", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_replace_current: I {}
public extension I_blockchain_ui_type_action_then_replace_current {
	var `stack`: L_blockchain_ui_type_action_then_replace_current_stack { .init("\(__).stack") }
}
public final class L_blockchain_ui_type_action_then_replace_current_stack: L, I_blockchain_ui_type_action_then_replace_current_stack {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.replace.current.stack", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_replace_current_stack: I_blockchain_db_type_array_of_tags {}
public final class L_blockchain_ui_type_action_then_replace_root: L, I_blockchain_ui_type_action_then_replace_root {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.replace.root", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_replace_root: I {}
public extension I_blockchain_ui_type_action_then_replace_root {
	var `stack`: L_blockchain_ui_type_action_then_replace_root_stack { .init("\(__).stack") }
}
public final class L_blockchain_ui_type_action_then_replace_root_stack: L, I_blockchain_ui_type_action_then_replace_root_stack {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.replace.root.stack", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_replace_root_stack: I_blockchain_db_type_array_of_tags {}
public final class L_blockchain_ui_type_action_then_set: L, I_blockchain_ui_type_action_then_set {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.set", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_set: I {}
public extension I_blockchain_ui_type_action_then_set {
	var `session`: L_blockchain_ui_type_action_then_set_session { .init("\(__).session") }
}
public final class L_blockchain_ui_type_action_then_set_session: L, I_blockchain_ui_type_action_then_set_session {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.set.session", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_set_session: I {}
public extension I_blockchain_ui_type_action_then_set_session {
	var `state`: L_blockchain_ui_type_action_then_set_session_state { .init("\(__).state") }
}
public final class L_blockchain_ui_type_action_then_set_session_state: L, I_blockchain_ui_type_action_then_set_session_state {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.set.session.state", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_set_session_state: I_blockchain_db_leaf, I_blockchain_db_type_array_of_maps {}
public extension I_blockchain_ui_type_action_then_set_session_state {
	var `key`: L_blockchain_ui_type_action_then_set_session_state_key { .init("\(__).key") }
	var `value`: L_blockchain_ui_type_action_then_set_session_state_value { .init("\(__).value") }
}
public final class L_blockchain_ui_type_action_then_set_session_state_key: L, I_blockchain_ui_type_action_then_set_session_state_key {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.set.session.state.key", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_set_session_state_key: I_blockchain_db_type_tag {}
public final class L_blockchain_ui_type_action_then_set_session_state_value: L, I_blockchain_ui_type_action_then_set_session_state_value {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.then.set.session.state.value", comment: "") }
}
public protocol I_blockchain_ui_type_action_then_set_session_state_value: I_blockchain_db_type_any {}
public final class L_blockchain_ui_type_action_was: L, I_blockchain_ui_type_action_was {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.was", comment: "") }
}
public protocol I_blockchain_ui_type_action_was: I {}
public extension I_blockchain_ui_type_action_was {
	var `handled`: L_blockchain_ui_type_action_was_handled { .init("\(__).handled") }
}
public final class L_blockchain_ui_type_action_was_handled: L, I_blockchain_ui_type_action_was_handled {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.action.was.handled", comment: "") }
}
public protocol I_blockchain_ui_type_action_was_handled: I {}
public final class L_blockchain_ui_type_angle: L, I_blockchain_ui_type_angle {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.angle", comment: "") }
}
public protocol I_blockchain_ui_type_angle: I {}
public extension I_blockchain_ui_type_angle {
	var `degrees`: L_blockchain_ui_type_angle_degrees { .init("\(__).degrees") }
	var `radians`: L_blockchain_ui_type_angle_radians { .init("\(__).radians") }
	var `turns`: L_blockchain_ui_type_angle_turns { .init("\(__).turns") }
}
public final class L_blockchain_ui_type_angle_degrees: L, I_blockchain_ui_type_angle_degrees {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.angle.degrees", comment: "") }
}
public protocol I_blockchain_ui_type_angle_degrees: I_blockchain_db_type_number {}
public final class L_blockchain_ui_type_angle_radians: L, I_blockchain_ui_type_angle_radians {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.angle.radians", comment: "") }
}
public protocol I_blockchain_ui_type_angle_radians: I_blockchain_db_type_number {}
public final class L_blockchain_ui_type_angle_turns: L, I_blockchain_ui_type_angle_turns {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.angle.turns", comment: "") }
}
public protocol I_blockchain_ui_type_angle_turns: I_blockchain_db_type_number {}
public final class L_blockchain_ui_type_article: L, I_blockchain_ui_type_article {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.article", comment: "") }
}
public protocol I_blockchain_ui_type_article: I {}
public extension I_blockchain_ui_type_article {
	var `plain`: L_blockchain_ui_type_article_plain { .init("\(__).plain") }
	var `type`: L_blockchain_ui_type_article_type { .init("\(__).type") }
}
public final class L_blockchain_ui_type_article_plain: L, I_blockchain_ui_type_article_plain {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.article.plain", comment: "") }
}
public protocol I_blockchain_ui_type_article_plain: I_blockchain_ui_type_article_type {}
public extension I_blockchain_ui_type_article_plain {
	var `body`: L_blockchain_ui_type_article_plain_body { .init("\(__).body") }
	var `footer`: L_blockchain_ui_type_article_plain_footer { .init("\(__).footer") }
	var `header`: L_blockchain_ui_type_article_plain_header { .init("\(__).header") }
}
public final class L_blockchain_ui_type_article_plain_body: L, I_blockchain_ui_type_article_plain_body {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.article.plain.body", comment: "") }
}
public protocol I_blockchain_ui_type_article_plain_body: I {}
public extension I_blockchain_ui_type_article_plain_body {
	var `pages`: L_blockchain_ui_type_article_plain_body_pages { .init("\(__).pages") }
}
public final class L_blockchain_ui_type_article_plain_body_pages: L, I_blockchain_ui_type_article_plain_body_pages {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.article.plain.body.pages", comment: "") }
}
public protocol I_blockchain_ui_type_article_plain_body_pages: I_blockchain_ui_type_page, I_blockchain_db_type_array_of_maps {}
public final class L_blockchain_ui_type_article_plain_footer: L, I_blockchain_ui_type_article_plain_footer {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.article.plain.footer", comment: "") }
}
public protocol I_blockchain_ui_type_article_plain_footer: I {}
public final class L_blockchain_ui_type_article_plain_header: L, I_blockchain_ui_type_article_plain_header {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.article.plain.header", comment: "") }
}
public protocol I_blockchain_ui_type_article_plain_header: I {}
public final class L_blockchain_ui_type_article_type: L, I_blockchain_ui_type_article_type {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.article.type", comment: "") }
}
public protocol I_blockchain_ui_type_article_type: I_blockchain_ui_type_state {}
public extension I_blockchain_ui_type_article_type {
	var `navigation`: L_blockchain_ui_type_article_type_navigation { .init("\(__).navigation") }
}
public final class L_blockchain_ui_type_article_type_navigation: L, I_blockchain_ui_type_article_type_navigation {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.article.type.navigation", comment: "") }
}
public protocol I_blockchain_ui_type_article_type_navigation: I_blockchain_ui_type_navigation {}
public final class L_blockchain_ui_type_button: L, I_blockchain_ui_type_button {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.button", comment: "") }
}
public protocol I_blockchain_ui_type_button: I {}
public extension I_blockchain_ui_type_button {
	var `alert`: L_blockchain_ui_type_button_alert { .init("\(__).alert") }
	var `icon`: L_blockchain_ui_type_button_icon { .init("\(__).icon") }
	var `minimal`: L_blockchain_ui_type_button_minimal { .init("\(__).minimal") }
	var `primary`: L_blockchain_ui_type_button_primary { .init("\(__).primary") }
	var `secondary`: L_blockchain_ui_type_button_secondary { .init("\(__).secondary") }
	var `small`: L_blockchain_ui_type_button_small { .init("\(__).small") }
}
public final class L_blockchain_ui_type_button_alert: L, I_blockchain_ui_type_button_alert {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.button.alert", comment: "") }
}
public protocol I_blockchain_ui_type_button_alert: I_blockchain_ui_type_control {}
public final class L_blockchain_ui_type_button_icon: L, I_blockchain_ui_type_button_icon {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.button.icon", comment: "") }
}
public protocol I_blockchain_ui_type_button_icon: I_blockchain_ui_type_control {}
public extension I_blockchain_ui_type_button_icon {
	var `media`: L_blockchain_ui_type_button_icon_media { .init("\(__).media") }
}
public final class L_blockchain_ui_type_button_icon_media: L, I_blockchain_ui_type_button_icon_media {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.button.icon.media", comment: "") }
}
public protocol I_blockchain_ui_type_button_icon_media: I_blockchain_ui_type_media {}
public final class L_blockchain_ui_type_button_minimal: L, I_blockchain_ui_type_button_minimal {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.button.minimal", comment: "") }
}
public protocol I_blockchain_ui_type_button_minimal: I_blockchain_ui_type_control {}
public final class L_blockchain_ui_type_button_primary: L, I_blockchain_ui_type_button_primary {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.button.primary", comment: "") }
}
public protocol I_blockchain_ui_type_button_primary: I_blockchain_ui_type_control {}
public final class L_blockchain_ui_type_button_secondary: L, I_blockchain_ui_type_button_secondary {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.button.secondary", comment: "") }
}
public protocol I_blockchain_ui_type_button_secondary: I_blockchain_ui_type_control {}
public final class L_blockchain_ui_type_button_small: L, I_blockchain_ui_type_button_small {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.button.small", comment: "") }
}
public protocol I_blockchain_ui_type_button_small: I {}
public extension I_blockchain_ui_type_button_small {
	var `minimal`: L_blockchain_ui_type_button_small_minimal { .init("\(__).minimal") }
	var `primary`: L_blockchain_ui_type_button_small_primary { .init("\(__).primary") }
	var `secondary`: L_blockchain_ui_type_button_small_secondary { .init("\(__).secondary") }
}
public final class L_blockchain_ui_type_button_small_minimal: L, I_blockchain_ui_type_button_small_minimal {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.button.small.minimal", comment: "") }
}
public protocol I_blockchain_ui_type_button_small_minimal: I_blockchain_ui_type_control {}
public final class L_blockchain_ui_type_button_small_primary: L, I_blockchain_ui_type_button_small_primary {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.button.small.primary", comment: "") }
}
public protocol I_blockchain_ui_type_button_small_primary: I_blockchain_ui_type_control {}
public final class L_blockchain_ui_type_button_small_secondary: L, I_blockchain_ui_type_button_small_secondary {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.button.small.secondary", comment: "") }
}
public protocol I_blockchain_ui_type_button_small_secondary: I_blockchain_ui_type_control {}
public final class L_blockchain_ui_type_color: L, I_blockchain_ui_type_color {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.color", comment: "") }
}
public protocol I_blockchain_ui_type_color: I {}
public extension I_blockchain_ui_type_color {
	var `hsb`: L_blockchain_ui_type_color_hsb { .init("\(__).hsb") }
	var `rgb`: L_blockchain_ui_type_color_rgb { .init("\(__).rgb") }
}
public final class L_blockchain_ui_type_color_hsb: L, I_blockchain_ui_type_color_hsb {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.color.hsb", comment: "") }
}
public protocol I_blockchain_ui_type_color_hsb: I {}
public extension I_blockchain_ui_type_color_hsb {
	var `alpha`: L_blockchain_ui_type_color_hsb_alpha { .init("\(__).alpha") }
	var `brightness`: L_blockchain_ui_type_color_hsb_brightness { .init("\(__).brightness") }
	var `hue`: L_blockchain_ui_type_color_hsb_hue { .init("\(__).hue") }
	var `saturation`: L_blockchain_ui_type_color_hsb_saturation { .init("\(__).saturation") }
}
public final class L_blockchain_ui_type_color_hsb_alpha: L, I_blockchain_ui_type_color_hsb_alpha {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.color.hsb.alpha", comment: "") }
}
public protocol I_blockchain_ui_type_color_hsb_alpha: I_blockchain_db_type_number {}
public final class L_blockchain_ui_type_color_hsb_brightness: L, I_blockchain_ui_type_color_hsb_brightness {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.color.hsb.brightness", comment: "") }
}
public protocol I_blockchain_ui_type_color_hsb_brightness: I_blockchain_db_type_number {}
public final class L_blockchain_ui_type_color_hsb_hue: L, I_blockchain_ui_type_color_hsb_hue {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.color.hsb.hue", comment: "") }
}
public protocol I_blockchain_ui_type_color_hsb_hue: I_blockchain_db_type_number {}
public final class L_blockchain_ui_type_color_hsb_saturation: L, I_blockchain_ui_type_color_hsb_saturation {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.color.hsb.saturation", comment: "") }
}
public protocol I_blockchain_ui_type_color_hsb_saturation: I_blockchain_db_type_number {}
public final class L_blockchain_ui_type_color_rgb: L, I_blockchain_ui_type_color_rgb {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.color.rgb", comment: "") }
}
public protocol I_blockchain_ui_type_color_rgb: I {}
public extension I_blockchain_ui_type_color_rgb {
	var `alpha`: L_blockchain_ui_type_color_rgb_alpha { .init("\(__).alpha") }
	var `blue`: L_blockchain_ui_type_color_rgb_blue { .init("\(__).blue") }
	var `green`: L_blockchain_ui_type_color_rgb_green { .init("\(__).green") }
	var `red`: L_blockchain_ui_type_color_rgb_red { .init("\(__).red") }
}
public final class L_blockchain_ui_type_color_rgb_alpha: L, I_blockchain_ui_type_color_rgb_alpha {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.color.rgb.alpha", comment: "") }
}
public protocol I_blockchain_ui_type_color_rgb_alpha: I_blockchain_db_type_number {}
public final class L_blockchain_ui_type_color_rgb_blue: L, I_blockchain_ui_type_color_rgb_blue {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.color.rgb.blue", comment: "") }
}
public protocol I_blockchain_ui_type_color_rgb_blue: I_blockchain_db_type_number {}
public final class L_blockchain_ui_type_color_rgb_green: L, I_blockchain_ui_type_color_rgb_green {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.color.rgb.green", comment: "") }
}
public protocol I_blockchain_ui_type_color_rgb_green: I_blockchain_db_type_number {}
public final class L_blockchain_ui_type_color_rgb_red: L, I_blockchain_ui_type_color_rgb_red {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.color.rgb.red", comment: "") }
}
public protocol I_blockchain_ui_type_color_rgb_red: I_blockchain_db_type_number {}
public final class L_blockchain_ui_type_control: L, I_blockchain_ui_type_control {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control", comment: "") }
}
public protocol I_blockchain_ui_type_control: I_blockchain_ui_type_element {}
public extension I_blockchain_ui_type_control {
	var `analytics`: L_blockchain_ui_type_control_analytics { .init("\(__).analytics") }
	var `event`: L_blockchain_ui_type_control_event { .init("\(__).event") }
	var `title`: L_blockchain_ui_type_control_title { .init("\(__).title") }
	var `select`: L_blockchain_ui_type_control_select { event.select }
	var `tap`: L_blockchain_ui_type_control_tap { event.select }
}
public final class L_blockchain_ui_type_control_analytics: L, I_blockchain_ui_type_control_analytics {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.analytics", comment: "") }
}
public protocol I_blockchain_ui_type_control_analytics: I {}
public extension I_blockchain_ui_type_control_analytics {
	var `context`: L_blockchain_ui_type_control_analytics_context { .init("\(__).context") }
}
public final class L_blockchain_ui_type_control_analytics_context: L, I_blockchain_ui_type_control_analytics_context {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.analytics.context", comment: "") }
}
public protocol I_blockchain_ui_type_control_analytics_context: I_blockchain_type_key_context {}
public final class L_blockchain_ui_type_control_event: L, I_blockchain_ui_type_control_event {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event", comment: "") }
}
public protocol I_blockchain_ui_type_control_event: I {}
public extension I_blockchain_ui_type_control_event {
	var `select`: L_blockchain_ui_type_control_event_select { .init("\(__).select") }
	var `swipe`: L_blockchain_ui_type_control_event_swipe { .init("\(__).swipe") }
	var `value`: L_blockchain_ui_type_control_event_value { .init("\(__).value") }
	var `tap`: L_blockchain_ui_type_control_event_tap { select }
}
public final class L_blockchain_ui_type_control_event_select: L, I_blockchain_ui_type_control_event_select {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.select", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_select: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_swipe: L, I_blockchain_ui_type_control_event_swipe {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.swipe", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_swipe: I {}
public extension I_blockchain_ui_type_control_event_swipe {
	var `any`: L_blockchain_ui_type_control_event_swipe_any { .init("\(__).any") }
	var `down`: L_blockchain_ui_type_control_event_swipe_down { .init("\(__).down") }
	var `horizontal`: L_blockchain_ui_type_control_event_swipe_horizontal { .init("\(__).horizontal") }
	var `left`: L_blockchain_ui_type_control_event_swipe_left { .init("\(__).left") }
	var `right`: L_blockchain_ui_type_control_event_swipe_right { .init("\(__).right") }
	var `up`: L_blockchain_ui_type_control_event_swipe_up { .init("\(__).up") }
	var `vertical`: L_blockchain_ui_type_control_event_swipe_vertical { .init("\(__).vertical") }
}
public final class L_blockchain_ui_type_control_event_swipe_any: L, I_blockchain_ui_type_control_event_swipe_any {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.swipe.any", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_swipe_any: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_swipe_down: L, I_blockchain_ui_type_control_event_swipe_down {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.swipe.down", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_swipe_down: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_swipe_horizontal: L, I_blockchain_ui_type_control_event_swipe_horizontal {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.swipe.horizontal", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_swipe_horizontal: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_swipe_left: L, I_blockchain_ui_type_control_event_swipe_left {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.swipe.left", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_swipe_left: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_swipe_right: L, I_blockchain_ui_type_control_event_swipe_right {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.swipe.right", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_swipe_right: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_swipe_up: L, I_blockchain_ui_type_control_event_swipe_up {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.swipe.up", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_swipe_up: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_swipe_vertical: L, I_blockchain_ui_type_control_event_swipe_vertical {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.swipe.vertical", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_swipe_vertical: I_blockchain_ui_type_action {}
public typealias L_blockchain_ui_type_control_event_tap = L_blockchain_ui_type_control_event_select
public final class L_blockchain_ui_type_control_event_value: L, I_blockchain_ui_type_control_event_value {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.value", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_value: I {}
public extension I_blockchain_ui_type_control_event_value {
	var `changed`: L_blockchain_ui_type_control_event_value_changed { .init("\(__).changed") }
	var `decremented`: L_blockchain_ui_type_control_event_value_decremented { .init("\(__).decremented") }
	var `incremented`: L_blockchain_ui_type_control_event_value_incremented { .init("\(__).incremented") }
	var `initialised`: L_blockchain_ui_type_control_event_value_initialised { .init("\(__).initialised") }
}
public final class L_blockchain_ui_type_control_event_value_changed: L, I_blockchain_ui_type_control_event_value_changed {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.value.changed", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_value_changed: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_value_decremented: L, I_blockchain_ui_type_control_event_value_decremented {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.value.decremented", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_value_decremented: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_value_incremented: L, I_blockchain_ui_type_control_event_value_incremented {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.value.incremented", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_value_incremented: I_blockchain_ui_type_action {}
public final class L_blockchain_ui_type_control_event_value_initialised: L, I_blockchain_ui_type_control_event_value_initialised {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.event.value.initialised", comment: "") }
}
public protocol I_blockchain_ui_type_control_event_value_initialised: I_blockchain_ui_type_action {}
public typealias L_blockchain_ui_type_control_select = L_blockchain_ui_type_control_event_select
public typealias L_blockchain_ui_type_control_tap = L_blockchain_ui_type_control_event_select
public final class L_blockchain_ui_type_control_title: L, I_blockchain_ui_type_control_title {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.control.title", comment: "") }
}
public protocol I_blockchain_ui_type_control_title: I_blockchain_ui_type_label {}
public final class L_blockchain_ui_type_element: L, I_blockchain_ui_type_element {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.element", comment: "") }
}
public protocol I_blockchain_ui_type_element: I {}
public extension I_blockchain_ui_type_element {
	var `accessibility`: L_blockchain_ui_type_element_accessibility { .init("\(__).accessibility") }
	var `lifecycle`: L_blockchain_ui_type_element_lifecycle { .init("\(__).lifecycle") }
	var `style`: L_blockchain_ui_type_element_style { .init("\(__).style") }
}
public final class L_blockchain_ui_type_element_accessibility: L, I_blockchain_ui_type_element_accessibility {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.element.accessibility", comment: "") }
}
public protocol I_blockchain_ui_type_element_accessibility: I_blockchain_ui_type_accessibility {}
public final class L_blockchain_ui_type_element_lifecycle: L, I_blockchain_ui_type_element_lifecycle {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.element.lifecycle", comment: "") }
}
public protocol I_blockchain_ui_type_element_lifecycle: I {}
public extension I_blockchain_ui_type_element_lifecycle {
	var `event`: L_blockchain_ui_type_element_lifecycle_event { .init("\(__).event") }
}
public final class L_blockchain_ui_type_element_lifecycle_event: L, I_blockchain_ui_type_element_lifecycle_event {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.element.lifecycle.event", comment: "") }
}
public protocol I_blockchain_ui_type_element_lifecycle_event: I {}
public extension I_blockchain_ui_type_element_lifecycle_event {
	var `did`: L_blockchain_ui_type_element_lifecycle_event_did { .init("\(__).did") }
}
public final class L_blockchain_ui_type_element_lifecycle_event_did: L, I_blockchain_ui_type_element_lifecycle_event_did {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.element.lifecycle.event.did", comment: "") }
}
public protocol I_blockchain_ui_type_element_lifecycle_event_did: I {}
public extension I_blockchain_ui_type_element_lifecycle_event_did {
	var `enter`: L_blockchain_ui_type_element_lifecycle_event_did_enter { .init("\(__).enter") }
	var `exit`: L_blockchain_ui_type_element_lifecycle_event_did_exit { .init("\(__).exit") }
	var `update`: L_blockchain_ui_type_element_lifecycle_event_did_update { .init("\(__).update") }
}
public final class L_blockchain_ui_type_element_lifecycle_event_did_enter: L, I_blockchain_ui_type_element_lifecycle_event_did_enter {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.element.lifecycle.event.did.enter", comment: "") }
}
public protocol I_blockchain_ui_type_element_lifecycle_event_did_enter: I {}
public extension I_blockchain_ui_type_element_lifecycle_event_did_enter {
	var `state`: L_blockchain_ui_type_element_lifecycle_event_did_enter_state { .init("\(__).state") }
}
public final class L_blockchain_ui_type_element_lifecycle_event_did_enter_state: L, I_blockchain_ui_type_element_lifecycle_event_did_enter_state {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.element.lifecycle.event.did.enter.state", comment: "") }
}
public protocol I_blockchain_ui_type_element_lifecycle_event_did_enter_state: I_blockchain_ux_type_analytics_state {}
public final class L_blockchain_ui_type_element_lifecycle_event_did_exit: L, I_blockchain_ui_type_element_lifecycle_event_did_exit {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.element.lifecycle.event.did.exit", comment: "") }
}
public protocol I_blockchain_ui_type_element_lifecycle_event_did_exit: I {}
public extension I_blockchain_ui_type_element_lifecycle_event_did_exit {
	var `state`: L_blockchain_ui_type_element_lifecycle_event_did_exit_state { .init("\(__).state") }
}
public final class L_blockchain_ui_type_element_lifecycle_event_did_exit_state: L, I_blockchain_ui_type_element_lifecycle_event_did_exit_state {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.element.lifecycle.event.did.exit.state", comment: "") }
}
public protocol I_blockchain_ui_type_element_lifecycle_event_did_exit_state: I_blockchain_ux_type_analytics_state {}
public final class L_blockchain_ui_type_element_lifecycle_event_did_update: L, I_blockchain_ui_type_element_lifecycle_event_did_update {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.element.lifecycle.event.did.update", comment: "") }
}
public protocol I_blockchain_ui_type_element_lifecycle_event_did_update: I {}
public extension I_blockchain_ui_type_element_lifecycle_event_did_update {
	var `state`: L_blockchain_ui_type_element_lifecycle_event_did_update_state { .init("\(__).state") }
}
public final class L_blockchain_ui_type_element_lifecycle_event_did_update_state: L, I_blockchain_ui_type_element_lifecycle_event_did_update_state {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.element.lifecycle.event.did.update.state", comment: "") }
}
public protocol I_blockchain_ui_type_element_lifecycle_event_did_update_state: I_blockchain_ux_type_analytics_state {}
public final class L_blockchain_ui_type_element_style: L, I_blockchain_ui_type_element_style {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.element.style", comment: "") }
}
public protocol I_blockchain_ui_type_element_style: I_blockchain_ui_type_style {}
public final class L_blockchain_ui_type_gradient: L, I_blockchain_ui_type_gradient {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.gradient", comment: "") }
}
public protocol I_blockchain_ui_type_gradient: I {}
public extension I_blockchain_ui_type_gradient {
	var `linear`: L_blockchain_ui_type_gradient_linear { .init("\(__).linear") }
}
public final class L_blockchain_ui_type_gradient_linear: L, I_blockchain_ui_type_gradient_linear {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.gradient.linear", comment: "") }
}
public protocol I_blockchain_ui_type_gradient_linear: I {}
public extension I_blockchain_ui_type_gradient_linear {
	var `angle`: L_blockchain_ui_type_gradient_linear_angle { .init("\(__).angle") }
	var `steps`: L_blockchain_ui_type_gradient_linear_steps { .init("\(__).steps") }
}
public final class L_blockchain_ui_type_gradient_linear_angle: L, I_blockchain_ui_type_gradient_linear_angle {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.gradient.linear.angle", comment: "") }
}
public protocol I_blockchain_ui_type_gradient_linear_angle: I_blockchain_ui_type_angle {}
public final class L_blockchain_ui_type_gradient_linear_steps: L, I_blockchain_ui_type_gradient_linear_steps {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.gradient.linear.steps", comment: "") }
}
public protocol I_blockchain_ui_type_gradient_linear_steps: I_blockchain_db_type_array_of_maps {}
public extension I_blockchain_ui_type_gradient_linear_steps {
	var `color`: L_blockchain_ui_type_gradient_linear_steps_color { .init("\(__).color") }
	var `fraction`: L_blockchain_ui_type_gradient_linear_steps_fraction { .init("\(__).fraction") }
}
public final class L_blockchain_ui_type_gradient_linear_steps_color: L, I_blockchain_ui_type_gradient_linear_steps_color {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.gradient.linear.steps.color", comment: "") }
}
public protocol I_blockchain_ui_type_gradient_linear_steps_color: I_blockchain_ui_type_color {}
public final class L_blockchain_ui_type_gradient_linear_steps_fraction: L, I_blockchain_ui_type_gradient_linear_steps_fraction {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.gradient.linear.steps.fraction", comment: "") }
}
public protocol I_blockchain_ui_type_gradient_linear_steps_fraction: I_blockchain_db_type_number {}
public final class L_blockchain_ui_type_input: L, I_blockchain_ui_type_input {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.input", comment: "") }
}
public protocol I_blockchain_ui_type_input: I_blockchain_ui_type_control {}
public extension I_blockchain_ui_type_input {
	var `value`: L_blockchain_ui_type_input_value { .init("\(__).value") }
}
public final class L_blockchain_ui_type_input_value: L, I_blockchain_ui_type_input_value {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.input.value", comment: "") }
}
public protocol I_blockchain_ui_type_input_value: I_blockchain_session_state_value {}
public final class L_blockchain_ui_type_label: L, I_blockchain_ui_type_label {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.label", comment: "") }
}
public protocol I_blockchain_ui_type_label: I_blockchain_ui_type_element {}
public extension I_blockchain_ui_type_label {
	var `text`: L_blockchain_ui_type_label_text { .init("\(__).text") }
}
public final class L_blockchain_ui_type_label_text: L, I_blockchain_ui_type_label_text {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.label.text", comment: "") }
}
public protocol I_blockchain_ui_type_label_text: I_blockchain_db_type_string {}
public final class L_blockchain_ui_type_media: L, I_blockchain_ui_type_media {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.media", comment: "") }
}
public protocol I_blockchain_ui_type_media: I_blockchain_ui_type_element {}
public extension I_blockchain_ui_type_media {
	var `url`: L_blockchain_ui_type_media_url { .init("\(__).url") }
}
public final class L_blockchain_ui_type_media_url: L, I_blockchain_ui_type_media_url {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.media.url", comment: "") }
}
public protocol I_blockchain_ui_type_media_url: I_blockchain_db_type_url {}
public final class L_blockchain_ui_type_navigation: L, I_blockchain_ui_type_navigation {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.navigation", comment: "") }
}
public protocol I_blockchain_ui_type_navigation: I {}
public extension I_blockchain_ui_type_navigation {
	var `bar`: L_blockchain_ui_type_navigation_bar { .init("\(__).bar") }
}
public final class L_blockchain_ui_type_navigation_bar: L, I_blockchain_ui_type_navigation_bar {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.navigation.bar", comment: "") }
}
public protocol I_blockchain_ui_type_navigation_bar: I {}
public extension I_blockchain_ui_type_navigation_bar {
	var `button`: L_blockchain_ui_type_navigation_bar_button { .init("\(__).button") }
}
public final class L_blockchain_ui_type_navigation_bar_button: L, I_blockchain_ui_type_navigation_bar_button {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.navigation.bar.button", comment: "") }
}
public protocol I_blockchain_ui_type_navigation_bar_button: I {}
public extension I_blockchain_ui_type_navigation_bar_button {
	var `back`: L_blockchain_ui_type_navigation_bar_button_back { .init("\(__).back") }
	var `close`: L_blockchain_ui_type_navigation_bar_button_close { .init("\(__).close") }
}
public final class L_blockchain_ui_type_navigation_bar_button_back: L, I_blockchain_ui_type_navigation_bar_button_back {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.navigation.bar.button.back", comment: "") }
}
public protocol I_blockchain_ui_type_navigation_bar_button_back: I_blockchain_ui_type_button_icon {}
public final class L_blockchain_ui_type_navigation_bar_button_close: L, I_blockchain_ui_type_navigation_bar_button_close {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.navigation.bar.button.close", comment: "") }
}
public protocol I_blockchain_ui_type_navigation_bar_button_close: I_blockchain_ui_type_button_icon {}
public final class L_blockchain_ui_type_page: L, I_blockchain_ui_type_page {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.page", comment: "") }
}
public protocol I_blockchain_ui_type_page: I {}
public extension I_blockchain_ui_type_page {
	var `centered`: L_blockchain_ui_type_page_centered { .init("\(__).centered") }
	var `plain`: L_blockchain_ui_type_page_plain { .init("\(__).plain") }
}
public final class L_blockchain_ui_type_page_centered: L, I_blockchain_ui_type_page_centered {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.page.centered", comment: "") }
}
public protocol I_blockchain_ui_type_page_centered: I_blockchain_ui_type_task_section_stack_vertical {}
public final class L_blockchain_ui_type_page_plain: L, I_blockchain_ui_type_page_plain {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.page.plain", comment: "") }
}
public protocol I_blockchain_ui_type_page_plain: I_blockchain_ui_type_task_section_stack_vertical {}
public final class L_blockchain_ui_type_row: L, I_blockchain_ui_type_row {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.row", comment: "") }
}
public protocol I_blockchain_ui_type_row: I_blockchain_ui_type_control {}
public extension I_blockchain_ui_type_row {
	var `byline`: L_blockchain_ui_type_row_byline { .init("\(__).byline") }
	var `footer`: L_blockchain_ui_type_row_footer { .init("\(__).footer") }
	var `leading`: L_blockchain_ui_type_row_leading { .init("\(__).leading") }
	var `style`: L_blockchain_ui_type_row_style { .init("\(__).style") }
	var `title`: L_blockchain_ui_type_row_title { .init("\(__).title") }
	var `trailing`: L_blockchain_ui_type_row_trailing { .init("\(__).trailing") }
}
public final class L_blockchain_ui_type_row_byline: L, I_blockchain_ui_type_row_byline {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.row.byline", comment: "") }
}
public protocol I_blockchain_ui_type_row_byline: I_blockchain_ui_type_text {}
public final class L_blockchain_ui_type_row_footer: L, I_blockchain_ui_type_row_footer {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.row.footer", comment: "") }
}
public protocol I_blockchain_ui_type_row_footer: I_blockchain_ui_type_task {}
public final class L_blockchain_ui_type_row_leading: L, I_blockchain_ui_type_row_leading {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.row.leading", comment: "") }
}
public protocol I_blockchain_ui_type_row_leading: I_blockchain_ui_type_task {}
public final class L_blockchain_ui_type_row_style: L, I_blockchain_ui_type_row_style {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.row.style", comment: "") }
}
public protocol I_blockchain_ui_type_row_style: I_blockchain_ui_type_style {}
public final class L_blockchain_ui_type_row_title: L, I_blockchain_ui_type_row_title {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.row.title", comment: "") }
}
public protocol I_blockchain_ui_type_row_title: I_blockchain_ui_type_text {}
public final class L_blockchain_ui_type_row_trailing: L, I_blockchain_ui_type_row_trailing {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.row.trailing", comment: "") }
}
public protocol I_blockchain_ui_type_row_trailing: I_blockchain_ui_type_task {}
public final class L_blockchain_ui_type_state: L, I_blockchain_ui_type_state {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.state", comment: "") }
}
public protocol I_blockchain_ui_type_state: I_blockchain_ui_type_element, I_blockchain_ux_type_analytics_state {}
public final class L_blockchain_ui_type_story: L, I_blockchain_ui_type_story {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.story", comment: "") }
}
public protocol I_blockchain_ui_type_story: I {}
public extension I_blockchain_ui_type_story {
	var `article`: L_blockchain_ui_type_story_article { .init("\(__).article") }
	var `page`: L_blockchain_ui_type_story_page { .init("\(__).page") }
	var `tab`: L_blockchain_ui_type_story_tab { .init("\(__).tab") }
}
public final class L_blockchain_ui_type_story_article: L, I_blockchain_ui_type_story_article {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.story.article", comment: "") }
}
public protocol I_blockchain_ui_type_story_article: I_blockchain_ui_type_article {}
public final class L_blockchain_ui_type_story_page: L, I_blockchain_ui_type_story_page {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.story.page", comment: "") }
}
public protocol I_blockchain_ui_type_story_page: I_blockchain_ui_type_page {}
public final class L_blockchain_ui_type_story_tab: L, I_blockchain_ui_type_story_tab {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.story.tab", comment: "") }
}
public protocol I_blockchain_ui_type_story_tab: I_blockchain_ui_type_tab {}
public final class L_blockchain_ui_type_style: L, I_blockchain_ui_type_style {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.style", comment: "") }
}
public protocol I_blockchain_ui_type_style: I {}
public extension I_blockchain_ui_type_style {
	var `background`: L_blockchain_ui_type_style_background { .init("\(__).background") }
	var `display`: L_blockchain_ui_type_style_display { .init("\(__).display") }
	var `foreground`: L_blockchain_ui_type_style_foreground { .init("\(__).foreground") }
}
public final class L_blockchain_ui_type_style_background: L, I_blockchain_ui_type_style_background {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.style.background", comment: "") }
}
public protocol I_blockchain_ui_type_style_background: I_blockchain_ui_type_texture {}
public final class L_blockchain_ui_type_style_display: L, I_blockchain_ui_type_style_display {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.style.display", comment: "") }
}
public protocol I_blockchain_ui_type_style_display: I_blockchain_db_type_boolean {}
public final class L_blockchain_ui_type_style_foreground: L, I_blockchain_ui_type_style_foreground {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.style.foreground", comment: "") }
}
public protocol I_blockchain_ui_type_style_foreground: I_blockchain_ui_type_texture {}
public final class L_blockchain_ui_type_tab: L, I_blockchain_ui_type_tab {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.tab", comment: "") }
}
public protocol I_blockchain_ui_type_tab: I {}
public extension I_blockchain_ui_type_tab {
	var `bar`: L_blockchain_ui_type_tab_bar { .init("\(__).bar") }
}
public final class L_blockchain_ui_type_tab_bar: L, I_blockchain_ui_type_tab_bar {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.tab.bar", comment: "") }
}
public protocol I_blockchain_ui_type_tab_bar: I {}
public extension I_blockchain_ui_type_tab_bar {
	var `item`: L_blockchain_ui_type_tab_bar_item { .init("\(__).item") }
	var `items`: L_blockchain_ui_type_tab_bar_items { .init("\(__).items") }
}
public final class L_blockchain_ui_type_tab_bar_item: L, I_blockchain_ui_type_tab_bar_item {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.tab.bar.item", comment: "") }
}
public protocol I_blockchain_ui_type_tab_bar_item: I {}
public extension I_blockchain_ui_type_tab_bar_item {
	var `entry`: L_blockchain_ui_type_tab_bar_item_entry { .init("\(__).entry") }
	var `story`: L_blockchain_ui_type_tab_bar_item_story { .init("\(__).story") }
}
public final class L_blockchain_ui_type_tab_bar_item_entry: L, I_blockchain_ui_type_tab_bar_item_entry {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.tab.bar.item.entry", comment: "") }
}
public protocol I_blockchain_ui_type_tab_bar_item_entry: I_blockchain_ui_type_button_icon {}
public final class L_blockchain_ui_type_tab_bar_item_story: L, I_blockchain_ui_type_tab_bar_item_story {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.tab.bar.item.story", comment: "") }
}
public protocol I_blockchain_ui_type_tab_bar_item_story: I_blockchain_db_type_tag {}
public final class L_blockchain_ui_type_tab_bar_items: L, I_blockchain_ui_type_tab_bar_items {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.tab.bar.items", comment: "") }
}
public protocol I_blockchain_ui_type_tab_bar_items: I_blockchain_ui_type_tab_bar_item, I_blockchain_db_type_array_of_maps {}
public final class L_blockchain_ui_type_task: L, I_blockchain_ui_type_task {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task", comment: "") }
}
public protocol I_blockchain_ui_type_task: I {}
public extension I_blockchain_ui_type_task {
	var `paragraph`: L_blockchain_ui_type_task_paragraph { .init("\(__).paragraph") }
	var `section`: L_blockchain_ui_type_task_section { .init("\(__).section") }
}
public final class L_blockchain_ui_type_task_paragraph: L, I_blockchain_ui_type_task_paragraph {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task.paragraph", comment: "") }
}
public protocol I_blockchain_ui_type_task_paragraph: I_blockchain_db_field {}
public extension I_blockchain_ui_type_task_paragraph {
	var `button`: L_blockchain_ui_type_task_paragraph_button { .init("\(__).button") }
	var `divider`: L_blockchain_ui_type_task_paragraph_divider { .init("\(__).divider") }
	var `input`: L_blockchain_ui_type_task_paragraph_input { .init("\(__).input") }
	var `label`: L_blockchain_ui_type_task_paragraph_label { .init("\(__).label") }
	var `media`: L_blockchain_ui_type_task_paragraph_media { .init("\(__).media") }
	var `reference`: L_blockchain_ui_type_task_paragraph_reference { .init("\(__).reference") }
	var `row`: L_blockchain_ui_type_task_paragraph_row { .init("\(__).row") }
}
public final class L_blockchain_ui_type_task_paragraph_button: L, I_blockchain_ui_type_task_paragraph_button {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task.paragraph.button", comment: "") }
}
public protocol I_blockchain_ui_type_task_paragraph_button: I_blockchain_ui_type_button {}
public final class L_blockchain_ui_type_task_paragraph_divider: L, I_blockchain_ui_type_task_paragraph_divider {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task.paragraph.divider", comment: "") }
}
public protocol I_blockchain_ui_type_task_paragraph_divider: I {}
public extension I_blockchain_ui_type_task_paragraph_divider {
	var `style`: L_blockchain_ui_type_task_paragraph_divider_style { .init("\(__).style") }
}
public final class L_blockchain_ui_type_task_paragraph_divider_style: L, I_blockchain_ui_type_task_paragraph_divider_style {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task.paragraph.divider.style", comment: "") }
}
public protocol I_blockchain_ui_type_task_paragraph_divider_style: I_blockchain_ui_type_style {}
public final class L_blockchain_ui_type_task_paragraph_input: L, I_blockchain_ui_type_task_paragraph_input {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task.paragraph.input", comment: "") }
}
public protocol I_blockchain_ui_type_task_paragraph_input: I_blockchain_ui_type_input {}
public final class L_blockchain_ui_type_task_paragraph_label: L, I_blockchain_ui_type_task_paragraph_label {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task.paragraph.label", comment: "") }
}
public protocol I_blockchain_ui_type_task_paragraph_label: I_blockchain_ui_type_text {}
public final class L_blockchain_ui_type_task_paragraph_media: L, I_blockchain_ui_type_task_paragraph_media {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task.paragraph.media", comment: "") }
}
public protocol I_blockchain_ui_type_task_paragraph_media: I_blockchain_ui_type_media {}
public final class L_blockchain_ui_type_task_paragraph_reference: L, I_blockchain_ui_type_task_paragraph_reference {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task.paragraph.reference", comment: "") }
}
public protocol I_blockchain_ui_type_task_paragraph_reference: I_blockchain_db_type_tag {}
public final class L_blockchain_ui_type_task_paragraph_row: L, I_blockchain_ui_type_task_paragraph_row {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task.paragraph.row", comment: "") }
}
public protocol I_blockchain_ui_type_task_paragraph_row: I_blockchain_ui_type_row {}
public final class L_blockchain_ui_type_task_section: L, I_blockchain_ui_type_task_section {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task.section", comment: "") }
}
public protocol I_blockchain_ui_type_task_section: I_blockchain_db_field {}
public extension I_blockchain_ui_type_task_section {
	var `reference`: L_blockchain_ui_type_task_section_reference { .init("\(__).reference") }
	var `stack`: L_blockchain_ui_type_task_section_stack { .init("\(__).stack") }
}
public final class L_blockchain_ui_type_task_section_reference: L, I_blockchain_ui_type_task_section_reference {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task.section.reference", comment: "") }
}
public protocol I_blockchain_ui_type_task_section_reference: I_blockchain_db_type_tag {}
public final class L_blockchain_ui_type_task_section_stack: L, I_blockchain_ui_type_task_section_stack {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task.section.stack", comment: "") }
}
public protocol I_blockchain_ui_type_task_section_stack: I {}
public extension I_blockchain_ui_type_task_section_stack {
	var `horizontal`: L_blockchain_ui_type_task_section_stack_horizontal { .init("\(__).horizontal") }
	var `spacing`: L_blockchain_ui_type_task_section_stack_spacing { .init("\(__).spacing") }
	var `vertical`: L_blockchain_ui_type_task_section_stack_vertical { .init("\(__).vertical") }
}
public final class L_blockchain_ui_type_task_section_stack_horizontal: L, I_blockchain_ui_type_task_section_stack_horizontal {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task.section.stack.horizontal", comment: "") }
}
public protocol I_blockchain_ui_type_task_section_stack_horizontal: I {}
public extension I_blockchain_ui_type_task_section_stack_horizontal {
	var `tasks`: L_blockchain_ui_type_task_section_stack_horizontal_tasks { .init("\(__).tasks") }
}
public final class L_blockchain_ui_type_task_section_stack_horizontal_tasks: L, I_blockchain_ui_type_task_section_stack_horizontal_tasks {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task.section.stack.horizontal.tasks", comment: "") }
}
public protocol I_blockchain_ui_type_task_section_stack_horizontal_tasks: I_blockchain_ui_type_task, I_blockchain_db_type_array_of_maps {}
public final class L_blockchain_ui_type_task_section_stack_spacing: L, I_blockchain_ui_type_task_section_stack_spacing {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task.section.stack.spacing", comment: "") }
}
public protocol I_blockchain_ui_type_task_section_stack_spacing: I_blockchain_db_type_number {}
public final class L_blockchain_ui_type_task_section_stack_vertical: L, I_blockchain_ui_type_task_section_stack_vertical {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task.section.stack.vertical", comment: "") }
}
public protocol I_blockchain_ui_type_task_section_stack_vertical: I {}
public extension I_blockchain_ui_type_task_section_stack_vertical {
	var `tasks`: L_blockchain_ui_type_task_section_stack_vertical_tasks { .init("\(__).tasks") }
}
public final class L_blockchain_ui_type_task_section_stack_vertical_tasks: L, I_blockchain_ui_type_task_section_stack_vertical_tasks {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.task.section.stack.vertical.tasks", comment: "") }
}
public protocol I_blockchain_ui_type_task_section_stack_vertical_tasks: I_blockchain_ui_type_task, I_blockchain_db_type_array_of_maps {}
public final class L_blockchain_ui_type_text: L, I_blockchain_ui_type_text {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.text", comment: "") }
}
public protocol I_blockchain_ui_type_text: I {}
public extension I_blockchain_ui_type_text {
	var `body1`: L_blockchain_ui_type_text_body1 { .init("\(__).body1") }
	var `body2`: L_blockchain_ui_type_text_body2 { .init("\(__).body2") }
	var `caption1`: L_blockchain_ui_type_text_caption1 { .init("\(__).caption1") }
	var `caption2`: L_blockchain_ui_type_text_caption2 { .init("\(__).caption2") }
	var `display`: L_blockchain_ui_type_text_display { .init("\(__).display") }
	var `micro`: L_blockchain_ui_type_text_micro { .init("\(__).micro") }
	var `mono`: L_blockchain_ui_type_text_mono { .init("\(__).mono") }
	var `overline`: L_blockchain_ui_type_text_overline { .init("\(__).overline") }
	var `paragraph1`: L_blockchain_ui_type_text_paragraph1 { .init("\(__).paragraph1") }
	var `paragraph2`: L_blockchain_ui_type_text_paragraph2 { .init("\(__).paragraph2") }
	var `subheading`: L_blockchain_ui_type_text_subheading { .init("\(__).subheading") }
	var `title1`: L_blockchain_ui_type_text_title1 { .init("\(__).title1") }
	var `title2`: L_blockchain_ui_type_text_title2 { .init("\(__).title2") }
	var `title3`: L_blockchain_ui_type_text_title3 { .init("\(__).title3") }
}
public final class L_blockchain_ui_type_text_body1: L, I_blockchain_ui_type_text_body1 {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.text.body1", comment: "") }
}
public protocol I_blockchain_ui_type_text_body1: I_blockchain_ui_type_label {}
public final class L_blockchain_ui_type_text_body2: L, I_blockchain_ui_type_text_body2 {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.text.body2", comment: "") }
}
public protocol I_blockchain_ui_type_text_body2: I_blockchain_ui_type_label {}
public final class L_blockchain_ui_type_text_caption1: L, I_blockchain_ui_type_text_caption1 {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.text.caption1", comment: "") }
}
public protocol I_blockchain_ui_type_text_caption1: I_blockchain_ui_type_label {}
public final class L_blockchain_ui_type_text_caption2: L, I_blockchain_ui_type_text_caption2 {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.text.caption2", comment: "") }
}
public protocol I_blockchain_ui_type_text_caption2: I_blockchain_ui_type_label {}
public final class L_blockchain_ui_type_text_display: L, I_blockchain_ui_type_text_display {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.text.display", comment: "") }
}
public protocol I_blockchain_ui_type_text_display: I_blockchain_ui_type_label {}
public final class L_blockchain_ui_type_text_micro: L, I_blockchain_ui_type_text_micro {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.text.micro", comment: "") }
}
public protocol I_blockchain_ui_type_text_micro: I_blockchain_ui_type_label {}
public final class L_blockchain_ui_type_text_mono: L, I_blockchain_ui_type_text_mono {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.text.mono", comment: "") }
}
public protocol I_blockchain_ui_type_text_mono: I {}
public extension I_blockchain_ui_type_text_mono {
	var `body`: L_blockchain_ui_type_text_mono_body { .init("\(__).body") }
	var `paragraph`: L_blockchain_ui_type_text_mono_paragraph { .init("\(__).paragraph") }
}
public final class L_blockchain_ui_type_text_mono_body: L, I_blockchain_ui_type_text_mono_body {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.text.mono.body", comment: "") }
}
public protocol I_blockchain_ui_type_text_mono_body: I_blockchain_ui_type_label {}
public final class L_blockchain_ui_type_text_mono_paragraph: L, I_blockchain_ui_type_text_mono_paragraph {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.text.mono.paragraph", comment: "") }
}
public protocol I_blockchain_ui_type_text_mono_paragraph: I_blockchain_ui_type_label {}
public final class L_blockchain_ui_type_text_overline: L, I_blockchain_ui_type_text_overline {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.text.overline", comment: "") }
}
public protocol I_blockchain_ui_type_text_overline: I_blockchain_ui_type_label {}
public final class L_blockchain_ui_type_text_paragraph1: L, I_blockchain_ui_type_text_paragraph1 {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.text.paragraph1", comment: "") }
}
public protocol I_blockchain_ui_type_text_paragraph1: I_blockchain_ui_type_label {}
public final class L_blockchain_ui_type_text_paragraph2: L, I_blockchain_ui_type_text_paragraph2 {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.text.paragraph2", comment: "") }
}
public protocol I_blockchain_ui_type_text_paragraph2: I_blockchain_ui_type_label {}
public final class L_blockchain_ui_type_text_subheading: L, I_blockchain_ui_type_text_subheading {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.text.subheading", comment: "") }
}
public protocol I_blockchain_ui_type_text_subheading: I_blockchain_ui_type_label {}
public final class L_blockchain_ui_type_text_title1: L, I_blockchain_ui_type_text_title1 {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.text.title1", comment: "") }
}
public protocol I_blockchain_ui_type_text_title1: I_blockchain_ui_type_label {}
public final class L_blockchain_ui_type_text_title2: L, I_blockchain_ui_type_text_title2 {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.text.title2", comment: "") }
}
public protocol I_blockchain_ui_type_text_title2: I_blockchain_ui_type_label {}
public final class L_blockchain_ui_type_text_title3: L, I_blockchain_ui_type_text_title3 {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.text.title3", comment: "") }
}
public protocol I_blockchain_ui_type_text_title3: I_blockchain_ui_type_label {}
public final class L_blockchain_ui_type_texture: L, I_blockchain_ui_type_texture {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.texture", comment: "") }
}
public protocol I_blockchain_ui_type_texture: I {}
public extension I_blockchain_ui_type_texture {
	var `color`: L_blockchain_ui_type_texture_color { .init("\(__).color") }
	var `gradient`: L_blockchain_ui_type_texture_gradient { .init("\(__).gradient") }
	var `media`: L_blockchain_ui_type_texture_media { .init("\(__).media") }
}
public final class L_blockchain_ui_type_texture_color: L, I_blockchain_ui_type_texture_color {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.texture.color", comment: "") }
}
public protocol I_blockchain_ui_type_texture_color: I_blockchain_ui_type_color {}
public final class L_blockchain_ui_type_texture_gradient: L, I_blockchain_ui_type_texture_gradient {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.texture.gradient", comment: "") }
}
public protocol I_blockchain_ui_type_texture_gradient: I_blockchain_ui_type_gradient {}
public final class L_blockchain_ui_type_texture_media: L, I_blockchain_ui_type_texture_media {
	public override class var localized: String { NSLocalizedString("blockchain.ui.type.texture.media", comment: "") }
}
public protocol I_blockchain_ui_type_texture_media: I_blockchain_ui_type_media {}
public final class L_blockchain_user: L, I_blockchain_user {
	public override class var localized: String { NSLocalizedString("blockchain.user", comment: "") }
}
public protocol I_blockchain_user: I_blockchain_db_collection {}
public extension I_blockchain_user {
	var `account`: L_blockchain_user_account { .init("\(__).account") }
	var `address`: L_blockchain_user_address { .init("\(__).address") }
	var `creation`: L_blockchain_user_creation { .init("\(__).creation") }
	var `currency`: L_blockchain_user_currency { .init("\(__).currency") }
	var `earn`: L_blockchain_user_earn { .init("\(__).earn") }
	var `email`: L_blockchain_user_email { .init("\(__).email") }
	var `event`: L_blockchain_user_event { .init("\(__).event") }
	var `is`: L_blockchain_user_is { .init("\(__).is") }
	var `name`: L_blockchain_user_name { .init("\(__).name") }
	var `referral`: L_blockchain_user_referral { .init("\(__).referral") }
	var `skipped`: L_blockchain_user_skipped { .init("\(__).skipped") }
	var `token`: L_blockchain_user_token { .init("\(__).token") }
	var `trading`: L_blockchain_user_trading { .init("\(__).trading") }
	var `wallet`: L_blockchain_user_wallet { .init("\(__).wallet") }
}
public final class L_blockchain_user_account: L, I_blockchain_user_account {
	public override class var localized: String { NSLocalizedString("blockchain.user.account", comment: "") }
}
public protocol I_blockchain_user_account: I {}
public extension I_blockchain_user_account {
	var `kyc`: L_blockchain_user_account_kyc { .init("\(__).kyc") }
	var `tier`: L_blockchain_user_account_tier { .init("\(__).tier") }
}
public final class L_blockchain_user_account_kyc: L, I_blockchain_user_account_kyc {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.kyc", comment: "") }
}
public protocol I_blockchain_user_account_kyc: I_blockchain_db_collection {}
public extension I_blockchain_user_account_kyc {
	var `limits`: L_blockchain_user_account_kyc_limits { .init("\(__).limits") }
	var `name`: L_blockchain_user_account_kyc_name { .init("\(__).name") }
	var `state`: L_blockchain_user_account_kyc_state { .init("\(__).state") }
}
public final class L_blockchain_user_account_kyc_limits: L, I_blockchain_user_account_kyc_limits {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.kyc.limits", comment: "") }
}
public protocol I_blockchain_user_account_kyc_limits: I {}
public extension I_blockchain_user_account_kyc_limits {
	var `annual`: L_blockchain_user_account_kyc_limits_annual { .init("\(__).annual") }
	var `currency`: L_blockchain_user_account_kyc_limits_currency { .init("\(__).currency") }
	var `daily`: L_blockchain_user_account_kyc_limits_daily { .init("\(__).daily") }
}
public final class L_blockchain_user_account_kyc_limits_annual: L, I_blockchain_user_account_kyc_limits_annual {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.kyc.limits.annual", comment: "") }
}
public protocol I_blockchain_user_account_kyc_limits_annual: I_blockchain_db_type_bigint {}
public final class L_blockchain_user_account_kyc_limits_currency: L, I_blockchain_user_account_kyc_limits_currency {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.kyc.limits.currency", comment: "") }
}
public protocol I_blockchain_user_account_kyc_limits_currency: I_blockchain_db_type_string {}
public final class L_blockchain_user_account_kyc_limits_daily: L, I_blockchain_user_account_kyc_limits_daily {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.kyc.limits.daily", comment: "") }
}
public protocol I_blockchain_user_account_kyc_limits_daily: I_blockchain_db_type_bigint {}
public final class L_blockchain_user_account_kyc_name: L, I_blockchain_user_account_kyc_name {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.kyc.name", comment: "") }
}
public protocol I_blockchain_user_account_kyc_name: I_blockchain_db_type_string {}
public final class L_blockchain_user_account_kyc_state: L, I_blockchain_user_account_kyc_state {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.kyc.state", comment: "") }
}
public protocol I_blockchain_user_account_kyc_state: I_blockchain_db_type_enum {}
public extension I_blockchain_user_account_kyc_state {
	var `expired`: L_blockchain_user_account_kyc_state_expired { .init("\(__).expired") }
	var `none`: L_blockchain_user_account_kyc_state_none { .init("\(__).none") }
	var `pending`: L_blockchain_user_account_kyc_state_pending { .init("\(__).pending") }
	var `rejected`: L_blockchain_user_account_kyc_state_rejected { .init("\(__).rejected") }
	var `under_review`: L_blockchain_user_account_kyc_state_under__review { .init("\(__).under_review") }
	var `verified`: L_blockchain_user_account_kyc_state_verified { .init("\(__).verified") }
}
public final class L_blockchain_user_account_kyc_state_expired: L, I_blockchain_user_account_kyc_state_expired {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.kyc.state.expired", comment: "") }
}
public protocol I_blockchain_user_account_kyc_state_expired: I {}
public final class L_blockchain_user_account_kyc_state_none: L, I_blockchain_user_account_kyc_state_none {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.kyc.state.none", comment: "") }
}
public protocol I_blockchain_user_account_kyc_state_none: I {}
public final class L_blockchain_user_account_kyc_state_pending: L, I_blockchain_user_account_kyc_state_pending {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.kyc.state.pending", comment: "") }
}
public protocol I_blockchain_user_account_kyc_state_pending: I {}
public final class L_blockchain_user_account_kyc_state_rejected: L, I_blockchain_user_account_kyc_state_rejected {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.kyc.state.rejected", comment: "") }
}
public protocol I_blockchain_user_account_kyc_state_rejected: I {}
public final class L_blockchain_user_account_kyc_state_under__review: L, I_blockchain_user_account_kyc_state_under__review {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.kyc.state.under_review", comment: "") }
}
public protocol I_blockchain_user_account_kyc_state_under__review: I {}
public final class L_blockchain_user_account_kyc_state_verified: L, I_blockchain_user_account_kyc_state_verified {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.kyc.state.verified", comment: "") }
}
public protocol I_blockchain_user_account_kyc_state_verified: I {}
public final class L_blockchain_user_account_tier: L, I_blockchain_user_account_tier {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.tier", comment: "") }
}
public protocol I_blockchain_user_account_tier: I_blockchain_db_type_enum {}
public extension I_blockchain_user_account_tier {
	var `gold`: L_blockchain_user_account_tier_gold { .init("\(__).gold") }
	var `none`: L_blockchain_user_account_tier_none { .init("\(__).none") }
	var `platinum`: L_blockchain_user_account_tier_platinum { .init("\(__).platinum") }
	var `silver`: L_blockchain_user_account_tier_silver { .init("\(__).silver") }
}
public final class L_blockchain_user_account_tier_gold: L, I_blockchain_user_account_tier_gold {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.tier.gold", comment: "") }
}
public protocol I_blockchain_user_account_tier_gold: I {}
public final class L_blockchain_user_account_tier_none: L, I_blockchain_user_account_tier_none {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.tier.none", comment: "") }
}
public protocol I_blockchain_user_account_tier_none: I {}
public final class L_blockchain_user_account_tier_platinum: L, I_blockchain_user_account_tier_platinum {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.tier.platinum", comment: "") }
}
public protocol I_blockchain_user_account_tier_platinum: I {}
public final class L_blockchain_user_account_tier_silver: L, I_blockchain_user_account_tier_silver {
	public override class var localized: String { NSLocalizedString("blockchain.user.account.tier.silver", comment: "") }
}
public protocol I_blockchain_user_account_tier_silver: I {}
public final class L_blockchain_user_address: L, I_blockchain_user_address {
	public override class var localized: String { NSLocalizedString("blockchain.user.address", comment: "") }
}
public protocol I_blockchain_user_address: I {}
public extension I_blockchain_user_address {
	var `city`: L_blockchain_user_address_city { .init("\(__).city") }
	var `country`: L_blockchain_user_address_country { .init("\(__).country") }
	var `line_1`: L_blockchain_user_address_line__1 { .init("\(__).line_1") }
	var `line_2`: L_blockchain_user_address_line__2 { .init("\(__).line_2") }
	var `postal`: L_blockchain_user_address_postal { .init("\(__).postal") }
	var `state`: L_blockchain_user_address_state { .init("\(__).state") }
}
public final class L_blockchain_user_address_city: L, I_blockchain_user_address_city {
	public override class var localized: String { NSLocalizedString("blockchain.user.address.city", comment: "") }
}
public protocol I_blockchain_user_address_city: I_blockchain_db_type_string {}
public final class L_blockchain_user_address_country: L, I_blockchain_user_address_country {
	public override class var localized: String { NSLocalizedString("blockchain.user.address.country", comment: "") }
}
public protocol I_blockchain_user_address_country: I {}
public extension I_blockchain_user_address_country {
	var `code`: L_blockchain_user_address_country_code { .init("\(__).code") }
}
public final class L_blockchain_user_address_country_code: L, I_blockchain_user_address_country_code {
	public override class var localized: String { NSLocalizedString("blockchain.user.address.country.code", comment: "") }
}
public protocol I_blockchain_user_address_country_code: I_blockchain_db_type_string {}
public final class L_blockchain_user_address_line__1: L, I_blockchain_user_address_line__1 {
	public override class var localized: String { NSLocalizedString("blockchain.user.address.line_1", comment: "") }
}
public protocol I_blockchain_user_address_line__1: I_blockchain_db_type_string {}
public final class L_blockchain_user_address_line__2: L, I_blockchain_user_address_line__2 {
	public override class var localized: String { NSLocalizedString("blockchain.user.address.line_2", comment: "") }
}
public protocol I_blockchain_user_address_line__2: I_blockchain_db_type_string {}
public final class L_blockchain_user_address_postal: L, I_blockchain_user_address_postal {
	public override class var localized: String { NSLocalizedString("blockchain.user.address.postal", comment: "") }
}
public protocol I_blockchain_user_address_postal: I {}
public extension I_blockchain_user_address_postal {
	var `code`: L_blockchain_user_address_postal_code { .init("\(__).code") }
}
public final class L_blockchain_user_address_postal_code: L, I_blockchain_user_address_postal_code {
	public override class var localized: String { NSLocalizedString("blockchain.user.address.postal.code", comment: "") }
}
public protocol I_blockchain_user_address_postal_code: I_blockchain_db_type_string {}
public final class L_blockchain_user_address_state: L, I_blockchain_user_address_state {
	public override class var localized: String { NSLocalizedString("blockchain.user.address.state", comment: "") }
}
public protocol I_blockchain_user_address_state: I_blockchain_db_type_string {}
public final class L_blockchain_user_creation: L, I_blockchain_user_creation {
	public override class var localized: String { NSLocalizedString("blockchain.user.creation", comment: "") }
}
public protocol I_blockchain_user_creation: I {}
public extension I_blockchain_user_creation {
	var `referral`: L_blockchain_user_creation_referral { .init("\(__).referral") }
}
public final class L_blockchain_user_creation_referral: L, I_blockchain_user_creation_referral {
	public override class var localized: String { NSLocalizedString("blockchain.user.creation.referral", comment: "") }
}
public protocol I_blockchain_user_creation_referral: I {}
public extension I_blockchain_user_creation_referral {
	var `code`: L_blockchain_user_creation_referral_code { .init("\(__).code") }
}
public final class L_blockchain_user_creation_referral_code: L, I_blockchain_user_creation_referral_code {
	public override class var localized: String { NSLocalizedString("blockchain.user.creation.referral.code", comment: "") }
}
public protocol I_blockchain_user_creation_referral_code: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_user_currency: L, I_blockchain_user_currency {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency", comment: "") }
}
public protocol I_blockchain_user_currency: I {}
public extension I_blockchain_user_currency {
	var `available`: L_blockchain_user_currency_available { .init("\(__).available") }
	var `currencies`: L_blockchain_user_currency_currencies { .init("\(__).currencies") }
	var `default`: L_blockchain_user_currency_default { .init("\(__).default") }
	var `preferred`: L_blockchain_user_currency_preferred { .init("\(__).preferred") }
}
public final class L_blockchain_user_currency_available: L, I_blockchain_user_currency_available {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.available", comment: "") }
}
public protocol I_blockchain_user_currency_available: I {}
public extension I_blockchain_user_currency_available {
	var `currencies`: L_blockchain_user_currency_available_currencies { .init("\(__).currencies") }
}
public final class L_blockchain_user_currency_available_currencies: L, I_blockchain_user_currency_available_currencies {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.available.currencies", comment: "") }
}
public protocol I_blockchain_user_currency_available_currencies: I_blockchain_db_array, I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_user_currency_currencies: L, I_blockchain_user_currency_currencies {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.currencies", comment: "") }
}
public protocol I_blockchain_user_currency_currencies: I_blockchain_db_array, I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_user_currency_default: L, I_blockchain_user_currency_default {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.default", comment: "") }
}
public protocol I_blockchain_user_currency_default: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_user_currency_preferred: L, I_blockchain_user_currency_preferred {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.preferred", comment: "") }
}
public protocol I_blockchain_user_currency_preferred: I {}
public extension I_blockchain_user_currency_preferred {
	var `fiat`: L_blockchain_user_currency_preferred_fiat { .init("\(__).fiat") }
}
public final class L_blockchain_user_currency_preferred_fiat: L, I_blockchain_user_currency_preferred_fiat {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.preferred.fiat", comment: "") }
}
public protocol I_blockchain_user_currency_preferred_fiat: I {}
public extension I_blockchain_user_currency_preferred_fiat {
	var `display`: L_blockchain_user_currency_preferred_fiat_display { .init("\(__).display") }
	var `trading`: L_blockchain_user_currency_preferred_fiat_trading { .init("\(__).trading") }
}
public final class L_blockchain_user_currency_preferred_fiat_display: L, I_blockchain_user_currency_preferred_fiat_display {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.preferred.fiat.display", comment: "") }
}
public protocol I_blockchain_user_currency_preferred_fiat_display: I {}
public extension I_blockchain_user_currency_preferred_fiat_display {
	var `currency`: L_blockchain_user_currency_preferred_fiat_display_currency { .init("\(__).currency") }
}
public final class L_blockchain_user_currency_preferred_fiat_display_currency: L, I_blockchain_user_currency_preferred_fiat_display_currency {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.preferred.fiat.display.currency", comment: "") }
}
public protocol I_blockchain_user_currency_preferred_fiat_display_currency: I_blockchain_session_state_value, I_blockchain_type_currency {}
public final class L_blockchain_user_currency_preferred_fiat_trading: L, I_blockchain_user_currency_preferred_fiat_trading {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.preferred.fiat.trading", comment: "") }
}
public protocol I_blockchain_user_currency_preferred_fiat_trading: I {}
public extension I_blockchain_user_currency_preferred_fiat_trading {
	var `currency`: L_blockchain_user_currency_preferred_fiat_trading_currency { .init("\(__).currency") }
}
public final class L_blockchain_user_currency_preferred_fiat_trading_currency: L, I_blockchain_user_currency_preferred_fiat_trading_currency {
	public override class var localized: String { NSLocalizedString("blockchain.user.currency.preferred.fiat.trading.currency", comment: "") }
}
public protocol I_blockchain_user_currency_preferred_fiat_trading_currency: I_blockchain_session_state_value, I_blockchain_type_currency {}
public final class L_blockchain_user_earn: L, I_blockchain_user_earn {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn", comment: "") }
}
public protocol I_blockchain_user_earn: I {}
public extension I_blockchain_user_earn {
	var `product`: L_blockchain_user_earn_product { .init("\(__).product") }
}
public final class L_blockchain_user_earn_product: L, I_blockchain_user_earn_product {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product", comment: "") }
}
public protocol I_blockchain_user_earn_product: I_blockchain_db_collection {}
public extension I_blockchain_user_earn_product {
	var `all`: L_blockchain_user_earn_product_all { .init("\(__).all") }
	var `asset`: L_blockchain_user_earn_product_asset { .init("\(__).asset") }
	var `has`: L_blockchain_user_earn_product_has { .init("\(__).has") }
}
public final class L_blockchain_user_earn_product_all: L, I_blockchain_user_earn_product_all {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.all", comment: "") }
}
public protocol I_blockchain_user_earn_product_all: I {}
public extension I_blockchain_user_earn_product_all {
	var `assets`: L_blockchain_user_earn_product_all_assets { .init("\(__).assets") }
}
public final class L_blockchain_user_earn_product_all_assets: L, I_blockchain_user_earn_product_all_assets {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.all.assets", comment: "") }
}
public protocol I_blockchain_user_earn_product_all_assets: I_blockchain_db_type_array_of_strings {}
public final class L_blockchain_user_earn_product_asset: L, I_blockchain_user_earn_product_asset {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset: I_blockchain_db_collection {}
public extension I_blockchain_user_earn_product_asset {
	var `account`: L_blockchain_user_earn_product_asset_account { .init("\(__).account") }
	var `activity`: L_blockchain_user_earn_product_asset_activity { .init("\(__).activity") }
	var `address`: L_blockchain_user_earn_product_asset_address { .init("\(__).address") }
	var `is`: L_blockchain_user_earn_product_asset_is { .init("\(__).is") }
	var `limit`: L_blockchain_user_earn_product_asset_limit { .init("\(__).limit") }
	var `rates`: L_blockchain_user_earn_product_asset_rates { .init("\(__).rates") }
}
public final class L_blockchain_user_earn_product_asset_account: L, I_blockchain_user_earn_product_asset_account {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.account", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_account: I {}
public extension I_blockchain_user_earn_product_asset_account {
	var `balance`: L_blockchain_user_earn_product_asset_account_balance { .init("\(__).balance") }
	var `bonding`: L_blockchain_user_earn_product_asset_account_bonding { .init("\(__).bonding") }
	var `locked`: L_blockchain_user_earn_product_asset_account_locked { .init("\(__).locked") }
	var `pending`: L_blockchain_user_earn_product_asset_account_pending { .init("\(__).pending") }
	var `total`: L_blockchain_user_earn_product_asset_account_total { .init("\(__).total") }
	var `unbonding`: L_blockchain_user_earn_product_asset_account_unbonding { .init("\(__).unbonding") }
}
public final class L_blockchain_user_earn_product_asset_account_balance: L, I_blockchain_user_earn_product_asset_account_balance {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.account.balance", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_account_balance: I_blockchain_type_money {}
public final class L_blockchain_user_earn_product_asset_account_bonding: L, I_blockchain_user_earn_product_asset_account_bonding {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.account.bonding", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_account_bonding: I {}
public extension I_blockchain_user_earn_product_asset_account_bonding {
	var `deposits`: L_blockchain_user_earn_product_asset_account_bonding_deposits { .init("\(__).deposits") }
}
public final class L_blockchain_user_earn_product_asset_account_bonding_deposits: L, I_blockchain_user_earn_product_asset_account_bonding_deposits {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.account.bonding.deposits", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_account_bonding_deposits: I_blockchain_type_money {}
public final class L_blockchain_user_earn_product_asset_account_locked: L, I_blockchain_user_earn_product_asset_account_locked {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.account.locked", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_account_locked: I_blockchain_type_money {}
public final class L_blockchain_user_earn_product_asset_account_pending: L, I_blockchain_user_earn_product_asset_account_pending {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.account.pending", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_account_pending: I {}
public extension I_blockchain_user_earn_product_asset_account_pending {
	var `deposit`: L_blockchain_user_earn_product_asset_account_pending_deposit { .init("\(__).deposit") }
	var `withdrawal`: L_blockchain_user_earn_product_asset_account_pending_withdrawal { .init("\(__).withdrawal") }
}
public final class L_blockchain_user_earn_product_asset_account_pending_deposit: L, I_blockchain_user_earn_product_asset_account_pending_deposit {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.account.pending.deposit", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_account_pending_deposit: I_blockchain_type_money {}
public final class L_blockchain_user_earn_product_asset_account_pending_withdrawal: L, I_blockchain_user_earn_product_asset_account_pending_withdrawal {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.account.pending.withdrawal", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_account_pending_withdrawal: I_blockchain_type_money {}
public final class L_blockchain_user_earn_product_asset_account_total: L, I_blockchain_user_earn_product_asset_account_total {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.account.total", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_account_total: I {}
public extension I_blockchain_user_earn_product_asset_account_total {
	var `rewards`: L_blockchain_user_earn_product_asset_account_total_rewards { .init("\(__).rewards") }
}
public final class L_blockchain_user_earn_product_asset_account_total_rewards: L, I_blockchain_user_earn_product_asset_account_total_rewards {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.account.total.rewards", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_account_total_rewards: I_blockchain_type_money {}
public final class L_blockchain_user_earn_product_asset_account_unbonding: L, I_blockchain_user_earn_product_asset_account_unbonding {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.account.unbonding", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_account_unbonding: I {}
public extension I_blockchain_user_earn_product_asset_account_unbonding {
	var `withdrawals`: L_blockchain_user_earn_product_asset_account_unbonding_withdrawals { .init("\(__).withdrawals") }
}
public final class L_blockchain_user_earn_product_asset_account_unbonding_withdrawals: L, I_blockchain_user_earn_product_asset_account_unbonding_withdrawals {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.account.unbonding.withdrawals", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_account_unbonding_withdrawals: I_blockchain_type_money {}
public final class L_blockchain_user_earn_product_asset_activity: L, I_blockchain_user_earn_product_asset_activity {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.activity", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_activity: I_blockchain_db_type_array_of_maps {}
public final class L_blockchain_user_earn_product_asset_address: L, I_blockchain_user_earn_product_asset_address {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.address", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_address: I_blockchain_db_type_string {}
public final class L_blockchain_user_earn_product_asset_is: L, I_blockchain_user_earn_product_asset_is {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.is", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_is: I {}
public extension I_blockchain_user_earn_product_asset_is {
	var `eligible`: L_blockchain_user_earn_product_asset_is_eligible { .init("\(__).eligible") }
}
public final class L_blockchain_user_earn_product_asset_is_eligible: L, I_blockchain_user_earn_product_asset_is_eligible {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.is.eligible", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_is_eligible: I_blockchain_db_type_boolean {}
public final class L_blockchain_user_earn_product_asset_limit: L, I_blockchain_user_earn_product_asset_limit {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit: I {}
public extension I_blockchain_user_earn_product_asset_limit {
	var `days`: L_blockchain_user_earn_product_asset_limit_days { .init("\(__).days") }
	var `lock`: L_blockchain_user_earn_product_asset_limit_lock { .init("\(__).lock") }
	var `maximum`: L_blockchain_user_earn_product_asset_limit_maximum { .init("\(__).maximum") }
	var `minimum`: L_blockchain_user_earn_product_asset_limit_minimum { .init("\(__).minimum") }
	var `reward`: L_blockchain_user_earn_product_asset_limit_reward { .init("\(__).reward") }
	var `withdraw`: L_blockchain_user_earn_product_asset_limit_withdraw { .init("\(__).withdraw") }
}
public final class L_blockchain_user_earn_product_asset_limit_days: L, I_blockchain_user_earn_product_asset_limit_days {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.days", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_days: I {}
public extension I_blockchain_user_earn_product_asset_limit_days {
	var `bonding`: L_blockchain_user_earn_product_asset_limit_days_bonding { .init("\(__).bonding") }
	var `unbonding`: L_blockchain_user_earn_product_asset_limit_days_unbonding { .init("\(__).unbonding") }
}
public final class L_blockchain_user_earn_product_asset_limit_days_bonding: L, I_blockchain_user_earn_product_asset_limit_days_bonding {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.days.bonding", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_days_bonding: I_blockchain_db_type_integer {}
public final class L_blockchain_user_earn_product_asset_limit_days_unbonding: L, I_blockchain_user_earn_product_asset_limit_days_unbonding {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.days.unbonding", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_days_unbonding: I_blockchain_db_type_integer {}
public final class L_blockchain_user_earn_product_asset_limit_lock: L, I_blockchain_user_earn_product_asset_limit_lock {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.lock", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_lock: I {}
public extension I_blockchain_user_earn_product_asset_limit_lock {
	var `up`: L_blockchain_user_earn_product_asset_limit_lock_up { .init("\(__).up") }
}
public final class L_blockchain_user_earn_product_asset_limit_lock_up: L, I_blockchain_user_earn_product_asset_limit_lock_up {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.lock.up", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_lock_up: I {}
public extension I_blockchain_user_earn_product_asset_limit_lock_up {
	var `duration`: L_blockchain_user_earn_product_asset_limit_lock_up_duration { .init("\(__).duration") }
}
public final class L_blockchain_user_earn_product_asset_limit_lock_up_duration: L, I_blockchain_user_earn_product_asset_limit_lock_up_duration {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.lock.up.duration", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_lock_up_duration: I_blockchain_db_type_integer {}
public final class L_blockchain_user_earn_product_asset_limit_maximum: L, I_blockchain_user_earn_product_asset_limit_maximum {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.maximum", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_maximum: I {}
public extension I_blockchain_user_earn_product_asset_limit_maximum {
	var `withdraw`: L_blockchain_user_earn_product_asset_limit_maximum_withdraw { .init("\(__).withdraw") }
}
public final class L_blockchain_user_earn_product_asset_limit_maximum_withdraw: L, I_blockchain_user_earn_product_asset_limit_maximum_withdraw {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.maximum.withdraw", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_maximum_withdraw: I {}
public extension I_blockchain_user_earn_product_asset_limit_maximum_withdraw {
	var `value`: L_blockchain_user_earn_product_asset_limit_maximum_withdraw_value { .init("\(__).value") }
}
public final class L_blockchain_user_earn_product_asset_limit_maximum_withdraw_value: L, I_blockchain_user_earn_product_asset_limit_maximum_withdraw_value {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.maximum.withdraw.value", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_maximum_withdraw_value: I_blockchain_type_money {}
public final class L_blockchain_user_earn_product_asset_limit_minimum: L, I_blockchain_user_earn_product_asset_limit_minimum {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.minimum", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_minimum: I {}
public extension I_blockchain_user_earn_product_asset_limit_minimum {
	var `deposit`: L_blockchain_user_earn_product_asset_limit_minimum_deposit { .init("\(__).deposit") }
}
public final class L_blockchain_user_earn_product_asset_limit_minimum_deposit: L, I_blockchain_user_earn_product_asset_limit_minimum_deposit {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.minimum.deposit", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_minimum_deposit: I {}
public extension I_blockchain_user_earn_product_asset_limit_minimum_deposit {
	var `value`: L_blockchain_user_earn_product_asset_limit_minimum_deposit_value { .init("\(__).value") }
}
public final class L_blockchain_user_earn_product_asset_limit_minimum_deposit_value: L, I_blockchain_user_earn_product_asset_limit_minimum_deposit_value {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.minimum.deposit.value", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_minimum_deposit_value: I_blockchain_type_money {}
public final class L_blockchain_user_earn_product_asset_limit_reward: L, I_blockchain_user_earn_product_asset_limit_reward {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.reward", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_reward: I {}
public extension I_blockchain_user_earn_product_asset_limit_reward {
	var `frequency`: L_blockchain_user_earn_product_asset_limit_reward_frequency { .init("\(__).frequency") }
}
public final class L_blockchain_user_earn_product_asset_limit_reward_frequency: L, I_blockchain_user_earn_product_asset_limit_reward_frequency {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.reward.frequency", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_reward_frequency: I_blockchain_db_type_enum {}
public extension I_blockchain_user_earn_product_asset_limit_reward_frequency {
	var `daily`: L_blockchain_user_earn_product_asset_limit_reward_frequency_daily { .init("\(__).daily") }
	var `monthly`: L_blockchain_user_earn_product_asset_limit_reward_frequency_monthly { .init("\(__).monthly") }
	var `weekly`: L_blockchain_user_earn_product_asset_limit_reward_frequency_weekly { .init("\(__).weekly") }
}
public final class L_blockchain_user_earn_product_asset_limit_reward_frequency_daily: L, I_blockchain_user_earn_product_asset_limit_reward_frequency_daily {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.reward.frequency.daily", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_reward_frequency_daily: I {}
public final class L_blockchain_user_earn_product_asset_limit_reward_frequency_monthly: L, I_blockchain_user_earn_product_asset_limit_reward_frequency_monthly {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.reward.frequency.monthly", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_reward_frequency_monthly: I {}
public final class L_blockchain_user_earn_product_asset_limit_reward_frequency_weekly: L, I_blockchain_user_earn_product_asset_limit_reward_frequency_weekly {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.reward.frequency.weekly", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_reward_frequency_weekly: I {}
public final class L_blockchain_user_earn_product_asset_limit_withdraw: L, I_blockchain_user_earn_product_asset_limit_withdraw {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.withdraw", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_withdraw: I {}
public extension I_blockchain_user_earn_product_asset_limit_withdraw {
	var `is`: L_blockchain_user_earn_product_asset_limit_withdraw_is { .init("\(__).is") }
}
public final class L_blockchain_user_earn_product_asset_limit_withdraw_is: L, I_blockchain_user_earn_product_asset_limit_withdraw_is {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.withdraw.is", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_withdraw_is: I {}
public extension I_blockchain_user_earn_product_asset_limit_withdraw_is {
	var `disabled`: L_blockchain_user_earn_product_asset_limit_withdraw_is_disabled { .init("\(__).disabled") }
}
public final class L_blockchain_user_earn_product_asset_limit_withdraw_is_disabled: L, I_blockchain_user_earn_product_asset_limit_withdraw_is_disabled {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.limit.withdraw.is.disabled", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_limit_withdraw_is_disabled: I_blockchain_db_type_boolean {}
public final class L_blockchain_user_earn_product_asset_rates: L, I_blockchain_user_earn_product_asset_rates {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.rates", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_rates: I {}
public extension I_blockchain_user_earn_product_asset_rates {
	var `commission`: L_blockchain_user_earn_product_asset_rates_commission { .init("\(__).commission") }
	var `rate`: L_blockchain_user_earn_product_asset_rates_rate { .init("\(__).rate") }
}
public final class L_blockchain_user_earn_product_asset_rates_commission: L, I_blockchain_user_earn_product_asset_rates_commission {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.rates.commission", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_rates_commission: I_blockchain_db_type_number {}
public final class L_blockchain_user_earn_product_asset_rates_rate: L, I_blockchain_user_earn_product_asset_rates_rate {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.asset.rates.rate", comment: "") }
}
public protocol I_blockchain_user_earn_product_asset_rates_rate: I_blockchain_db_type_number {}
public final class L_blockchain_user_earn_product_has: L, I_blockchain_user_earn_product_has {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.has", comment: "") }
}
public protocol I_blockchain_user_earn_product_has: I {}
public extension I_blockchain_user_earn_product_has {
	var `balance`: L_blockchain_user_earn_product_has_balance { .init("\(__).balance") }
}
public final class L_blockchain_user_earn_product_has_balance: L, I_blockchain_user_earn_product_has_balance {
	public override class var localized: String { NSLocalizedString("blockchain.user.earn.product.has.balance", comment: "") }
}
public protocol I_blockchain_user_earn_product_has_balance: I_blockchain_db_type_boolean {}
public final class L_blockchain_user_email: L, I_blockchain_user_email {
	public override class var localized: String { NSLocalizedString("blockchain.user.email", comment: "") }
}
public protocol I_blockchain_user_email: I {}
public extension I_blockchain_user_email {
	var `address`: L_blockchain_user_email_address { .init("\(__).address") }
	var `is`: L_blockchain_user_email_is { .init("\(__).is") }
}
public final class L_blockchain_user_email_address: L, I_blockchain_user_email_address {
	public override class var localized: String { NSLocalizedString("blockchain.user.email.address", comment: "") }
}
public protocol I_blockchain_user_email_address: I_blockchain_db_type_string {}
public final class L_blockchain_user_email_is: L, I_blockchain_user_email_is {
	public override class var localized: String { NSLocalizedString("blockchain.user.email.is", comment: "") }
}
public protocol I_blockchain_user_email_is: I {}
public extension I_blockchain_user_email_is {
	var `verified`: L_blockchain_user_email_is_verified { .init("\(__).verified") }
}
public final class L_blockchain_user_email_is_verified: L, I_blockchain_user_email_is_verified {
	public override class var localized: String { NSLocalizedString("blockchain.user.email.is.verified", comment: "") }
}
public protocol I_blockchain_user_email_is_verified: I_blockchain_db_type_boolean {}
public final class L_blockchain_user_event: L, I_blockchain_user_event {
	public override class var localized: String { NSLocalizedString("blockchain.user.event", comment: "") }
}
public protocol I_blockchain_user_event: I {}
public extension I_blockchain_user_event {
	var `did`: L_blockchain_user_event_did { .init("\(__).did") }
}
public final class L_blockchain_user_event_did: L, I_blockchain_user_event_did {
	public override class var localized: String { NSLocalizedString("blockchain.user.event.did", comment: "") }
}
public protocol I_blockchain_user_event_did: I {}
public extension I_blockchain_user_event_did {
	var `update`: L_blockchain_user_event_did_update { .init("\(__).update") }
}
public final class L_blockchain_user_event_did_update: L, I_blockchain_user_event_did_update {
	public override class var localized: String { NSLocalizedString("blockchain.user.event.did.update", comment: "") }
}
public protocol I_blockchain_user_event_did_update: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_user_is: L, I_blockchain_user_is {
	public override class var localized: String { NSLocalizedString("blockchain.user.is", comment: "") }
}
public protocol I_blockchain_user_is: I {}
public extension I_blockchain_user_is {
	var `cowboy`: L_blockchain_user_is_cowboy { .init("\(__).cowboy") }
	var `superapp`: L_blockchain_user_is_superapp { .init("\(__).superapp") }
	var `tier`: L_blockchain_user_is_tier { .init("\(__).tier") }
}
public final class L_blockchain_user_is_cowboy: L, I_blockchain_user_is_cowboy {
	public override class var localized: String { NSLocalizedString("blockchain.user.is.cowboy", comment: "") }
}
public protocol I_blockchain_user_is_cowboy: I {}
public extension I_blockchain_user_is_cowboy {
	var `fan`: L_blockchain_user_is_cowboy_fan { .init("\(__).fan") }
}
public final class L_blockchain_user_is_cowboy_fan: L, I_blockchain_user_is_cowboy_fan {
	public override class var localized: String { NSLocalizedString("blockchain.user.is.cowboy.fan", comment: "") }
}
public protocol I_blockchain_user_is_cowboy_fan: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_user_is_superapp: L, I_blockchain_user_is_superapp {
	public override class var localized: String { NSLocalizedString("blockchain.user.is.superapp", comment: "") }
}
public protocol I_blockchain_user_is_superapp: I {}
public extension I_blockchain_user_is_superapp {
	var `user`: L_blockchain_user_is_superapp_user { .init("\(__).user") }
}
public final class L_blockchain_user_is_superapp_user: L, I_blockchain_user_is_superapp_user {
	public override class var localized: String { NSLocalizedString("blockchain.user.is.superapp.user", comment: "") }
}
public protocol I_blockchain_user_is_superapp_user: I_blockchain_session_state_value {}
public final class L_blockchain_user_is_tier: L, I_blockchain_user_is_tier {
	public override class var localized: String { NSLocalizedString("blockchain.user.is.tier", comment: "") }
}
public protocol I_blockchain_user_is_tier: I {}
public extension I_blockchain_user_is_tier {
	var `gold`: L_blockchain_user_is_tier_gold { .init("\(__).gold") }
	var `none`: L_blockchain_user_is_tier_none { .init("\(__).none") }
	var `silver`: L_blockchain_user_is_tier_silver { .init("\(__).silver") }
}
public final class L_blockchain_user_is_tier_gold: L, I_blockchain_user_is_tier_gold {
	public override class var localized: String { NSLocalizedString("blockchain.user.is.tier.gold", comment: "") }
}
public protocol I_blockchain_user_is_tier_gold: I_blockchain_db_type_boolean {}
public final class L_blockchain_user_is_tier_none: L, I_blockchain_user_is_tier_none {
	public override class var localized: String { NSLocalizedString("blockchain.user.is.tier.none", comment: "") }
}
public protocol I_blockchain_user_is_tier_none: I_blockchain_db_type_boolean {}
public final class L_blockchain_user_is_tier_silver: L, I_blockchain_user_is_tier_silver {
	public override class var localized: String { NSLocalizedString("blockchain.user.is.tier.silver", comment: "") }
}
public protocol I_blockchain_user_is_tier_silver: I_blockchain_db_type_boolean {}
public final class L_blockchain_user_name: L, I_blockchain_user_name {
	public override class var localized: String { NSLocalizedString("blockchain.user.name", comment: "") }
}
public protocol I_blockchain_user_name: I {}
public extension I_blockchain_user_name {
	var `first`: L_blockchain_user_name_first { .init("\(__).first") }
	var `last`: L_blockchain_user_name_last { .init("\(__).last") }
}
public final class L_blockchain_user_name_first: L, I_blockchain_user_name_first {
	public override class var localized: String { NSLocalizedString("blockchain.user.name.first", comment: "") }
}
public protocol I_blockchain_user_name_first: I_blockchain_db_type_string {}
public final class L_blockchain_user_name_last: L, I_blockchain_user_name_last {
	public override class var localized: String { NSLocalizedString("blockchain.user.name.last", comment: "") }
}
public protocol I_blockchain_user_name_last: I_blockchain_db_type_string {}
public final class L_blockchain_user_referral: L, I_blockchain_user_referral {
	public override class var localized: String { NSLocalizedString("blockchain.user.referral", comment: "") }
}
public protocol I_blockchain_user_referral: I {}
public extension I_blockchain_user_referral {
	var `campaign`: L_blockchain_user_referral_campaign { .init("\(__).campaign") }
}
public final class L_blockchain_user_referral_campaign: L, I_blockchain_user_referral_campaign {
	public override class var localized: String { NSLocalizedString("blockchain.user.referral.campaign", comment: "") }
}
public protocol I_blockchain_user_referral_campaign: I_blockchain_session_state_value {}
public final class L_blockchain_user_skipped: L, I_blockchain_user_skipped {
	public override class var localized: String { NSLocalizedString("blockchain.user.skipped", comment: "") }
}
public protocol I_blockchain_user_skipped: I {}
public extension I_blockchain_user_skipped {
	var `seed_phrase`: L_blockchain_user_skipped_seed__phrase { .init("\(__).seed_phrase") }
}
public final class L_blockchain_user_skipped_seed__phrase: L, I_blockchain_user_skipped_seed__phrase {
	public override class var localized: String { NSLocalizedString("blockchain.user.skipped.seed_phrase", comment: "") }
}
public protocol I_blockchain_user_skipped_seed__phrase: I {}
public extension I_blockchain_user_skipped_seed__phrase {
	var `backup`: L_blockchain_user_skipped_seed__phrase_backup { .init("\(__).backup") }
}
public final class L_blockchain_user_skipped_seed__phrase_backup: L, I_blockchain_user_skipped_seed__phrase_backup {
	public override class var localized: String { NSLocalizedString("blockchain.user.skipped.seed_phrase.backup", comment: "") }
}
public protocol I_blockchain_user_skipped_seed__phrase_backup: I_blockchain_db_type_boolean, I_blockchain_session_state_preference_value {}
public final class L_blockchain_user_token: L, I_blockchain_user_token {
	public override class var localized: String { NSLocalizedString("blockchain.user.token", comment: "") }
}
public protocol I_blockchain_user_token: I {}
public extension I_blockchain_user_token {
	var `firebase`: L_blockchain_user_token_firebase { .init("\(__).firebase") }
	var `nabu`: L_blockchain_user_token_nabu { .init("\(__).nabu") }
}
public final class L_blockchain_user_token_firebase: L, I_blockchain_user_token_firebase {
	public override class var localized: String { NSLocalizedString("blockchain.user.token.firebase", comment: "") }
}
public protocol I_blockchain_user_token_firebase: I {}
public extension I_blockchain_user_token_firebase {
	var `installation`: L_blockchain_user_token_firebase_installation { .init("\(__).installation") }
}
public final class L_blockchain_user_token_firebase_installation: L, I_blockchain_user_token_firebase_installation {
	public override class var localized: String { NSLocalizedString("blockchain.user.token.firebase.installation", comment: "") }
}
public protocol I_blockchain_user_token_firebase_installation: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_user_token_nabu: L, I_blockchain_user_token_nabu {
	public override class var localized: String { NSLocalizedString("blockchain.user.token.nabu", comment: "") }
}
public protocol I_blockchain_user_token_nabu: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_user_trading: L, I_blockchain_user_trading {
	public override class var localized: String { NSLocalizedString("blockchain.user.trading", comment: "") }
}
public protocol I_blockchain_user_trading: I_blockchain_db_collection {}
public extension I_blockchain_user_trading {
	var `account`: L_blockchain_user_trading_account { .init("\(__).account") }
}
public final class L_blockchain_user_trading_account: L, I_blockchain_user_trading_account {
	public override class var localized: String { NSLocalizedString("blockchain.user.trading.account", comment: "") }
}
public protocol I_blockchain_user_trading_account: I {}
public extension I_blockchain_user_trading_account {
	var `balance`: L_blockchain_user_trading_account_balance { .init("\(__).balance") }
}
public final class L_blockchain_user_trading_account_balance: L, I_blockchain_user_trading_account_balance {
	public override class var localized: String { NSLocalizedString("blockchain.user.trading.account.balance", comment: "") }
}
public protocol I_blockchain_user_trading_account_balance: I {}
public extension I_blockchain_user_trading_account_balance {
	var `available`: L_blockchain_user_trading_account_balance_available { .init("\(__).available") }
	var `display`: L_blockchain_user_trading_account_balance_display { .init("\(__).display") }
	var `pending`: L_blockchain_user_trading_account_balance_pending { .init("\(__).pending") }
	var `withdrawable`: L_blockchain_user_trading_account_balance_withdrawable { .init("\(__).withdrawable") }
}
public final class L_blockchain_user_trading_account_balance_available: L, I_blockchain_user_trading_account_balance_available {
	public override class var localized: String { NSLocalizedString("blockchain.user.trading.account.balance.available", comment: "") }
}
public protocol I_blockchain_user_trading_account_balance_available: I_blockchain_type_money {}
public final class L_blockchain_user_trading_account_balance_display: L, I_blockchain_user_trading_account_balance_display {
	public override class var localized: String { NSLocalizedString("blockchain.user.trading.account.balance.display", comment: "") }
}
public protocol I_blockchain_user_trading_account_balance_display: I_blockchain_type_money {}
public final class L_blockchain_user_trading_account_balance_pending: L, I_blockchain_user_trading_account_balance_pending {
	public override class var localized: String { NSLocalizedString("blockchain.user.trading.account.balance.pending", comment: "") }
}
public protocol I_blockchain_user_trading_account_balance_pending: I_blockchain_type_money {}
public final class L_blockchain_user_trading_account_balance_withdrawable: L, I_blockchain_user_trading_account_balance_withdrawable {
	public override class var localized: String { NSLocalizedString("blockchain.user.trading.account.balance.withdrawable", comment: "") }
}
public protocol I_blockchain_user_trading_account_balance_withdrawable: I_blockchain_type_money {}
public final class L_blockchain_user_wallet: L, I_blockchain_user_wallet {
	public override class var localized: String { NSLocalizedString("blockchain.user.wallet", comment: "") }
}
public protocol I_blockchain_user_wallet: I_blockchain_db_collection {}
public extension I_blockchain_user_wallet {
	var `created`: L_blockchain_user_wallet_created { .init("\(__).created") }
	var `is`: L_blockchain_user_wallet_is { .init("\(__).is") }
	var `was`: L_blockchain_user_wallet_was { .init("\(__).was") }
}
public final class L_blockchain_user_wallet_created: L, I_blockchain_user_wallet_created {
	public override class var localized: String { NSLocalizedString("blockchain.user.wallet.created", comment: "") }
}
public protocol I_blockchain_user_wallet_created: I_blockchain_db_type_boolean {}
public final class L_blockchain_user_wallet_is: L, I_blockchain_user_wallet_is {
	public override class var localized: String { NSLocalizedString("blockchain.user.wallet.is", comment: "") }
}
public protocol I_blockchain_user_wallet_is: I {}
public extension I_blockchain_user_wallet_is {
	var `funded`: L_blockchain_user_wallet_is_funded { .init("\(__).funded") }
}
public final class L_blockchain_user_wallet_is_funded: L, I_blockchain_user_wallet_is_funded {
	public override class var localized: String { NSLocalizedString("blockchain.user.wallet.is.funded", comment: "") }
}
public protocol I_blockchain_user_wallet_is_funded: I {}
public final class L_blockchain_user_wallet_was: L, I_blockchain_user_wallet_was {
	public override class var localized: String { NSLocalizedString("blockchain.user.wallet.was", comment: "") }
}
public protocol I_blockchain_user_wallet_was: I {}
public extension I_blockchain_user_wallet_was {
	var `created`: L_blockchain_user_wallet_was_created { .init("\(__).created") }
}
public final class L_blockchain_user_wallet_was_created: L, I_blockchain_user_wallet_was_created {
	public override class var localized: String { NSLocalizedString("blockchain.user.wallet.was.created", comment: "") }
}
public protocol I_blockchain_user_wallet_was_created: I_blockchain_db_type_boolean {}
public final class L_blockchain_ux: L, I_blockchain_ux {
	public override class var localized: String { NSLocalizedString("blockchain.ux", comment: "") }
}
public protocol I_blockchain_ux: I {}
public extension I_blockchain_ux {
	var `activity`: L_blockchain_ux_activity { .init("\(__).activity") }
	var `app`: L_blockchain_ux_app { .init("\(__).app") }
	var `asset`: L_blockchain_ux_asset { .init("\(__).asset") }
	var `buy_and_sell`: L_blockchain_ux_buy__and__sell { .init("\(__).buy_and_sell") }
	var `customer`: L_blockchain_ux_customer { .init("\(__).customer") }
	var `dashboard`: L_blockchain_ux_dashboard { .init("\(__).dashboard") }
	var `earn`: L_blockchain_ux_earn { .init("\(__).earn") }
	var `error`: L_blockchain_ux_error { .init("\(__).error") }
	var `frequent`: L_blockchain_ux_frequent { .init("\(__).frequent") }
	var `home`: L_blockchain_ux_home { .init("\(__).home") }
	var `kyc`: L_blockchain_ux_kyc { .init("\(__).kyc") }
	var `maintenance`: L_blockchain_ux_maintenance { .init("\(__).maintenance") }
	var `multiapp`: L_blockchain_ux_multiapp { .init("\(__).multiapp") }
	var `nft`: L_blockchain_ux_nft { .init("\(__).nft") }
	var `onboarding`: L_blockchain_ux_onboarding { .init("\(__).onboarding") }
	var `payment`: L_blockchain_ux_payment { .init("\(__).payment") }
	var `pin`: L_blockchain_ux_pin { .init("\(__).pin") }
	var `prices`: L_blockchain_ux_prices { .init("\(__).prices") }
	var `referral`: L_blockchain_ux_referral { .init("\(__).referral") }
	var `scan`: L_blockchain_ux_scan { .init("\(__).scan") }
	var `switcher`: L_blockchain_ux_switcher { .init("\(__).switcher") }
	var `transaction`: L_blockchain_ux_transaction { .init("\(__).transaction") }
	var `type`: L_blockchain_ux_type { .init("\(__).type") }
	var `user`: L_blockchain_ux_user { .init("\(__).user") }
	var `web`: L_blockchain_ux_web { .init("\(__).web") }
	var `withdrawal`: L_blockchain_ux_withdrawal { .init("\(__).withdrawal") }
}
public final class L_blockchain_ux_activity: L, I_blockchain_ux_activity {
	public override class var localized: String { NSLocalizedString("blockchain.ux.activity", comment: "") }
}
public protocol I_blockchain_ux_activity: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_activity {
	var `detail`: L_blockchain_ux_activity_detail { .init("\(__).detail") }
	var `row`: L_blockchain_ux_activity_row { .init("\(__).row") }
}
public final class L_blockchain_ux_activity_detail: L, I_blockchain_ux_activity_detail {
	public override class var localized: String { NSLocalizedString("blockchain.ux.activity.detail", comment: "") }
}
public protocol I_blockchain_ux_activity_detail: I_blockchain_db_collection, I_blockchain_ux_type_story {}
public extension I_blockchain_ux_activity_detail {
	var `floating`: L_blockchain_ux_activity_detail_floating { .init("\(__).floating") }
	var `model`: L_blockchain_ux_activity_detail_model { .init("\(__).model") }
}
public final class L_blockchain_ux_activity_detail_floating: L, I_blockchain_ux_activity_detail_floating {
	public override class var localized: String { NSLocalizedString("blockchain.ux.activity.detail.floating", comment: "") }
}
public protocol I_blockchain_ux_activity_detail_floating: I {}
public extension I_blockchain_ux_activity_detail_floating {
	var `button`: L_blockchain_ux_activity_detail_floating_button { .init("\(__).button") }
}
public final class L_blockchain_ux_activity_detail_floating_button: L, I_blockchain_ux_activity_detail_floating_button {
	public override class var localized: String { NSLocalizedString("blockchain.ux.activity.detail.floating.button", comment: "") }
}
public protocol I_blockchain_ux_activity_detail_floating_button: I_blockchain_db_collection {}
public extension I_blockchain_ux_activity_detail_floating_button {
	var `tap`: L_blockchain_ux_activity_detail_floating_button_tap { .init("\(__).tap") }
}
public final class L_blockchain_ux_activity_detail_floating_button_tap: L, I_blockchain_ux_activity_detail_floating_button_tap {
	public override class var localized: String { NSLocalizedString("blockchain.ux.activity.detail.floating.button.tap", comment: "") }
}
public protocol I_blockchain_ux_activity_detail_floating_button_tap: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_activity_detail_model: L, I_blockchain_ux_activity_detail_model {
	public override class var localized: String { NSLocalizedString("blockchain.ux.activity.detail.model", comment: "") }
}
public protocol I_blockchain_ux_activity_detail_model: I {}
public final class L_blockchain_ux_activity_row: L, I_blockchain_ux_activity_row {
	public override class var localized: String { NSLocalizedString("blockchain.ux.activity.row", comment: "") }
}
public protocol I_blockchain_ux_activity_row: I {}
public extension I_blockchain_ux_activity_row {
	var `button`: L_blockchain_ux_activity_row_button { .init("\(__).button") }
}
public final class L_blockchain_ux_activity_row_button: L, I_blockchain_ux_activity_row_button {
	public override class var localized: String { NSLocalizedString("blockchain.ux.activity.row.button", comment: "") }
}
public protocol I_blockchain_ux_activity_row_button: I_blockchain_db_collection {}
public extension I_blockchain_ux_activity_row_button {
	var `tap`: L_blockchain_ux_activity_row_button_tap { .init("\(__).tap") }
}
public final class L_blockchain_ux_activity_row_button_tap: L, I_blockchain_ux_activity_row_button_tap {
	public override class var localized: String { NSLocalizedString("blockchain.ux.activity.row.button.tap", comment: "") }
}
public protocol I_blockchain_ux_activity_row_button_tap: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_app: L, I_blockchain_ux_app {
	public override class var localized: String { NSLocalizedString("blockchain.ux.app", comment: "") }
}
public protocol I_blockchain_ux_app: I {}
public extension I_blockchain_ux_app {
	var `mode`: L_blockchain_ux_app_mode { .init("\(__).mode") }
}
public final class L_blockchain_ux_app_mode: L, I_blockchain_ux_app_mode {
	public override class var localized: String { NSLocalizedString("blockchain.ux.app.mode", comment: "") }
}
public protocol I_blockchain_ux_app_mode: I {}
public extension I_blockchain_ux_app_mode {
	var `seen`: L_blockchain_ux_app_mode_seen { .init("\(__).seen") }
	var `switcher`: L_blockchain_ux_app_mode_switcher { .init("\(__).switcher") }
}
public final class L_blockchain_ux_app_mode_seen: L, I_blockchain_ux_app_mode_seen {
	public override class var localized: String { NSLocalizedString("blockchain.ux.app.mode.seen", comment: "") }
}
public protocol I_blockchain_ux_app_mode_seen: I_blockchain_db_type_boolean, I_blockchain_session_state_preference_value {}
public final class L_blockchain_ux_app_mode_switcher: L, I_blockchain_ux_app_mode_switcher {
	public override class var localized: String { NSLocalizedString("blockchain.ux.app.mode.switcher", comment: "") }
}
public protocol I_blockchain_ux_app_mode_switcher: I {}
public extension I_blockchain_ux_app_mode_switcher {
	var `tapped`: L_blockchain_ux_app_mode_switcher_tapped { .init("\(__).tapped") }
}
public final class L_blockchain_ux_app_mode_switcher_tapped: L, I_blockchain_ux_app_mode_switcher_tapped {
	public override class var localized: String { NSLocalizedString("blockchain.ux.app.mode.switcher.tapped", comment: "") }
}
public protocol I_blockchain_ux_app_mode_switcher_tapped: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset: L, I_blockchain_ux_asset {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset", comment: "") }
}
public protocol I_blockchain_ux_asset: I_blockchain_db_collection, I_blockchain_ux_type_story {}
public extension I_blockchain_ux_asset {
	var `account`: L_blockchain_ux_asset_account { .init("\(__).account") }
	var `balanceInfo`: L_blockchain_ux_asset_balanceInfo { .init("\(__).balanceInfo") }
	var `bio`: L_blockchain_ux_asset_bio { .init("\(__).bio") }
	var `buy`: L_blockchain_ux_asset_buy { .init("\(__).buy") }
	var `chart`: L_blockchain_ux_asset_chart { .init("\(__).chart") }
	var `error`: L_blockchain_ux_asset_error { .init("\(__).error") }
	var `receive`: L_blockchain_ux_asset_receive { .init("\(__).receive") }
	var `recurring`: L_blockchain_ux_asset_recurring { .init("\(__).recurring") }
	var `refresh`: L_blockchain_ux_asset_refresh { .init("\(__).refresh") }
	var `select`: L_blockchain_ux_asset_select { .init("\(__).select") }
	var `sell`: L_blockchain_ux_asset_sell { .init("\(__).sell") }
	var `send`: L_blockchain_ux_asset_send { .init("\(__).send") }
	var `watchlist`: L_blockchain_ux_asset_watchlist { .init("\(__).watchlist") }
}
public final class L_blockchain_ux_asset_account: L, I_blockchain_ux_asset_account {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account", comment: "") }
}
public protocol I_blockchain_ux_asset_account: I_blockchain_db_collection, I_blockchain_ux_type_story, I_blockchain_ux_type_analytics_privacy_policy_obfuscate {}
public extension I_blockchain_ux_asset_account {
	var `activity`: L_blockchain_ux_asset_account_activity { .init("\(__).activity") }
	var `buy`: L_blockchain_ux_asset_account_buy { .init("\(__).buy") }
	var `coming`: L_blockchain_ux_asset_account_coming { .init("\(__).coming") }
	var `error`: L_blockchain_ux_asset_account_error { .init("\(__).error") }
	var `exchange`: L_blockchain_ux_asset_account_exchange { .init("\(__).exchange") }
	var `explainer`: L_blockchain_ux_asset_account_explainer { .init("\(__).explainer") }
	var `is`: L_blockchain_ux_asset_account_is { .init("\(__).is") }
	var `receive`: L_blockchain_ux_asset_account_receive { .init("\(__).receive") }
	var `require`: L_blockchain_ux_asset_account_require { .init("\(__).require") }
	var `rewards`: L_blockchain_ux_asset_account_rewards { .init("\(__).rewards") }
	var `sell`: L_blockchain_ux_asset_account_sell { .init("\(__).sell") }
	var `send`: L_blockchain_ux_asset_account_send { .init("\(__).send") }
	var `sheet`: L_blockchain_ux_asset_account_sheet { .init("\(__).sheet") }
	var `staking`: L_blockchain_ux_asset_account_staking { .init("\(__).staking") }
	var `swap`: L_blockchain_ux_asset_account_swap { .init("\(__).swap") }
	var `type`: L_blockchain_ux_asset_account_type { .init("\(__).type") }
}
public final class L_blockchain_ux_asset_account_activity: L, I_blockchain_ux_asset_account_activity {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.activity", comment: "") }
}
public protocol I_blockchain_ux_asset_account_activity: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_buy: L, I_blockchain_ux_asset_account_buy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.buy", comment: "") }
}
public protocol I_blockchain_ux_asset_account_buy: I_blockchain_ux_type_action {}
public extension I_blockchain_ux_asset_account_buy {
	var `recurring`: L_blockchain_ux_asset_account_buy_recurring { .init("\(__).recurring") }
}
public final class L_blockchain_ux_asset_account_buy_recurring: L, I_blockchain_ux_asset_account_buy_recurring {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.buy.recurring", comment: "") }
}
public protocol I_blockchain_ux_asset_account_buy_recurring: I_blockchain_ux_type_action {}
public extension I_blockchain_ux_asset_account_buy_recurring {
	var `summary`: L_blockchain_ux_asset_account_buy_recurring_summary { .init("\(__).summary") }
}
public final class L_blockchain_ux_asset_account_buy_recurring_summary: L, I_blockchain_ux_asset_account_buy_recurring_summary {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.buy.recurring.summary", comment: "") }
}
public protocol I_blockchain_ux_asset_account_buy_recurring_summary: I_blockchain_db_type_string, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_asset_account_coming: L, I_blockchain_ux_asset_account_coming {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.coming", comment: "") }
}
public protocol I_blockchain_ux_asset_account_coming: I {}
public extension I_blockchain_ux_asset_account_coming {
	var `soon`: L_blockchain_ux_asset_account_coming_soon { .init("\(__).soon") }
}
public final class L_blockchain_ux_asset_account_coming_soon: L, I_blockchain_ux_asset_account_coming_soon {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.coming.soon", comment: "") }
}
public protocol I_blockchain_ux_asset_account_coming_soon: I {}
public extension I_blockchain_ux_asset_account_coming_soon {
	var `visit`: L_blockchain_ux_asset_account_coming_soon_visit { .init("\(__).visit") }
}
public final class L_blockchain_ux_asset_account_coming_soon_visit: L, I_blockchain_ux_asset_account_coming_soon_visit {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.coming.soon.visit", comment: "") }
}
public protocol I_blockchain_ux_asset_account_coming_soon_visit: I {}
public extension I_blockchain_ux_asset_account_coming_soon_visit {
	var `learn`: L_blockchain_ux_asset_account_coming_soon_visit_learn { .init("\(__).learn") }
	var `web`: L_blockchain_ux_asset_account_coming_soon_visit_web { .init("\(__).web") }
}
public final class L_blockchain_ux_asset_account_coming_soon_visit_learn: L, I_blockchain_ux_asset_account_coming_soon_visit_learn {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.coming.soon.visit.learn", comment: "") }
}
public protocol I_blockchain_ux_asset_account_coming_soon_visit_learn: I {}
public extension I_blockchain_ux_asset_account_coming_soon_visit_learn {
	var `more`: L_blockchain_ux_asset_account_coming_soon_visit_learn_more { .init("\(__).more") }
}
public final class L_blockchain_ux_asset_account_coming_soon_visit_learn_more: L, I_blockchain_ux_asset_account_coming_soon_visit_learn_more {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.coming.soon.visit.learn.more", comment: "") }
}
public protocol I_blockchain_ux_asset_account_coming_soon_visit_learn_more: I_blockchain_ux_type_action {}
public extension I_blockchain_ux_asset_account_coming_soon_visit_learn_more {
	var `url`: L_blockchain_ux_asset_account_coming_soon_visit_learn_more_url { .init("\(__).url") }
}
public final class L_blockchain_ux_asset_account_coming_soon_visit_learn_more_url: L, I_blockchain_ux_asset_account_coming_soon_visit_learn_more_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.coming.soon.visit.learn.more.url", comment: "") }
}
public protocol I_blockchain_ux_asset_account_coming_soon_visit_learn_more_url: I_blockchain_db_type_url, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_asset_account_coming_soon_visit_web: L, I_blockchain_ux_asset_account_coming_soon_visit_web {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.coming.soon.visit.web", comment: "") }
}
public protocol I_blockchain_ux_asset_account_coming_soon_visit_web: I {}
public extension I_blockchain_ux_asset_account_coming_soon_visit_web {
	var `app`: L_blockchain_ux_asset_account_coming_soon_visit_web_app { .init("\(__).app") }
}
public final class L_blockchain_ux_asset_account_coming_soon_visit_web_app: L, I_blockchain_ux_asset_account_coming_soon_visit_web_app {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.coming.soon.visit.web.app", comment: "") }
}
public protocol I_blockchain_ux_asset_account_coming_soon_visit_web_app: I_blockchain_ux_type_action {}
public extension I_blockchain_ux_asset_account_coming_soon_visit_web_app {
	var `url`: L_blockchain_ux_asset_account_coming_soon_visit_web_app_url { .init("\(__).url") }
}
public final class L_blockchain_ux_asset_account_coming_soon_visit_web_app_url: L, I_blockchain_ux_asset_account_coming_soon_visit_web_app_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.coming.soon.visit.web.app.url", comment: "") }
}
public protocol I_blockchain_ux_asset_account_coming_soon_visit_web_app_url: I_blockchain_db_type_url, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_asset_account_error: L, I_blockchain_ux_asset_account_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.error", comment: "") }
}
public protocol I_blockchain_ux_asset_account_error: I_blockchain_ux_type_analytics_error {}
public final class L_blockchain_ux_asset_account_exchange: L, I_blockchain_ux_asset_account_exchange {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.exchange", comment: "") }
}
public protocol I_blockchain_ux_asset_account_exchange: I {}
public extension I_blockchain_ux_asset_account_exchange {
	var `connect`: L_blockchain_ux_asset_account_exchange_connect { .init("\(__).connect") }
	var `deposit`: L_blockchain_ux_asset_account_exchange_deposit { .init("\(__).deposit") }
	var `withdraw`: L_blockchain_ux_asset_account_exchange_withdraw { .init("\(__).withdraw") }
}
public final class L_blockchain_ux_asset_account_exchange_connect: L, I_blockchain_ux_asset_account_exchange_connect {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.exchange.connect", comment: "") }
}
public protocol I_blockchain_ux_asset_account_exchange_connect: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_exchange_deposit: L, I_blockchain_ux_asset_account_exchange_deposit {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.exchange.deposit", comment: "") }
}
public protocol I_blockchain_ux_asset_account_exchange_deposit: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_exchange_withdraw: L, I_blockchain_ux_asset_account_exchange_withdraw {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.exchange.withdraw", comment: "") }
}
public protocol I_blockchain_ux_asset_account_exchange_withdraw: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_explainer: L, I_blockchain_ux_asset_account_explainer {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.explainer", comment: "") }
}
public protocol I_blockchain_ux_asset_account_explainer: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_asset_account_explainer {
	var `accept`: L_blockchain_ux_asset_account_explainer_accept { .init("\(__).accept") }
	var `reset`: L_blockchain_ux_asset_account_explainer_reset { .init("\(__).reset") }
}
public final class L_blockchain_ux_asset_account_explainer_accept: L, I_blockchain_ux_asset_account_explainer_accept {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.explainer.accept", comment: "") }
}
public protocol I_blockchain_ux_asset_account_explainer_accept: I {}
public final class L_blockchain_ux_asset_account_explainer_reset: L, I_blockchain_ux_asset_account_explainer_reset {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.explainer.reset", comment: "") }
}
public protocol I_blockchain_ux_asset_account_explainer_reset: I {}
public final class L_blockchain_ux_asset_account_is: L, I_blockchain_ux_asset_account_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.is", comment: "") }
}
public protocol I_blockchain_ux_asset_account_is: I {}
public extension I_blockchain_ux_asset_account_is {
	var `private_key`: L_blockchain_ux_asset_account_is_private__key { .init("\(__).private_key") }
	var `rewards`: L_blockchain_ux_asset_account_is_rewards { .init("\(__).rewards") }
	var `trading`: L_blockchain_ux_asset_account_is_trading { .init("\(__).trading") }
}
public final class L_blockchain_ux_asset_account_is_private__key: L, I_blockchain_ux_asset_account_is_private__key {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.is.private_key", comment: "") }
}
public protocol I_blockchain_ux_asset_account_is_private__key: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_asset_account_is_rewards: L, I_blockchain_ux_asset_account_is_rewards {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.is.rewards", comment: "") }
}
public protocol I_blockchain_ux_asset_account_is_rewards: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_asset_account_is_trading: L, I_blockchain_ux_asset_account_is_trading {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.is.trading", comment: "") }
}
public protocol I_blockchain_ux_asset_account_is_trading: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_asset_account_receive: L, I_blockchain_ux_asset_account_receive {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.receive", comment: "") }
}
public protocol I_blockchain_ux_asset_account_receive: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_require: L, I_blockchain_ux_asset_account_require {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.require", comment: "") }
}
public protocol I_blockchain_ux_asset_account_require: I {}
public extension I_blockchain_ux_asset_account_require {
	var `KYC`: L_blockchain_ux_asset_account_require_KYC { .init("\(__).KYC") }
}
public final class L_blockchain_ux_asset_account_require_KYC: L, I_blockchain_ux_asset_account_require_KYC {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.require.KYC", comment: "") }
}
public protocol I_blockchain_ux_asset_account_require_KYC: I_blockchain_ui_type_action {}
public final class L_blockchain_ux_asset_account_rewards: L, I_blockchain_ux_asset_account_rewards {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.rewards", comment: "") }
}
public protocol I_blockchain_ux_asset_account_rewards: I {}
public extension I_blockchain_ux_asset_account_rewards {
	var `deposit`: L_blockchain_ux_asset_account_rewards_deposit { .init("\(__).deposit") }
	var `summary`: L_blockchain_ux_asset_account_rewards_summary { .init("\(__).summary") }
	var `withdraw`: L_blockchain_ux_asset_account_rewards_withdraw { .init("\(__).withdraw") }
}
public final class L_blockchain_ux_asset_account_rewards_deposit: L, I_blockchain_ux_asset_account_rewards_deposit {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.rewards.deposit", comment: "") }
}
public protocol I_blockchain_ux_asset_account_rewards_deposit: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_rewards_summary: L, I_blockchain_ux_asset_account_rewards_summary {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.rewards.summary", comment: "") }
}
public protocol I_blockchain_ux_asset_account_rewards_summary: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_rewards_withdraw: L, I_blockchain_ux_asset_account_rewards_withdraw {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.rewards.withdraw", comment: "") }
}
public protocol I_blockchain_ux_asset_account_rewards_withdraw: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_sell: L, I_blockchain_ux_asset_account_sell {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.sell", comment: "") }
}
public protocol I_blockchain_ux_asset_account_sell: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_send: L, I_blockchain_ux_asset_account_send {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.send", comment: "") }
}
public protocol I_blockchain_ux_asset_account_send: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_sheet: L, I_blockchain_ux_asset_account_sheet {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.sheet", comment: "") }
}
public protocol I_blockchain_ux_asset_account_sheet: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_staking: L, I_blockchain_ux_asset_account_staking {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.staking", comment: "") }
}
public protocol I_blockchain_ux_asset_account_staking: I {}
public extension I_blockchain_ux_asset_account_staking {
	var `deposit`: L_blockchain_ux_asset_account_staking_deposit { .init("\(__).deposit") }
	var `summary`: L_blockchain_ux_asset_account_staking_summary { .init("\(__).summary") }
}
public final class L_blockchain_ux_asset_account_staking_deposit: L, I_blockchain_ux_asset_account_staking_deposit {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.staking.deposit", comment: "") }
}
public protocol I_blockchain_ux_asset_account_staking_deposit: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_staking_summary: L, I_blockchain_ux_asset_account_staking_summary {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.staking.summary", comment: "") }
}
public protocol I_blockchain_ux_asset_account_staking_summary: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_swap: L, I_blockchain_ux_asset_account_swap {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.swap", comment: "") }
}
public protocol I_blockchain_ux_asset_account_swap: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_account_type: L, I_blockchain_ux_asset_account_type {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.account.type", comment: "") }
}
public protocol I_blockchain_ux_asset_account_type: I_blockchain_db_type_string {}
public final class L_blockchain_ux_asset_balanceInfo: L, I_blockchain_ux_asset_balanceInfo {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.balanceInfo", comment: "") }
}
public protocol I_blockchain_ux_asset_balanceInfo: I_blockchain_db_collection, I_blockchain_ux_type_story {}
public final class L_blockchain_ux_asset_bio: L, I_blockchain_ux_asset_bio {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.bio", comment: "") }
}
public protocol I_blockchain_ux_asset_bio: I {}
public extension I_blockchain_ux_asset_bio {
	var `visit`: L_blockchain_ux_asset_bio_visit { .init("\(__).visit") }
}
public final class L_blockchain_ux_asset_bio_visit: L, I_blockchain_ux_asset_bio_visit {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.bio.visit", comment: "") }
}
public protocol I_blockchain_ux_asset_bio_visit: I {}
public extension I_blockchain_ux_asset_bio_visit {
	var `website`: L_blockchain_ux_asset_bio_visit_website { .init("\(__).website") }
}
public final class L_blockchain_ux_asset_bio_visit_website: L, I_blockchain_ux_asset_bio_visit_website {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.bio.visit.website", comment: "") }
}
public protocol I_blockchain_ux_asset_bio_visit_website: I {}
public extension I_blockchain_ux_asset_bio_visit_website {
	var `url`: L_blockchain_ux_asset_bio_visit_website_url { .init("\(__).url") }
}
public final class L_blockchain_ux_asset_bio_visit_website_url: L, I_blockchain_ux_asset_bio_visit_website_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.bio.visit.website.url", comment: "") }
}
public protocol I_blockchain_ux_asset_bio_visit_website_url: I_blockchain_db_type_url {}
public final class L_blockchain_ux_asset_buy: L, I_blockchain_ux_asset_buy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.buy", comment: "") }
}
public protocol I_blockchain_ux_asset_buy: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_chart: L, I_blockchain_ux_asset_chart {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.chart", comment: "") }
}
public protocol I_blockchain_ux_asset_chart: I {}
public extension I_blockchain_ux_asset_chart {
	var `asset`: L_blockchain_ux_asset_chart_asset { .init("\(__).asset") }
	var `deselected`: L_blockchain_ux_asset_chart_deselected { .init("\(__).deselected") }
	var `interval`: L_blockchain_ux_asset_chart_interval { .init("\(__).interval") }
	var `selected`: L_blockchain_ux_asset_chart_selected { .init("\(__).selected") }
}
public final class L_blockchain_ux_asset_chart_asset: L, I_blockchain_ux_asset_chart_asset {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.chart.asset", comment: "") }
}
public protocol I_blockchain_ux_asset_chart_asset: I {}
public extension I_blockchain_ux_asset_chart_asset {
	var `color`: L_blockchain_ux_asset_chart_asset_color { .init("\(__).color") }
}
public final class L_blockchain_ux_asset_chart_asset_color: L, I_blockchain_ux_asset_chart_asset_color {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.chart.asset.color", comment: "") }
}
public protocol I_blockchain_ux_asset_chart_asset_color: I {}
public extension I_blockchain_ux_asset_chart_asset_color {
	var `is`: L_blockchain_ux_asset_chart_asset_color_is { .init("\(__).is") }
}
public final class L_blockchain_ux_asset_chart_asset_color_is: L, I_blockchain_ux_asset_chart_asset_color_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.chart.asset.color.is", comment: "") }
}
public protocol I_blockchain_ux_asset_chart_asset_color_is: I {}
public extension I_blockchain_ux_asset_chart_asset_color_is {
	var `enabled`: L_blockchain_ux_asset_chart_asset_color_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_ux_asset_chart_asset_color_is_enabled: L, I_blockchain_ux_asset_chart_asset_color_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.chart.asset.color.is.enabled", comment: "") }
}
public protocol I_blockchain_ux_asset_chart_asset_color_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_asset_chart_deselected: L, I_blockchain_ux_asset_chart_deselected {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.chart.deselected", comment: "") }
}
public protocol I_blockchain_ux_asset_chart_deselected: I_blockchain_ux_type_analytics_action {}
public final class L_blockchain_ux_asset_chart_interval: L, I_blockchain_ux_asset_chart_interval {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.chart.interval", comment: "") }
}
public protocol I_blockchain_ux_asset_chart_interval: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_asset_chart_selected: L, I_blockchain_ux_asset_chart_selected {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.chart.selected", comment: "") }
}
public protocol I_blockchain_ux_asset_chart_selected: I_blockchain_ux_type_analytics_action {}
public final class L_blockchain_ux_asset_error: L, I_blockchain_ux_asset_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.error", comment: "") }
}
public protocol I_blockchain_ux_asset_error: I_blockchain_ux_type_analytics_error {}
public final class L_blockchain_ux_asset_receive: L, I_blockchain_ux_asset_receive {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.receive", comment: "") }
}
public protocol I_blockchain_ux_asset_receive: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_recurring: L, I_blockchain_ux_asset_recurring {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.recurring", comment: "") }
}
public protocol I_blockchain_ux_asset_recurring: I {}
public extension I_blockchain_ux_asset_recurring {
	var `buy`: L_blockchain_ux_asset_recurring_buy { .init("\(__).buy") }
}
public final class L_blockchain_ux_asset_recurring_buy: L, I_blockchain_ux_asset_recurring_buy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.recurring.buy", comment: "") }
}
public protocol I_blockchain_ux_asset_recurring_buy: I {}
public extension I_blockchain_ux_asset_recurring_buy {
	var `summary`: L_blockchain_ux_asset_recurring_buy_summary { .init("\(__).summary") }
	var `visit`: L_blockchain_ux_asset_recurring_buy_visit { .init("\(__).visit") }
}
public final class L_blockchain_ux_asset_recurring_buy_summary: L, I_blockchain_ux_asset_recurring_buy_summary {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.recurring.buy.summary", comment: "") }
}
public protocol I_blockchain_ux_asset_recurring_buy_summary: I_blockchain_db_collection, I_blockchain_ux_type_story {}
public extension I_blockchain_ux_asset_recurring_buy_summary {
	var `cancel`: L_blockchain_ux_asset_recurring_buy_summary_cancel { .init("\(__).cancel") }
}
public final class L_blockchain_ux_asset_recurring_buy_summary_cancel: L, I_blockchain_ux_asset_recurring_buy_summary_cancel {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.recurring.buy.summary.cancel", comment: "") }
}
public protocol I_blockchain_ux_asset_recurring_buy_summary_cancel: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_asset_recurring_buy_summary_cancel {
	var `tapped`: L_blockchain_ux_asset_recurring_buy_summary_cancel_tapped { .init("\(__).tapped") }
}
public final class L_blockchain_ux_asset_recurring_buy_summary_cancel_tapped: L, I_blockchain_ux_asset_recurring_buy_summary_cancel_tapped {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.recurring.buy.summary.cancel.tapped", comment: "") }
}
public protocol I_blockchain_ux_asset_recurring_buy_summary_cancel_tapped: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_recurring_buy_visit: L, I_blockchain_ux_asset_recurring_buy_visit {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.recurring.buy.visit", comment: "") }
}
public protocol I_blockchain_ux_asset_recurring_buy_visit: I {}
public extension I_blockchain_ux_asset_recurring_buy_visit {
	var `website`: L_blockchain_ux_asset_recurring_buy_visit_website { .init("\(__).website") }
}
public final class L_blockchain_ux_asset_recurring_buy_visit_website: L, I_blockchain_ux_asset_recurring_buy_visit_website {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.recurring.buy.visit.website", comment: "") }
}
public protocol I_blockchain_ux_asset_recurring_buy_visit_website: I_blockchain_db_type_url {}
public extension I_blockchain_ux_asset_recurring_buy_visit_website {
	var `url`: L_blockchain_ux_asset_recurring_buy_visit_website_url { .init("\(__).url") }
}
public final class L_blockchain_ux_asset_recurring_buy_visit_website_url: L, I_blockchain_ux_asset_recurring_buy_visit_website_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.recurring.buy.visit.website.url", comment: "") }
}
public protocol I_blockchain_ux_asset_recurring_buy_visit_website_url: I_blockchain_db_type_url, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_asset_refresh: L, I_blockchain_ux_asset_refresh {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.refresh", comment: "") }
}
public protocol I_blockchain_ux_asset_refresh: I_blockchain_ux_type_analytics_action {}
public final class L_blockchain_ux_asset_select: L, I_blockchain_ux_asset_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.select", comment: "") }
}
public protocol I_blockchain_ux_asset_select: I_blockchain_ux_type_action {}
public extension I_blockchain_ux_asset_select {
	var `origin`: L_blockchain_ux_asset_select_origin { .init("\(__).origin") }
}
public final class L_blockchain_ux_asset_select_origin: L, I_blockchain_ux_asset_select_origin {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.select.origin", comment: "") }
}
public protocol I_blockchain_ux_asset_select_origin: I_blockchain_session_state_value {}
public final class L_blockchain_ux_asset_sell: L, I_blockchain_ux_asset_sell {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.sell", comment: "") }
}
public protocol I_blockchain_ux_asset_sell: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_send: L, I_blockchain_ux_asset_send {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.send", comment: "") }
}
public protocol I_blockchain_ux_asset_send: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_asset_watchlist: L, I_blockchain_ux_asset_watchlist {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.watchlist", comment: "") }
}
public protocol I_blockchain_ux_asset_watchlist: I {}
public extension I_blockchain_ux_asset_watchlist {
	var `add`: L_blockchain_ux_asset_watchlist_add { .init("\(__).add") }
	var `is`: L_blockchain_ux_asset_watchlist_is { .init("\(__).is") }
	var `remove`: L_blockchain_ux_asset_watchlist_remove { .init("\(__).remove") }
}
public final class L_blockchain_ux_asset_watchlist_add: L, I_blockchain_ux_asset_watchlist_add {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.watchlist.add", comment: "") }
}
public protocol I_blockchain_ux_asset_watchlist_add: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_asset_watchlist_is: L, I_blockchain_ux_asset_watchlist_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.watchlist.is", comment: "") }
}
public protocol I_blockchain_ux_asset_watchlist_is: I {}
public extension I_blockchain_ux_asset_watchlist_is {
	var `on`: L_blockchain_ux_asset_watchlist_is_on { .init("\(__).on") }
}
public final class L_blockchain_ux_asset_watchlist_is_on: L, I_blockchain_ux_asset_watchlist_is_on {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.watchlist.is.on", comment: "") }
}
public protocol I_blockchain_ux_asset_watchlist_is_on: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_asset_watchlist_remove: L, I_blockchain_ux_asset_watchlist_remove {
	public override class var localized: String { NSLocalizedString("blockchain.ux.asset.watchlist.remove", comment: "") }
}
public protocol I_blockchain_ux_asset_watchlist_remove: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_buy__and__sell: L, I_blockchain_ux_buy__and__sell {
	public override class var localized: String { NSLocalizedString("blockchain.ux.buy_and_sell", comment: "") }
}
public protocol I_blockchain_ux_buy__and__sell: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_buy__and__sell {
	var `buy`: L_blockchain_ux_buy__and__sell_buy { .init("\(__).buy") }
	var `sell`: L_blockchain_ux_buy__and__sell_sell { .init("\(__).sell") }
}
public final class L_blockchain_ux_buy__and__sell_buy: L, I_blockchain_ux_buy__and__sell_buy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.buy_and_sell.buy", comment: "") }
}
public protocol I_blockchain_ux_buy__and__sell_buy: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_buy__and__sell_sell: L, I_blockchain_ux_buy__and__sell_sell {
	public override class var localized: String { NSLocalizedString("blockchain.ux.buy_and_sell.sell", comment: "") }
}
public protocol I_blockchain_ux_buy__and__sell_sell: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_customer: L, I_blockchain_ux_customer {
	public override class var localized: String { NSLocalizedString("blockchain.ux.customer", comment: "") }
}
public protocol I_blockchain_ux_customer: I {}
public extension I_blockchain_ux_customer {
	var `support`: L_blockchain_ux_customer_support { .init("\(__).support") }
}
public final class L_blockchain_ux_customer_support: L, I_blockchain_ux_customer_support {
	public override class var localized: String { NSLocalizedString("blockchain.ux.customer.support", comment: "") }
}
public protocol I_blockchain_ux_customer_support: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_customer_support {
	var `show`: L_blockchain_ux_customer_support_show { .init("\(__).show") }
	var `unread`: L_blockchain_ux_customer_support_unread { .init("\(__).unread") }
}
public final class L_blockchain_ux_customer_support_show: L, I_blockchain_ux_customer_support_show {
	public override class var localized: String { NSLocalizedString("blockchain.ux.customer.support.show", comment: "") }
}
public protocol I_blockchain_ux_customer_support_show: I {}
public extension I_blockchain_ux_customer_support_show {
	var `help`: L_blockchain_ux_customer_support_show_help { .init("\(__).help") }
	var `messenger`: L_blockchain_ux_customer_support_show_messenger { .init("\(__).messenger") }
}
public final class L_blockchain_ux_customer_support_show_help: L, I_blockchain_ux_customer_support_show_help {
	public override class var localized: String { NSLocalizedString("blockchain.ux.customer.support.show.help", comment: "") }
}
public protocol I_blockchain_ux_customer_support_show_help: I {}
public extension I_blockchain_ux_customer_support_show_help {
	var `center`: L_blockchain_ux_customer_support_show_help_center { .init("\(__).center") }
}
public final class L_blockchain_ux_customer_support_show_help_center: L, I_blockchain_ux_customer_support_show_help_center {
	public override class var localized: String { NSLocalizedString("blockchain.ux.customer.support.show.help.center", comment: "") }
}
public protocol I_blockchain_ux_customer_support_show_help_center: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_customer_support_show_messenger: L, I_blockchain_ux_customer_support_show_messenger {
	public override class var localized: String { NSLocalizedString("blockchain.ux.customer.support.show.messenger", comment: "") }
}
public protocol I_blockchain_ux_customer_support_show_messenger: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_customer_support_unread: L, I_blockchain_ux_customer_support_unread {
	public override class var localized: String { NSLocalizedString("blockchain.ux.customer.support.unread", comment: "") }
}
public protocol I_blockchain_ux_customer_support_unread: I {}
public extension I_blockchain_ux_customer_support_unread {
	var `count`: L_blockchain_ux_customer_support_unread_count { .init("\(__).count") }
}
public final class L_blockchain_ux_customer_support_unread_count: L, I_blockchain_ux_customer_support_unread_count {
	public override class var localized: String { NSLocalizedString("blockchain.ux.customer.support.unread.count", comment: "") }
}
public protocol I_blockchain_ux_customer_support_unread_count: I_blockchain_db_type_integer, I_blockchain_session_state_value {}
public final class L_blockchain_ux_dashboard: L, I_blockchain_ux_dashboard {
	public override class var localized: String { NSLocalizedString("blockchain.ux.dashboard", comment: "") }
}
public protocol I_blockchain_ux_dashboard: I {}
public extension I_blockchain_ux_dashboard {
	var `fiat`: L_blockchain_ux_dashboard_fiat { .init("\(__).fiat") }
	var `total`: L_blockchain_ux_dashboard_total { .init("\(__).total") }
}
public final class L_blockchain_ux_dashboard_fiat: L, I_blockchain_ux_dashboard_fiat {
	public override class var localized: String { NSLocalizedString("blockchain.ux.dashboard.fiat", comment: "") }
}
public protocol I_blockchain_ux_dashboard_fiat: I {}
public extension I_blockchain_ux_dashboard_fiat {
	var `account`: L_blockchain_ux_dashboard_fiat_account { .init("\(__).account") }
}
public final class L_blockchain_ux_dashboard_fiat_account: L, I_blockchain_ux_dashboard_fiat_account {
	public override class var localized: String { NSLocalizedString("blockchain.ux.dashboard.fiat.account", comment: "") }
}
public protocol I_blockchain_ux_dashboard_fiat_account: I {}
public extension I_blockchain_ux_dashboard_fiat_account {
	var `action`: L_blockchain_ux_dashboard_fiat_account_action { .init("\(__).action") }
	var `tap`: L_blockchain_ux_dashboard_fiat_account_tap { .init("\(__).tap") }
}
public final class L_blockchain_ux_dashboard_fiat_account_action: L, I_blockchain_ux_dashboard_fiat_account_action {
	public override class var localized: String { NSLocalizedString("blockchain.ux.dashboard.fiat.account.action", comment: "") }
}
public protocol I_blockchain_ux_dashboard_fiat_account_action: I {}
public extension I_blockchain_ux_dashboard_fiat_account_action {
	var `sheet`: L_blockchain_ux_dashboard_fiat_account_action_sheet { .init("\(__).sheet") }
}
public final class L_blockchain_ux_dashboard_fiat_account_action_sheet: L, I_blockchain_ux_dashboard_fiat_account_action_sheet {
	public override class var localized: String { NSLocalizedString("blockchain.ux.dashboard.fiat.account.action.sheet", comment: "") }
}
public protocol I_blockchain_ux_dashboard_fiat_account_action_sheet: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_dashboard_fiat_account_action_sheet {
	var `asset`: L_blockchain_ux_dashboard_fiat_account_action_sheet_asset { .init("\(__).asset") }
}
public final class L_blockchain_ux_dashboard_fiat_account_action_sheet_asset: L, I_blockchain_ux_dashboard_fiat_account_action_sheet_asset {
	public override class var localized: String { NSLocalizedString("blockchain.ux.dashboard.fiat.account.action.sheet.asset", comment: "") }
}
public protocol I_blockchain_ux_dashboard_fiat_account_action_sheet_asset: I_blockchain_db_type_any {}
public final class L_blockchain_ux_dashboard_fiat_account_tap: L, I_blockchain_ux_dashboard_fiat_account_tap {
	public override class var localized: String { NSLocalizedString("blockchain.ux.dashboard.fiat.account.tap", comment: "") }
}
public protocol I_blockchain_ux_dashboard_fiat_account_tap: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_dashboard_total: L, I_blockchain_ux_dashboard_total {
	public override class var localized: String { NSLocalizedString("blockchain.ux.dashboard.total", comment: "") }
}
public protocol I_blockchain_ux_dashboard_total: I {}
public extension I_blockchain_ux_dashboard_total {
	var `balance`: L_blockchain_ux_dashboard_total_balance { .init("\(__).balance") }
	var `defi`: L_blockchain_ux_dashboard_total_defi { .init("\(__).defi") }
	var `trading`: L_blockchain_ux_dashboard_total_trading { .init("\(__).trading") }
}
public final class L_blockchain_ux_dashboard_total_balance: L, I_blockchain_ux_dashboard_total_balance {
	public override class var localized: String { NSLocalizedString("blockchain.ux.dashboard.total.balance", comment: "") }
}
public protocol I_blockchain_ux_dashboard_total_balance: I_blockchain_db_type_any, I_blockchain_session_state_stored_value {}
public final class L_blockchain_ux_dashboard_total_defi: L, I_blockchain_ux_dashboard_total_defi {
	public override class var localized: String { NSLocalizedString("blockchain.ux.dashboard.total.defi", comment: "") }
}
public protocol I_blockchain_ux_dashboard_total_defi: I {}
public extension I_blockchain_ux_dashboard_total_defi {
	var `balance`: L_blockchain_ux_dashboard_total_defi_balance { .init("\(__).balance") }
}
public final class L_blockchain_ux_dashboard_total_defi_balance: L, I_blockchain_ux_dashboard_total_defi_balance {
	public override class var localized: String { NSLocalizedString("blockchain.ux.dashboard.total.defi.balance", comment: "") }
}
public protocol I_blockchain_ux_dashboard_total_defi_balance: I_blockchain_db_type_any, I_blockchain_session_state_stored_value {}
public final class L_blockchain_ux_dashboard_total_trading: L, I_blockchain_ux_dashboard_total_trading {
	public override class var localized: String { NSLocalizedString("blockchain.ux.dashboard.total.trading", comment: "") }
}
public protocol I_blockchain_ux_dashboard_total_trading: I {}
public extension I_blockchain_ux_dashboard_total_trading {
	var `balance`: L_blockchain_ux_dashboard_total_trading_balance { .init("\(__).balance") }
}
public final class L_blockchain_ux_dashboard_total_trading_balance: L, I_blockchain_ux_dashboard_total_trading_balance {
	public override class var localized: String { NSLocalizedString("blockchain.ux.dashboard.total.trading.balance", comment: "") }
}
public protocol I_blockchain_ux_dashboard_total_trading_balance: I {}
public extension I_blockchain_ux_dashboard_total_trading_balance {
	var `info`: L_blockchain_ux_dashboard_total_trading_balance_info { .init("\(__).info") }
}
public final class L_blockchain_ux_dashboard_total_trading_balance_info: L, I_blockchain_ux_dashboard_total_trading_balance_info {
	public override class var localized: String { NSLocalizedString("blockchain.ux.dashboard.total.trading.balance.info", comment: "") }
}
public protocol I_blockchain_ux_dashboard_total_trading_balance_info: I_blockchain_db_type_any, I_blockchain_session_state_stored_value {}
public final class L_blockchain_ux_earn: L, I_blockchain_ux_earn {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn", comment: "") }
}
public protocol I_blockchain_ux_earn: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_earn {
	var `discover`: L_blockchain_ux_earn_discover { .init("\(__).discover") }
	var `portfolio`: L_blockchain_ux_earn_portfolio { .init("\(__).portfolio") }
	var `supported`: L_blockchain_ux_earn_supported { .init("\(__).supported") }
	var `type`: L_blockchain_ux_earn_type { .init("\(__).type") }
}
public final class L_blockchain_ux_earn_discover: L, I_blockchain_ux_earn_discover {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.discover", comment: "") }
}
public protocol I_blockchain_ux_earn_discover: I_blockchain_ux_earn_type_hub {}
public extension I_blockchain_ux_earn_discover {
	var `learn`: L_blockchain_ux_earn_discover_learn { .init("\(__).learn") }
}
public final class L_blockchain_ux_earn_discover_learn: L, I_blockchain_ux_earn_discover_learn {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.discover.learn", comment: "") }
}
public protocol I_blockchain_ux_earn_discover_learn: I_blockchain_db_collection, I_blockchain_ux_type_task {}
public extension I_blockchain_ux_earn_discover_learn {
	var `more`: L_blockchain_ux_earn_discover_learn_more { .init("\(__).more") }
}
public final class L_blockchain_ux_earn_discover_learn_more: L, I_blockchain_ux_earn_discover_learn_more {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.discover.learn.more", comment: "") }
}
public protocol I_blockchain_ux_earn_discover_learn_more: I_blockchain_ux_type_task {}
public extension I_blockchain_ux_earn_discover_learn_more {
	var `url`: L_blockchain_ux_earn_discover_learn_more_url { .init("\(__).url") }
}
public final class L_blockchain_ux_earn_discover_learn_more_url: L, I_blockchain_ux_earn_discover_learn_more_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.discover.learn.more.url", comment: "") }
}
public protocol I_blockchain_ux_earn_discover_learn_more_url: I_blockchain_db_type_url, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_earn_portfolio: L, I_blockchain_ux_earn_portfolio {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.portfolio", comment: "") }
}
public protocol I_blockchain_ux_earn_portfolio: I_blockchain_ux_earn_type_hub {}
public final class L_blockchain_ux_earn_supported: L, I_blockchain_ux_earn_supported {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.supported", comment: "") }
}
public protocol I_blockchain_ux_earn_supported: I {}
public extension I_blockchain_ux_earn_supported {
	var `products`: L_blockchain_ux_earn_supported_products { .init("\(__).products") }
}
public final class L_blockchain_ux_earn_supported_products: L, I_blockchain_ux_earn_supported_products {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.supported.products", comment: "") }
}
public protocol I_blockchain_ux_earn_supported_products: I_blockchain_db_type_array_of_strings, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_earn_type: L, I_blockchain_ux_earn_type {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type", comment: "") }
}
public protocol I_blockchain_ux_earn_type: I {}
public extension I_blockchain_ux_earn_type {
	var `hub`: L_blockchain_ux_earn_type_hub { .init("\(__).hub") }
}
public final class L_blockchain_ux_earn_type_hub: L, I_blockchain_ux_earn_type_hub {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_earn_type_hub {
	var `filter`: L_blockchain_ux_earn_type_hub_filter { .init("\(__).filter") }
	var `product`: L_blockchain_ux_earn_type_hub_product { .init("\(__).product") }
	var `search`: L_blockchain_ux_earn_type_hub_search { .init("\(__).search") }
}
public final class L_blockchain_ux_earn_type_hub_filter: L, I_blockchain_ux_earn_type_hub_filter {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.filter", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_filter: I_blockchain_ux_type_task {}
public final class L_blockchain_ux_earn_type_hub_product: L, I_blockchain_ux_earn_type_hub_product {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product: I_blockchain_db_collection {}
public extension I_blockchain_ux_earn_type_hub_product {
	var `asset`: L_blockchain_ux_earn_type_hub_product_asset { .init("\(__).asset") }
	var `not`: L_blockchain_ux_earn_type_hub_product_not { .init("\(__).not") }
}
public final class L_blockchain_ux_earn_type_hub_product_asset: L, I_blockchain_ux_earn_type_hub_product_asset {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product.asset", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product_asset: I_blockchain_db_collection, I_blockchain_ux_type_task {}
public extension I_blockchain_ux_earn_type_hub_product_asset {
	var `no`: L_blockchain_ux_earn_type_hub_product_asset_no { .init("\(__).no") }
	var `summary`: L_blockchain_ux_earn_type_hub_product_asset_summary { .init("\(__).summary") }
}
public final class L_blockchain_ux_earn_type_hub_product_asset_no: L, I_blockchain_ux_earn_type_hub_product_asset_no {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product.asset.no", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product_asset_no: I {}
public extension I_blockchain_ux_earn_type_hub_product_asset_no {
	var `balance`: L_blockchain_ux_earn_type_hub_product_asset_no_balance { .init("\(__).balance") }
}
public final class L_blockchain_ux_earn_type_hub_product_asset_no_balance: L, I_blockchain_ux_earn_type_hub_product_asset_no_balance {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product.asset.no.balance", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product_asset_no_balance: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_earn_type_hub_product_asset_no_balance {
	var `buy`: L_blockchain_ux_earn_type_hub_product_asset_no_balance_buy { .init("\(__).buy") }
	var `receive`: L_blockchain_ux_earn_type_hub_product_asset_no_balance_receive { .init("\(__).receive") }
}
public final class L_blockchain_ux_earn_type_hub_product_asset_no_balance_buy: L, I_blockchain_ux_earn_type_hub_product_asset_no_balance_buy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product.asset.no.balance.buy", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product_asset_no_balance_buy: I_blockchain_ux_type_task {}
public final class L_blockchain_ux_earn_type_hub_product_asset_no_balance_receive: L, I_blockchain_ux_earn_type_hub_product_asset_no_balance_receive {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product.asset.no.balance.receive", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product_asset_no_balance_receive: I_blockchain_ux_type_task {}
public final class L_blockchain_ux_earn_type_hub_product_asset_summary: L, I_blockchain_ux_earn_type_hub_product_asset_summary {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product.asset.summary", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product_asset_summary: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_earn_type_hub_product_asset_summary {
	var `add`: L_blockchain_ux_earn_type_hub_product_asset_summary_add { .init("\(__).add") }
	var `learn`: L_blockchain_ux_earn_type_hub_product_asset_summary_learn { .init("\(__).learn") }
	var `view`: L_blockchain_ux_earn_type_hub_product_asset_summary_view { .init("\(__).view") }
	var `withdraw`: L_blockchain_ux_earn_type_hub_product_asset_summary_withdraw { .init("\(__).withdraw") }
}
public final class L_blockchain_ux_earn_type_hub_product_asset_summary_add: L, I_blockchain_ux_earn_type_hub_product_asset_summary_add {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product.asset.summary.add", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product_asset_summary_add: I_blockchain_ux_type_task {}
public final class L_blockchain_ux_earn_type_hub_product_asset_summary_learn: L, I_blockchain_ux_earn_type_hub_product_asset_summary_learn {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product.asset.summary.learn", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product_asset_summary_learn: I {}
public extension I_blockchain_ux_earn_type_hub_product_asset_summary_learn {
	var `more`: L_blockchain_ux_earn_type_hub_product_asset_summary_learn_more { .init("\(__).more") }
}
public final class L_blockchain_ux_earn_type_hub_product_asset_summary_learn_more: L, I_blockchain_ux_earn_type_hub_product_asset_summary_learn_more {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product.asset.summary.learn.more", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product_asset_summary_learn_more: I_blockchain_ux_type_task {}
public extension I_blockchain_ux_earn_type_hub_product_asset_summary_learn_more {
	var `url`: L_blockchain_ux_earn_type_hub_product_asset_summary_learn_more_url { .init("\(__).url") }
}
public final class L_blockchain_ux_earn_type_hub_product_asset_summary_learn_more_url: L, I_blockchain_ux_earn_type_hub_product_asset_summary_learn_more_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product.asset.summary.learn.more.url", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product_asset_summary_learn_more_url: I_blockchain_db_type_url, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_earn_type_hub_product_asset_summary_view: L, I_blockchain_ux_earn_type_hub_product_asset_summary_view {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product.asset.summary.view", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product_asset_summary_view: I {}
public extension I_blockchain_ux_earn_type_hub_product_asset_summary_view {
	var `activity`: L_blockchain_ux_earn_type_hub_product_asset_summary_view_activity { .init("\(__).activity") }
}
public final class L_blockchain_ux_earn_type_hub_product_asset_summary_view_activity: L, I_blockchain_ux_earn_type_hub_product_asset_summary_view_activity {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product.asset.summary.view.activity", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product_asset_summary_view_activity: I_blockchain_ux_type_task {}
public final class L_blockchain_ux_earn_type_hub_product_asset_summary_withdraw: L, I_blockchain_ux_earn_type_hub_product_asset_summary_withdraw {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product.asset.summary.withdraw", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product_asset_summary_withdraw: I_blockchain_ux_type_task {}
public final class L_blockchain_ux_earn_type_hub_product_not: L, I_blockchain_ux_earn_type_hub_product_not {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product.not", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product_not: I {}
public extension I_blockchain_ux_earn_type_hub_product_not {
	var `eligible`: L_blockchain_ux_earn_type_hub_product_not_eligible { .init("\(__).eligible") }
}
public final class L_blockchain_ux_earn_type_hub_product_not_eligible: L, I_blockchain_ux_earn_type_hub_product_not_eligible {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product.not.eligible", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product_not_eligible: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_earn_type_hub_product_not_eligible {
	var `go`: L_blockchain_ux_earn_type_hub_product_not_eligible_go { .init("\(__).go") }
}
public final class L_blockchain_ux_earn_type_hub_product_not_eligible_go: L, I_blockchain_ux_earn_type_hub_product_not_eligible_go {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product.not.eligible.go", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product_not_eligible_go: I {}
public extension I_blockchain_ux_earn_type_hub_product_not_eligible_go {
	var `back`: L_blockchain_ux_earn_type_hub_product_not_eligible_go_back { .init("\(__).back") }
}
public final class L_blockchain_ux_earn_type_hub_product_not_eligible_go_back: L, I_blockchain_ux_earn_type_hub_product_not_eligible_go_back {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.product.not.eligible.go.back", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_product_not_eligible_go_back: I_blockchain_ux_type_task {}
public final class L_blockchain_ux_earn_type_hub_search: L, I_blockchain_ux_earn_type_hub_search {
	public override class var localized: String { NSLocalizedString("blockchain.ux.earn.type.hub.search", comment: "") }
}
public protocol I_blockchain_ux_earn_type_hub_search: I_blockchain_ux_type_task {}
public final class L_blockchain_ux_error: L, I_blockchain_ux_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error", comment: "") }
}
public protocol I_blockchain_ux_error: I_blockchain_ux_type_story, I_blockchain_ui_device_haptic_feedback_notification_error, I_blockchain_ux_type_action {}
public extension I_blockchain_ux_error {
	var `context`: L_blockchain_ux_error_context { .init("\(__).context") }
}
public final class L_blockchain_ux_error_context: L, I_blockchain_ux_error_context {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error.context", comment: "") }
}
public protocol I_blockchain_ux_error_context: I {}
public extension I_blockchain_ux_error_context {
	var `action`: L_blockchain_ux_error_context_action { .init("\(__).action") }
	var `category`: L_blockchain_ux_error_context_category { .init("\(__).category") }
	var `id`: L_blockchain_ux_error_context_id { .init("\(__).id") }
	var `network`: L_blockchain_ux_error_context_network { .init("\(__).network") }
	var `source`: L_blockchain_ux_error_context_source { .init("\(__).source") }
	var `title`: L_blockchain_ux_error_context_title { .init("\(__).title") }
	var `type`: L_blockchain_ux_error_context_type { .init("\(__).type") }
}
public final class L_blockchain_ux_error_context_action: L, I_blockchain_ux_error_context_action {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error.context.action", comment: "") }
}
public protocol I_blockchain_ux_error_context_action: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_error_context_category: L, I_blockchain_ux_error_context_category {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error.context.category", comment: "") }
}
public protocol I_blockchain_ux_error_context_category: I_blockchain_db_type_string {}
public final class L_blockchain_ux_error_context_id: L, I_blockchain_ux_error_context_id {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error.context.id", comment: "") }
}
public protocol I_blockchain_ux_error_context_id: I_blockchain_db_type_string {}
public final class L_blockchain_ux_error_context_network: L, I_blockchain_ux_error_context_network {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error.context.network", comment: "") }
}
public protocol I_blockchain_ux_error_context_network: I {}
public extension I_blockchain_ux_error_context_network {
	var `endpoint`: L_blockchain_ux_error_context_network_endpoint { .init("\(__).endpoint") }
	var `error`: L_blockchain_ux_error_context_network_error { .init("\(__).error") }
}
public final class L_blockchain_ux_error_context_network_endpoint: L, I_blockchain_ux_error_context_network_endpoint {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error.context.network.endpoint", comment: "") }
}
public protocol I_blockchain_ux_error_context_network_endpoint: I_blockchain_db_type_url {}
public final class L_blockchain_ux_error_context_network_error: L, I_blockchain_ux_error_context_network_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error.context.network.error", comment: "") }
}
public protocol I_blockchain_ux_error_context_network_error: I {}
public extension I_blockchain_ux_error_context_network_error {
	var `code`: L_blockchain_ux_error_context_network_error_code { .init("\(__).code") }
	var `description`: L_blockchain_ux_error_context_network_error_description { .init("\(__).description") }
	var `id`: L_blockchain_ux_error_context_network_error_id { .init("\(__).id") }
	var `type`: L_blockchain_ux_error_context_network_error_type { .init("\(__).type") }
}
public final class L_blockchain_ux_error_context_network_error_code: L, I_blockchain_ux_error_context_network_error_code {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error.context.network.error.code", comment: "") }
}
public protocol I_blockchain_ux_error_context_network_error_code: I_blockchain_db_type_string {}
public final class L_blockchain_ux_error_context_network_error_description: L, I_blockchain_ux_error_context_network_error_description {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error.context.network.error.description", comment: "") }
}
public protocol I_blockchain_ux_error_context_network_error_description: I_blockchain_db_type_string {}
public final class L_blockchain_ux_error_context_network_error_id: L, I_blockchain_ux_error_context_network_error_id {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error.context.network.error.id", comment: "") }
}
public protocol I_blockchain_ux_error_context_network_error_id: I_blockchain_db_type_string {}
public final class L_blockchain_ux_error_context_network_error_type: L, I_blockchain_ux_error_context_network_error_type {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error.context.network.error.type", comment: "") }
}
public protocol I_blockchain_ux_error_context_network_error_type: I_blockchain_db_type_string {}
public final class L_blockchain_ux_error_context_source: L, I_blockchain_ux_error_context_source {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error.context.source", comment: "") }
}
public protocol I_blockchain_ux_error_context_source: I_blockchain_db_type_string {}
public final class L_blockchain_ux_error_context_title: L, I_blockchain_ux_error_context_title {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error.context.title", comment: "") }
}
public protocol I_blockchain_ux_error_context_title: I_blockchain_db_type_string {}
public final class L_blockchain_ux_error_context_type: L, I_blockchain_ux_error_context_type {
	public override class var localized: String { NSLocalizedString("blockchain.ux.error.context.type", comment: "") }
}
public protocol I_blockchain_ux_error_context_type: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_frequent: L, I_blockchain_ux_frequent {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent", comment: "") }
}
public protocol I_blockchain_ux_frequent: I {}
public extension I_blockchain_ux_frequent {
	var `action`: L_blockchain_ux_frequent_action { .init("\(__).action") }
}
public final class L_blockchain_ux_frequent_action: L, I_blockchain_ux_frequent_action {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action", comment: "") }
}
public protocol I_blockchain_ux_frequent_action: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_frequent_action {
	var `brokerage`: L_blockchain_ux_frequent_action_brokerage { .init("\(__).brokerage") }
	var `buy`: L_blockchain_ux_frequent_action_buy { .init("\(__).buy") }
	var `defi`: L_blockchain_ux_frequent_action_defi { .init("\(__).defi") }
	var `deposit`: L_blockchain_ux_frequent_action_deposit { .init("\(__).deposit") }
	var `earn`: L_blockchain_ux_frequent_action_earn { .init("\(__).earn") }
	var `nft`: L_blockchain_ux_frequent_action_nft { .init("\(__).nft") }
	var `receive`: L_blockchain_ux_frequent_action_receive { .init("\(__).receive") }
	var `rewards`: L_blockchain_ux_frequent_action_rewards { .init("\(__).rewards") }
	var `sell`: L_blockchain_ux_frequent_action_sell { .init("\(__).sell") }
	var `send`: L_blockchain_ux_frequent_action_send { .init("\(__).send") }
	var `swap`: L_blockchain_ux_frequent_action_swap { .init("\(__).swap") }
	var `withdraw`: L_blockchain_ux_frequent_action_withdraw { .init("\(__).withdraw") }
}
public final class L_blockchain_ux_frequent_action_brokerage: L, I_blockchain_ux_frequent_action_brokerage {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.brokerage", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_brokerage: I {}
public extension I_blockchain_ux_frequent_action_brokerage {
	var `more`: L_blockchain_ux_frequent_action_brokerage_more { .init("\(__).more") }
}
public final class L_blockchain_ux_frequent_action_brokerage_more: L, I_blockchain_ux_frequent_action_brokerage_more {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.brokerage.more", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_brokerage_more: I_blockchain_ux_type_story, I_blockchain_ui_device_haptic_feedback_impact_light {}
public extension I_blockchain_ux_frequent_action_brokerage_more {
	var `actions`: L_blockchain_ux_frequent_action_brokerage_more_actions { .init("\(__).actions") }
	var `close`: L_blockchain_ux_frequent_action_brokerage_more_close { .init("\(__).close") }
}
public final class L_blockchain_ux_frequent_action_brokerage_more_actions: L, I_blockchain_ux_frequent_action_brokerage_more_actions {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.brokerage.more.actions", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_brokerage_more_actions: I_blockchain_db_type_any {}
public final class L_blockchain_ux_frequent_action_brokerage_more_close: L, I_blockchain_ux_frequent_action_brokerage_more_close {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.brokerage.more.close", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_brokerage_more_close: I_blockchain_ui_type_action {}
public final class L_blockchain_ux_frequent_action_buy: L, I_blockchain_ux_frequent_action_buy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.buy", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_buy: I_blockchain_ui_device_haptic_feedback_impact_light, I_blockchain_ux_type_action {}
public final class L_blockchain_ux_frequent_action_defi: L, I_blockchain_ux_frequent_action_defi {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.defi", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_defi: I {}
public extension I_blockchain_ux_frequent_action_defi {
	var `buy`: L_blockchain_ux_frequent_action_defi_buy { .init("\(__).buy") }
	var `switch`: L_blockchain_ux_frequent_action_defi_switch { .init("\(__).switch") }
}
public final class L_blockchain_ux_frequent_action_defi_buy: L, I_blockchain_ux_frequent_action_defi_buy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.defi.buy", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_defi_buy: I {}
public final class L_blockchain_ux_frequent_action_defi_switch: L, I_blockchain_ux_frequent_action_defi_switch {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.defi.switch", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_defi_switch: I {}
public extension I_blockchain_ux_frequent_action_defi_switch {
	var `to`: L_blockchain_ux_frequent_action_defi_switch_to { .init("\(__).to") }
}
public final class L_blockchain_ux_frequent_action_defi_switch_to: L, I_blockchain_ux_frequent_action_defi_switch_to {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.defi.switch.to", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_defi_switch_to: I {}
public extension I_blockchain_ux_frequent_action_defi_switch_to {
	var `trading`: L_blockchain_ux_frequent_action_defi_switch_to_trading { .init("\(__).trading") }
}
public final class L_blockchain_ux_frequent_action_defi_switch_to_trading: L, I_blockchain_ux_frequent_action_defi_switch_to_trading {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.defi.switch.to.trading", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_defi_switch_to_trading: I {}
public final class L_blockchain_ux_frequent_action_deposit: L, I_blockchain_ux_frequent_action_deposit {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.deposit", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_deposit: I_blockchain_ui_device_haptic_feedback_impact_light, I_blockchain_ux_type_action {}
public final class L_blockchain_ux_frequent_action_earn: L, I_blockchain_ux_frequent_action_earn {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.earn", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_earn: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_frequent_action_nft: L, I_blockchain_ux_frequent_action_nft {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.nft", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_nft: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_frequent_action_receive: L, I_blockchain_ux_frequent_action_receive {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.receive", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_receive: I_blockchain_ui_device_haptic_feedback_impact_light, I_blockchain_ux_type_action {}
public final class L_blockchain_ux_frequent_action_rewards: L, I_blockchain_ux_frequent_action_rewards {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.rewards", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_rewards: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_frequent_action_sell: L, I_blockchain_ux_frequent_action_sell {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.sell", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_sell: I_blockchain_ui_device_haptic_feedback_impact_light, I_blockchain_ux_type_action {}
public final class L_blockchain_ux_frequent_action_send: L, I_blockchain_ux_frequent_action_send {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.send", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_send: I_blockchain_ui_device_haptic_feedback_impact_light, I_blockchain_ux_type_action {}
public final class L_blockchain_ux_frequent_action_swap: L, I_blockchain_ux_frequent_action_swap {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.swap", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_swap: I_blockchain_ui_device_haptic_feedback_impact_light, I_blockchain_ux_type_action {}
public final class L_blockchain_ux_frequent_action_withdraw: L, I_blockchain_ux_frequent_action_withdraw {
	public override class var localized: String { NSLocalizedString("blockchain.ux.frequent.action.withdraw", comment: "") }
}
public protocol I_blockchain_ux_frequent_action_withdraw: I_blockchain_ui_device_haptic_feedback_impact_light, I_blockchain_ux_type_action {}
public final class L_blockchain_ux_home: L, I_blockchain_ux_home {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home", comment: "") }
}
public protocol I_blockchain_ux_home: I {}
public extension I_blockchain_ux_home {
	var `dashboard`: L_blockchain_ux_home_dashboard { .init("\(__).dashboard") }
	var `event`: L_blockchain_ux_home_event { .init("\(__).event") }
	var `tab`: L_blockchain_ux_home_tab { .init("\(__).tab") }
}
public final class L_blockchain_ux_home_dashboard: L, I_blockchain_ux_home_dashboard {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.dashboard", comment: "") }
}
public protocol I_blockchain_ux_home_dashboard: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_home_dashboard {
	var `announcement`: L_blockchain_ux_home_dashboard_announcement { .init("\(__).announcement") }
}
public final class L_blockchain_ux_home_dashboard_announcement: L, I_blockchain_ux_home_dashboard_announcement {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.dashboard.announcement", comment: "") }
}
public protocol I_blockchain_ux_home_dashboard_announcement: I_blockchain_ui_type_element, I_blockchain_db_collection {}
public extension I_blockchain_ux_home_dashboard_announcement {
	var `button`: L_blockchain_ux_home_dashboard_announcement_button { .init("\(__).button") }
	var `description`: L_blockchain_ux_home_dashboard_announcement_description { .init("\(__).description") }
	var `title`: L_blockchain_ux_home_dashboard_announcement_title { .init("\(__).title") }
}
public final class L_blockchain_ux_home_dashboard_announcement_button: L, I_blockchain_ux_home_dashboard_announcement_button {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.dashboard.announcement.button", comment: "") }
}
public protocol I_blockchain_ux_home_dashboard_announcement_button: I_blockchain_ui_type_button_primary {}
public final class L_blockchain_ux_home_dashboard_announcement_description: L, I_blockchain_ux_home_dashboard_announcement_description {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.dashboard.announcement.description", comment: "") }
}
public protocol I_blockchain_ux_home_dashboard_announcement_description: I_blockchain_db_type_string {}
public final class L_blockchain_ux_home_dashboard_announcement_title: L, I_blockchain_ux_home_dashboard_announcement_title {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.dashboard.announcement.title", comment: "") }
}
public protocol I_blockchain_ux_home_dashboard_announcement_title: I_blockchain_db_type_string {}
public final class L_blockchain_ux_home_event: L, I_blockchain_ux_home_event {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.event", comment: "") }
}
public protocol I_blockchain_ux_home_event: I {}
public extension I_blockchain_ux_home_event {
	var `did`: L_blockchain_ux_home_event_did { .init("\(__).did") }
}
public final class L_blockchain_ux_home_event_did: L, I_blockchain_ux_home_event_did {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.event.did", comment: "") }
}
public protocol I_blockchain_ux_home_event_did: I {}
public extension I_blockchain_ux_home_event_did {
	var `pull`: L_blockchain_ux_home_event_did_pull { .init("\(__).pull") }
}
public final class L_blockchain_ux_home_event_did_pull: L, I_blockchain_ux_home_event_did_pull {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.event.did.pull", comment: "") }
}
public protocol I_blockchain_ux_home_event_did_pull: I {}
public extension I_blockchain_ux_home_event_did_pull {
	var `to`: L_blockchain_ux_home_event_did_pull_to { .init("\(__).to") }
}
public final class L_blockchain_ux_home_event_did_pull_to: L, I_blockchain_ux_home_event_did_pull_to {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.event.did.pull.to", comment: "") }
}
public protocol I_blockchain_ux_home_event_did_pull_to: I {}
public extension I_blockchain_ux_home_event_did_pull_to {
	var `refresh`: L_blockchain_ux_home_event_did_pull_to_refresh { .init("\(__).refresh") }
}
public final class L_blockchain_ux_home_event_did_pull_to_refresh: L, I_blockchain_ux_home_event_did_pull_to_refresh {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.event.did.pull.to.refresh", comment: "") }
}
public protocol I_blockchain_ux_home_event_did_pull_to_refresh: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_home_tab: L, I_blockchain_ux_home_tab {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.tab", comment: "") }
}
public protocol I_blockchain_ux_home_tab: I_blockchain_db_collection {}
public extension I_blockchain_ux_home_tab {
	var `select`: L_blockchain_ux_home_tab_select { .init("\(__).select") }
}
public final class L_blockchain_ux_home_tab_select: L, I_blockchain_ux_home_tab_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.home.tab.select", comment: "") }
}
public protocol I_blockchain_ux_home_tab_select: I_blockchain_ui_device_haptic_feedback_impact_soft, I_blockchain_ux_type_action {}
public final class L_blockchain_ux_kyc: L, I_blockchain_ux_kyc {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc", comment: "") }
}
public protocol I_blockchain_ux_kyc: I {}
public extension I_blockchain_ux_kyc {
	var `current`: L_blockchain_ux_kyc_current { .init("\(__).current") }
	var `event`: L_blockchain_ux_kyc_event { .init("\(__).event") }
	var `extra`: L_blockchain_ux_kyc_extra { .init("\(__).extra") }
	var `tier`: L_blockchain_ux_kyc_tier { .init("\(__).tier") }
	var `trading`: L_blockchain_ux_kyc_trading { .init("\(__).trading") }
	var `type`: L_blockchain_ux_kyc_type { .init("\(__).type") }
}
public final class L_blockchain_ux_kyc_current: L, I_blockchain_ux_kyc_current {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.current", comment: "") }
}
public protocol I_blockchain_ux_kyc_current: I {}
public extension I_blockchain_ux_kyc_current {
	var `state`: L_blockchain_ux_kyc_current_state { .init("\(__).state") }
}
public final class L_blockchain_ux_kyc_current_state: L, I_blockchain_ux_kyc_current_state {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.current.state", comment: "") }
}
public protocol I_blockchain_ux_kyc_current_state: I_blockchain_ux_kyc_type_state {}
public final class L_blockchain_ux_kyc_event: L, I_blockchain_ux_kyc_event {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event", comment: "") }
}
public protocol I_blockchain_ux_kyc_event: I {}
public extension I_blockchain_ux_kyc_event {
	var `did`: L_blockchain_ux_kyc_event_did { .init("\(__).did") }
	var `status`: L_blockchain_ux_kyc_event_status { .init("\(__).status") }
}
public final class L_blockchain_ux_kyc_event_did: L, I_blockchain_ux_kyc_event_did {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.did", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_did: I {}
public extension I_blockchain_ux_kyc_event_did {
	var `cancel`: L_blockchain_ux_kyc_event_did_cancel { .init("\(__).cancel") }
	var `confirm`: L_blockchain_ux_kyc_event_did_confirm { .init("\(__).confirm") }
	var `enter`: L_blockchain_ux_kyc_event_did_enter { .init("\(__).enter") }
	var `fail`: L_blockchain_ux_kyc_event_did_fail { .init("\(__).fail") }
	var `finish`: L_blockchain_ux_kyc_event_did_finish { .init("\(__).finish") }
	var `start`: L_blockchain_ux_kyc_event_did_start { .init("\(__).start") }
	var `stop`: L_blockchain_ux_kyc_event_did_stop { .init("\(__).stop") }
}
public final class L_blockchain_ux_kyc_event_did_cancel: L, I_blockchain_ux_kyc_event_did_cancel {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.did.cancel", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_did_cancel: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_kyc_event_did_confirm: L, I_blockchain_ux_kyc_event_did_confirm {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.did.confirm", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_did_confirm: I {}
public extension I_blockchain_ux_kyc_event_did_confirm {
	var `state`: L_blockchain_ux_kyc_event_did_confirm_state { .init("\(__).state") }
}
public final class L_blockchain_ux_kyc_event_did_confirm_state: L, I_blockchain_ux_kyc_event_did_confirm_state {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.did.confirm.state", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_did_confirm_state: I_blockchain_ux_kyc_type_state {}
public final class L_blockchain_ux_kyc_event_did_enter: L, I_blockchain_ux_kyc_event_did_enter {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.did.enter", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_did_enter: I {}
public extension I_blockchain_ux_kyc_event_did_enter {
	var `state`: L_blockchain_ux_kyc_event_did_enter_state { .init("\(__).state") }
}
public final class L_blockchain_ux_kyc_event_did_enter_state: L, I_blockchain_ux_kyc_event_did_enter_state {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.did.enter.state", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_did_enter_state: I_blockchain_ux_kyc_type_state {}
public final class L_blockchain_ux_kyc_event_did_fail: L, I_blockchain_ux_kyc_event_did_fail {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.did.fail", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_did_fail: I {}
public extension I_blockchain_ux_kyc_event_did_fail {
	var `on`: L_blockchain_ux_kyc_event_did_fail_on { .init("\(__).on") }
}
public final class L_blockchain_ux_kyc_event_did_fail_on: L, I_blockchain_ux_kyc_event_did_fail_on {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.did.fail.on", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_did_fail_on: I {}
public extension I_blockchain_ux_kyc_event_did_fail_on {
	var `state`: L_blockchain_ux_kyc_event_did_fail_on_state { .init("\(__).state") }
}
public final class L_blockchain_ux_kyc_event_did_fail_on_state: L, I_blockchain_ux_kyc_event_did_fail_on_state {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.did.fail.on.state", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_did_fail_on_state: I_blockchain_ux_kyc_type_state {}
public final class L_blockchain_ux_kyc_event_did_finish: L, I_blockchain_ux_kyc_event_did_finish {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.did.finish", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_did_finish: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_kyc_event_did_start: L, I_blockchain_ux_kyc_event_did_start {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.did.start", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_did_start: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_kyc_event_did_stop: L, I_blockchain_ux_kyc_event_did_stop {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.did.stop", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_did_stop: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_kyc_event_status: L, I_blockchain_ux_kyc_event_status {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.status", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_status: I {}
public extension I_blockchain_ux_kyc_event_status {
	var `did`: L_blockchain_ux_kyc_event_status_did { .init("\(__).did") }
}
public final class L_blockchain_ux_kyc_event_status_did: L, I_blockchain_ux_kyc_event_status_did {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.status.did", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_status_did: I {}
public extension I_blockchain_ux_kyc_event_status_did {
	var `change`: L_blockchain_ux_kyc_event_status_did_change { .init("\(__).change") }
}
public final class L_blockchain_ux_kyc_event_status_did_change: L, I_blockchain_ux_kyc_event_status_did_change {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.event.status.did.change", comment: "") }
}
public protocol I_blockchain_ux_kyc_event_status_did_change: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_kyc_extra: L, I_blockchain_ux_kyc_extra {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra: I {}
public extension I_blockchain_ux_kyc_extra {
	var `questions`: L_blockchain_ux_kyc_extra_questions { .init("\(__).questions") }
}
public final class L_blockchain_ux_kyc_extra_questions: L, I_blockchain_ux_kyc_extra_questions {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions: I {}
public extension I_blockchain_ux_kyc_extra_questions {
	var `context`: L_blockchain_ux_kyc_extra_questions_context { .init("\(__).context") }
	var `default`: L_blockchain_ux_kyc_extra_questions_default { .init("\(__).default") }
	var `form`: L_blockchain_ux_kyc_extra_questions_form { .init("\(__).form") }
}
public final class L_blockchain_ux_kyc_extra_questions_context: L, I_blockchain_ux_kyc_extra_questions_context {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions.context", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions_context: I {}
public extension I_blockchain_ux_kyc_extra_questions_context {
	var `observer`: L_blockchain_ux_kyc_extra_questions_context_observer { .init("\(__).observer") }
}
public final class L_blockchain_ux_kyc_extra_questions_context_observer: L, I_blockchain_ux_kyc_extra_questions_context_observer {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions.context.observer", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions_context_observer: I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_kyc_extra_questions_default: L, I_blockchain_ux_kyc_extra_questions_default {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions.default", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions_default: I {}
public extension I_blockchain_ux_kyc_extra_questions_default {
	var `context`: L_blockchain_ux_kyc_extra_questions_default_context { .init("\(__).context") }
}
public final class L_blockchain_ux_kyc_extra_questions_default_context: L, I_blockchain_ux_kyc_extra_questions_default_context {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions.default.context", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions_default_context: I_blockchain_db_type_string, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_kyc_extra_questions_form: L, I_blockchain_ux_kyc_extra_questions_form {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions.form", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions_form: I_blockchain_db_collection {}
public extension I_blockchain_ux_kyc_extra_questions_form {
	var `data`: L_blockchain_ux_kyc_extra_questions_form_data { .init("\(__).data") }
	var `is`: L_blockchain_ux_kyc_extra_questions_form_is { .init("\(__).is") }
}
public final class L_blockchain_ux_kyc_extra_questions_form_data: L, I_blockchain_ux_kyc_extra_questions_form_data {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions.form.data", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions_form_data: I_blockchain_session_state_value {}
public final class L_blockchain_ux_kyc_extra_questions_form_is: L, I_blockchain_ux_kyc_extra_questions_form_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions.form.is", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions_form_is: I {}
public extension I_blockchain_ux_kyc_extra_questions_form_is {
	var `empty`: L_blockchain_ux_kyc_extra_questions_form_is_empty { .init("\(__).empty") }
}
public final class L_blockchain_ux_kyc_extra_questions_form_is_empty: L, I_blockchain_ux_kyc_extra_questions_form_is_empty {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.extra.questions.form.is.empty", comment: "") }
}
public protocol I_blockchain_ux_kyc_extra_questions_form_is_empty: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_kyc_tier: L, I_blockchain_ux_kyc_tier {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.tier", comment: "") }
}
public protocol I_blockchain_ux_kyc_tier: I_blockchain_db_type_enum {}
public extension I_blockchain_ux_kyc_tier {
	var `gold`: L_blockchain_ux_kyc_tier_gold { .init("\(__).gold") }
	var `none`: L_blockchain_ux_kyc_tier_none { .init("\(__).none") }
	var `platinum`: L_blockchain_ux_kyc_tier_platinum { .init("\(__).platinum") }
	var `silver`: L_blockchain_ux_kyc_tier_silver { .init("\(__).silver") }
}
public final class L_blockchain_ux_kyc_tier_gold: L, I_blockchain_ux_kyc_tier_gold {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.tier.gold", comment: "") }
}
public protocol I_blockchain_ux_kyc_tier_gold: I {}
public final class L_blockchain_ux_kyc_tier_none: L, I_blockchain_ux_kyc_tier_none {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.tier.none", comment: "") }
}
public protocol I_blockchain_ux_kyc_tier_none: I {}
public final class L_blockchain_ux_kyc_tier_platinum: L, I_blockchain_ux_kyc_tier_platinum {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.tier.platinum", comment: "") }
}
public protocol I_blockchain_ux_kyc_tier_platinum: I {}
public final class L_blockchain_ux_kyc_tier_silver: L, I_blockchain_ux_kyc_tier_silver {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.tier.silver", comment: "") }
}
public protocol I_blockchain_ux_kyc_tier_silver: I {}
public final class L_blockchain_ux_kyc_trading: L, I_blockchain_ux_kyc_trading {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.trading", comment: "") }
}
public protocol I_blockchain_ux_kyc_trading: I {}
public extension I_blockchain_ux_kyc_trading {
	var `limits`: L_blockchain_ux_kyc_trading_limits { .init("\(__).limits") }
	var `unlock`: L_blockchain_ux_kyc_trading_unlock { .init("\(__).unlock") }
	var `upgrade`: L_blockchain_ux_kyc_trading_upgrade { .init("\(__).upgrade") }
}
public final class L_blockchain_ux_kyc_trading_limits: L, I_blockchain_ux_kyc_trading_limits {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.trading.limits", comment: "") }
}
public protocol I_blockchain_ux_kyc_trading_limits: I {}
public extension I_blockchain_ux_kyc_trading_limits {
	var `overview`: L_blockchain_ux_kyc_trading_limits_overview { .init("\(__).overview") }
}
public final class L_blockchain_ux_kyc_trading_limits_overview: L, I_blockchain_ux_kyc_trading_limits_overview {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.trading.limits.overview", comment: "") }
}
public protocol I_blockchain_ux_kyc_trading_limits_overview: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_kyc_trading_unlock: L, I_blockchain_ux_kyc_trading_unlock {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.trading.unlock", comment: "") }
}
public protocol I_blockchain_ux_kyc_trading_unlock: I {}
public extension I_blockchain_ux_kyc_trading_unlock {
	var `more`: L_blockchain_ux_kyc_trading_unlock_more { .init("\(__).more") }
}
public final class L_blockchain_ux_kyc_trading_unlock_more: L, I_blockchain_ux_kyc_trading_unlock_more {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.trading.unlock.more", comment: "") }
}
public protocol I_blockchain_ux_kyc_trading_unlock_more: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_kyc_trading_upgrade: L, I_blockchain_ux_kyc_trading_upgrade {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.trading.upgrade", comment: "") }
}
public protocol I_blockchain_ux_kyc_trading_upgrade: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_kyc_type: L, I_blockchain_ux_kyc_type {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type", comment: "") }
}
public protocol I_blockchain_ux_kyc_type: I {}
public extension I_blockchain_ux_kyc_type {
	var `state`: L_blockchain_ux_kyc_type_state { .init("\(__).state") }
}
public final class L_blockchain_ux_kyc_type_state: L, I_blockchain_ux_kyc_type_state {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state: I_blockchain_db_type_enum, I_blockchain_session_state_value {}
public extension I_blockchain_ux_kyc_type_state {
	var `account`: L_blockchain_ux_kyc_type_state_account { .init("\(__).account") }
	var `address`: L_blockchain_ux_kyc_type_state_address { .init("\(__).address") }
	var `application`: L_blockchain_ux_kyc_type_state_application { .init("\(__).application") }
	var `confirm`: L_blockchain_ux_kyc_type_state_confirm { .init("\(__).confirm") }
	var `country`: L_blockchain_ux_kyc_type_state_country { .init("\(__).country") }
	var `enter`: L_blockchain_ux_kyc_type_state_enter { .init("\(__).enter") }
	var `finish`: L_blockchain_ux_kyc_type_state_finish { .init("\(__).finish") }
	var `force_gold`: L_blockchain_ux_kyc_type_state_force__gold { .init("\(__).force_gold") }
	var `profile`: L_blockchain_ux_kyc_type_state_profile { .init("\(__).profile") }
	var `resubmit`: L_blockchain_ux_kyc_type_state_resubmit { .init("\(__).resubmit") }
	var `sdd`: L_blockchain_ux_kyc_type_state_sdd { .init("\(__).sdd") }
	var `states`: L_blockchain_ux_kyc_type_state_states { .init("\(__).states") }
	var `verify`: L_blockchain_ux_kyc_type_state_verify { .init("\(__).verify") }
	var `welcome`: L_blockchain_ux_kyc_type_state_welcome { .init("\(__).welcome") }
}
public final class L_blockchain_ux_kyc_type_state_account: L, I_blockchain_ux_kyc_type_state_account {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.account", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_account: I {}
public extension I_blockchain_ux_kyc_type_state_account {
	var `form`: L_blockchain_ux_kyc_type_state_account_form { .init("\(__).form") }
	var `status`: L_blockchain_ux_kyc_type_state_account_status { .init("\(__).status") }
}
public final class L_blockchain_ux_kyc_type_state_account_form: L, I_blockchain_ux_kyc_type_state_account_form {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.account.form", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_account_form: I {}
public final class L_blockchain_ux_kyc_type_state_account_status: L, I_blockchain_ux_kyc_type_state_account_status {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.account.status", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_account_status: I {}
public final class L_blockchain_ux_kyc_type_state_address: L, I_blockchain_ux_kyc_type_state_address {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.address", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_address: I {}
public final class L_blockchain_ux_kyc_type_state_application: L, I_blockchain_ux_kyc_type_state_application {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.application", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_application: I {}
public extension I_blockchain_ux_kyc_type_state_application {
	var `complete`: L_blockchain_ux_kyc_type_state_application_complete { .init("\(__).complete") }
}
public final class L_blockchain_ux_kyc_type_state_application_complete: L, I_blockchain_ux_kyc_type_state_application_complete {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.application.complete", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_application_complete: I {}
public final class L_blockchain_ux_kyc_type_state_confirm: L, I_blockchain_ux_kyc_type_state_confirm {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.confirm", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_confirm: I {}
public extension I_blockchain_ux_kyc_type_state_confirm {
	var `email`: L_blockchain_ux_kyc_type_state_confirm_email { .init("\(__).email") }
	var `phone`: L_blockchain_ux_kyc_type_state_confirm_phone { .init("\(__).phone") }
}
public final class L_blockchain_ux_kyc_type_state_confirm_email: L, I_blockchain_ux_kyc_type_state_confirm_email {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.confirm.email", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_confirm_email: I {}
public final class L_blockchain_ux_kyc_type_state_confirm_phone: L, I_blockchain_ux_kyc_type_state_confirm_phone {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.confirm.phone", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_confirm_phone: I {}
public final class L_blockchain_ux_kyc_type_state_country: L, I_blockchain_ux_kyc_type_state_country {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.country", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_country: I {}
public final class L_blockchain_ux_kyc_type_state_enter: L, I_blockchain_ux_kyc_type_state_enter {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.enter", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_enter: I {}
public extension I_blockchain_ux_kyc_type_state_enter {
	var `email`: L_blockchain_ux_kyc_type_state_enter_email { .init("\(__).email") }
	var `phone`: L_blockchain_ux_kyc_type_state_enter_phone { .init("\(__).phone") }
}
public final class L_blockchain_ux_kyc_type_state_enter_email: L, I_blockchain_ux_kyc_type_state_enter_email {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.enter.email", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_enter_email: I {}
public final class L_blockchain_ux_kyc_type_state_enter_phone: L, I_blockchain_ux_kyc_type_state_enter_phone {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.enter.phone", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_enter_phone: I {}
public final class L_blockchain_ux_kyc_type_state_finish: L, I_blockchain_ux_kyc_type_state_finish {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.finish", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_finish: I {}
public final class L_blockchain_ux_kyc_type_state_force__gold: L, I_blockchain_ux_kyc_type_state_force__gold {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.force_gold", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_force__gold: I {}
public final class L_blockchain_ux_kyc_type_state_profile: L, I_blockchain_ux_kyc_type_state_profile {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.profile", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_profile: I {}
public final class L_blockchain_ux_kyc_type_state_resubmit: L, I_blockchain_ux_kyc_type_state_resubmit {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.resubmit", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_resubmit: I {}
public extension I_blockchain_ux_kyc_type_state_resubmit {
	var `identity`: L_blockchain_ux_kyc_type_state_resubmit_identity { .init("\(__).identity") }
}
public final class L_blockchain_ux_kyc_type_state_resubmit_identity: L, I_blockchain_ux_kyc_type_state_resubmit_identity {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.resubmit.identity", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_resubmit_identity: I {}
public final class L_blockchain_ux_kyc_type_state_sdd: L, I_blockchain_ux_kyc_type_state_sdd {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.sdd", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_sdd: I {}
public extension I_blockchain_ux_kyc_type_state_sdd {
	var `verification`: L_blockchain_ux_kyc_type_state_sdd_verification { .init("\(__).verification") }
}
public final class L_blockchain_ux_kyc_type_state_sdd_verification: L, I_blockchain_ux_kyc_type_state_sdd_verification {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.sdd.verification", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_sdd_verification: I {}
public final class L_blockchain_ux_kyc_type_state_states: L, I_blockchain_ux_kyc_type_state_states {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.states", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_states: I {}
public final class L_blockchain_ux_kyc_type_state_verify: L, I_blockchain_ux_kyc_type_state_verify {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.verify", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_verify: I {}
public extension I_blockchain_ux_kyc_type_state_verify {
	var `identity`: L_blockchain_ux_kyc_type_state_verify_identity { .init("\(__).identity") }
}
public final class L_blockchain_ux_kyc_type_state_verify_identity: L, I_blockchain_ux_kyc_type_state_verify_identity {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.verify.identity", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_verify_identity: I {}
public final class L_blockchain_ux_kyc_type_state_welcome: L, I_blockchain_ux_kyc_type_state_welcome {
	public override class var localized: String { NSLocalizedString("blockchain.ux.kyc.type.state.welcome", comment: "") }
}
public protocol I_blockchain_ux_kyc_type_state_welcome: I {}
public final class L_blockchain_ux_maintenance: L, I_blockchain_ux_maintenance {
	public override class var localized: String { NSLocalizedString("blockchain.ux.maintenance", comment: "") }
}
public protocol I_blockchain_ux_maintenance: I_blockchain_db_collection, I_blockchain_ux_type_story {}
public final class L_blockchain_ux_multiapp: L, I_blockchain_ux_multiapp {
	public override class var localized: String { NSLocalizedString("blockchain.ux.multiapp", comment: "") }
}
public protocol I_blockchain_ux_multiapp: I {}
public extension I_blockchain_ux_multiapp {
	var `present`: L_blockchain_ux_multiapp_present { .init("\(__).present") }
	var `wallet`: L_blockchain_ux_multiapp_wallet { .init("\(__).wallet") }
}
public final class L_blockchain_ux_multiapp_present: L, I_blockchain_ux_multiapp_present {
	public override class var localized: String { NSLocalizedString("blockchain.ux.multiapp.present", comment: "") }
}
public protocol I_blockchain_ux_multiapp_present: I {}
public extension I_blockchain_ux_multiapp_present {
	var `allAssetsScreen`: L_blockchain_ux_multiapp_present_allAssetsScreen { .init("\(__).allAssetsScreen") }
}
public final class L_blockchain_ux_multiapp_present_allAssetsScreen: L, I_blockchain_ux_multiapp_present_allAssetsScreen {
	public override class var localized: String { NSLocalizedString("blockchain.ux.multiapp.present.allAssetsScreen", comment: "") }
}
public protocol I_blockchain_ux_multiapp_present_allAssetsScreen: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_multiapp_wallet: L, I_blockchain_ux_multiapp_wallet {
	public override class var localized: String { NSLocalizedString("blockchain.ux.multiapp.wallet", comment: "") }
}
public protocol I_blockchain_ux_multiapp_wallet: I {}
public extension I_blockchain_ux_multiapp_wallet {
	var `action`: L_blockchain_ux_multiapp_wallet_action { .init("\(__).action") }
}
public final class L_blockchain_ux_multiapp_wallet_action: L, I_blockchain_ux_multiapp_wallet_action {
	public override class var localized: String { NSLocalizedString("blockchain.ux.multiapp.wallet.action", comment: "") }
}
public protocol I_blockchain_ux_multiapp_wallet_action: I {}
public extension I_blockchain_ux_multiapp_wallet_action {
	var `sheet`: L_blockchain_ux_multiapp_wallet_action_sheet { .init("\(__).sheet") }
}
public final class L_blockchain_ux_multiapp_wallet_action_sheet: L, I_blockchain_ux_multiapp_wallet_action_sheet {
	public override class var localized: String { NSLocalizedString("blockchain.ux.multiapp.wallet.action.sheet", comment: "") }
}
public protocol I_blockchain_ux_multiapp_wallet_action_sheet: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_nft: L, I_blockchain_ux_nft {
	public override class var localized: String { NSLocalizedString("blockchain.ux.nft", comment: "") }
}
public protocol I_blockchain_ux_nft: I {}
public extension I_blockchain_ux_nft {
	var `asset`: L_blockchain_ux_nft_asset { .init("\(__).asset") }
	var `collection`: L_blockchain_ux_nft_collection { .init("\(__).collection") }
	var `wallet`: L_blockchain_ux_nft_wallet { .init("\(__).wallet") }
}
public final class L_blockchain_ux_nft_asset: L, I_blockchain_ux_nft_asset {
	public override class var localized: String { NSLocalizedString("blockchain.ux.nft.asset", comment: "") }
}
public protocol I_blockchain_ux_nft_asset: I_blockchain_db_collection {}
public extension I_blockchain_ux_nft_asset {
	var `select`: L_blockchain_ux_nft_asset_select { .init("\(__).select") }
}
public final class L_blockchain_ux_nft_asset_select: L, I_blockchain_ux_nft_asset_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.nft.asset.select", comment: "") }
}
public protocol I_blockchain_ux_nft_asset_select: I {}
public final class L_blockchain_ux_nft_collection: L, I_blockchain_ux_nft_collection {
	public override class var localized: String { NSLocalizedString("blockchain.ux.nft.collection", comment: "") }
}
public protocol I_blockchain_ux_nft_collection: I_blockchain_db_collection, I_blockchain_ux_type_story {}
public extension I_blockchain_ux_nft_collection {
	var `select`: L_blockchain_ux_nft_collection_select { .init("\(__).select") }
}
public final class L_blockchain_ux_nft_collection_select: L, I_blockchain_ux_nft_collection_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.nft.collection.select", comment: "") }
}
public protocol I_blockchain_ux_nft_collection_select: I {}
public final class L_blockchain_ux_nft_wallet: L, I_blockchain_ux_nft_wallet {
	public override class var localized: String { NSLocalizedString("blockchain.ux.nft.wallet", comment: "") }
}
public protocol I_blockchain_ux_nft_wallet: I_blockchain_db_collection {}
public extension I_blockchain_ux_nft_wallet {
	var `select`: L_blockchain_ux_nft_wallet_select { .init("\(__).select") }
}
public final class L_blockchain_ux_nft_wallet_select: L, I_blockchain_ux_nft_wallet_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.nft.wallet.select", comment: "") }
}
public protocol I_blockchain_ux_nft_wallet_select: I {}
public final class L_blockchain_ux_onboarding: L, I_blockchain_ux_onboarding {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding", comment: "") }
}
public protocol I_blockchain_ux_onboarding: I {}
public extension I_blockchain_ux_onboarding {
	var `intro`: L_blockchain_ux_onboarding_intro { .init("\(__).intro") }
	var `promotion`: L_blockchain_ux_onboarding_promotion { .init("\(__).promotion") }
	var `type`: L_blockchain_ux_onboarding_type { .init("\(__).type") }
}
public final class L_blockchain_ux_onboarding_intro: L, I_blockchain_ux_onboarding_intro {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.intro", comment: "") }
}
public protocol I_blockchain_ux_onboarding_intro: I {}
public extension I_blockchain_ux_onboarding_intro {
	var `did`: L_blockchain_ux_onboarding_intro_did { .init("\(__).did") }
	var `event`: L_blockchain_ux_onboarding_intro_event { .init("\(__).event") }
}
public final class L_blockchain_ux_onboarding_intro_did: L, I_blockchain_ux_onboarding_intro_did {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.intro.did", comment: "") }
}
public protocol I_blockchain_ux_onboarding_intro_did: I {}
public extension I_blockchain_ux_onboarding_intro_did {
	var `show`: L_blockchain_ux_onboarding_intro_did_show { .init("\(__).show") }
}
public final class L_blockchain_ux_onboarding_intro_did_show: L, I_blockchain_ux_onboarding_intro_did_show {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.intro.did.show", comment: "") }
}
public protocol I_blockchain_ux_onboarding_intro_did_show: I_blockchain_db_type_boolean, I_blockchain_session_state_shared_value, I_blockchain_session_state_stored_value {}
public final class L_blockchain_ux_onboarding_intro_event: L, I_blockchain_ux_onboarding_intro_event {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.intro.event", comment: "") }
}
public protocol I_blockchain_ux_onboarding_intro_event: I {}
public extension I_blockchain_ux_onboarding_intro_event {
	var `show`: L_blockchain_ux_onboarding_intro_event_show { .init("\(__).show") }
}
public final class L_blockchain_ux_onboarding_intro_event_show: L, I_blockchain_ux_onboarding_intro_event_show {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.intro.event.show", comment: "") }
}
public protocol I_blockchain_ux_onboarding_intro_event_show: I {}
public extension I_blockchain_ux_onboarding_intro_event_show {
	var `sign`: L_blockchain_ux_onboarding_intro_event_show_sign { .init("\(__).sign") }
	var `tutorial`: L_blockchain_ux_onboarding_intro_event_show_tutorial { .init("\(__).tutorial") }
}
public final class L_blockchain_ux_onboarding_intro_event_show_sign: L, I_blockchain_ux_onboarding_intro_event_show_sign {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.intro.event.show.sign", comment: "") }
}
public protocol I_blockchain_ux_onboarding_intro_event_show_sign: I {}
public extension I_blockchain_ux_onboarding_intro_event_show_sign {
	var `in`: L_blockchain_ux_onboarding_intro_event_show_sign_in { .init("\(__).in") }
	var `up`: L_blockchain_ux_onboarding_intro_event_show_sign_up { .init("\(__).up") }
}
public final class L_blockchain_ux_onboarding_intro_event_show_sign_in: L, I_blockchain_ux_onboarding_intro_event_show_sign_in {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.intro.event.show.sign.in", comment: "") }
}
public protocol I_blockchain_ux_onboarding_intro_event_show_sign_in: I {}
public final class L_blockchain_ux_onboarding_intro_event_show_sign_up: L, I_blockchain_ux_onboarding_intro_event_show_sign_up {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.intro.event.show.sign.up", comment: "") }
}
public protocol I_blockchain_ux_onboarding_intro_event_show_sign_up: I {}
public final class L_blockchain_ux_onboarding_intro_event_show_tutorial: L, I_blockchain_ux_onboarding_intro_event_show_tutorial {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.intro.event.show.tutorial", comment: "") }
}
public protocol I_blockchain_ux_onboarding_intro_event_show_tutorial: I {}
public extension I_blockchain_ux_onboarding_intro_event_show_tutorial {
	var `defi`: L_blockchain_ux_onboarding_intro_event_show_tutorial_defi { .init("\(__).defi") }
	var `trading`: L_blockchain_ux_onboarding_intro_event_show_tutorial_trading { .init("\(__).trading") }
}
public final class L_blockchain_ux_onboarding_intro_event_show_tutorial_defi: L, I_blockchain_ux_onboarding_intro_event_show_tutorial_defi {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.intro.event.show.tutorial.defi", comment: "") }
}
public protocol I_blockchain_ux_onboarding_intro_event_show_tutorial_defi: I {}
public final class L_blockchain_ux_onboarding_intro_event_show_tutorial_trading: L, I_blockchain_ux_onboarding_intro_event_show_tutorial_trading {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.intro.event.show.tutorial.trading", comment: "") }
}
public protocol I_blockchain_ux_onboarding_intro_event_show_tutorial_trading: I {}
public final class L_blockchain_ux_onboarding_promotion: L, I_blockchain_ux_onboarding_promotion {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion: I {}
public extension I_blockchain_ux_onboarding_promotion {
	var `cowboys`: L_blockchain_ux_onboarding_promotion_cowboys { .init("\(__).cowboys") }
	var `launch`: L_blockchain_ux_onboarding_promotion_launch { .init("\(__).launch") }
	var `product`: L_blockchain_ux_onboarding_promotion_product { .init("\(__).product") }
}
public final class L_blockchain_ux_onboarding_promotion_cowboys: L, I_blockchain_ux_onboarding_promotion_cowboys {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.cowboys", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_cowboys: I {}
public extension I_blockchain_ux_onboarding_promotion_cowboys {
	var `announcements`: L_blockchain_ux_onboarding_promotion_cowboys_announcements { .init("\(__).announcements") }
	var `is`: L_blockchain_ux_onboarding_promotion_cowboys_is { .init("\(__).is") }
	var `raffle`: L_blockchain_ux_onboarding_promotion_cowboys_raffle { .init("\(__).raffle") }
	var `refer`: L_blockchain_ux_onboarding_promotion_cowboys_refer { .init("\(__).refer") }
	var `user`: L_blockchain_ux_onboarding_promotion_cowboys_user { .init("\(__).user") }
	var `verify`: L_blockchain_ux_onboarding_promotion_cowboys_verify { .init("\(__).verify") }
	var `welcome`: L_blockchain_ux_onboarding_promotion_cowboys_welcome { .init("\(__).welcome") }
}
public final class L_blockchain_ux_onboarding_promotion_cowboys_announcements: L, I_blockchain_ux_onboarding_promotion_cowboys_announcements {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.cowboys.announcements", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_cowboys_announcements: I {}
public extension I_blockchain_ux_onboarding_promotion_cowboys_announcements {
	var `is`: L_blockchain_ux_onboarding_promotion_cowboys_announcements_is { .init("\(__).is") }
}
public final class L_blockchain_ux_onboarding_promotion_cowboys_announcements_is: L, I_blockchain_ux_onboarding_promotion_cowboys_announcements_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.cowboys.announcements.is", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_cowboys_announcements_is: I {}
public extension I_blockchain_ux_onboarding_promotion_cowboys_announcements_is {
	var `enabled`: L_blockchain_ux_onboarding_promotion_cowboys_announcements_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_ux_onboarding_promotion_cowboys_announcements_is_enabled: L, I_blockchain_ux_onboarding_promotion_cowboys_announcements_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.cowboys.announcements.is.enabled", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_cowboys_announcements_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_onboarding_promotion_cowboys_is: L, I_blockchain_ux_onboarding_promotion_cowboys_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.cowboys.is", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_cowboys_is: I {}
public extension I_blockchain_ux_onboarding_promotion_cowboys_is {
	var `enabled`: L_blockchain_ux_onboarding_promotion_cowboys_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_ux_onboarding_promotion_cowboys_is_enabled: L, I_blockchain_ux_onboarding_promotion_cowboys_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.cowboys.is.enabled", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_cowboys_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_onboarding_promotion_cowboys_raffle: L, I_blockchain_ux_onboarding_promotion_cowboys_raffle {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.cowboys.raffle", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_cowboys_raffle: I_blockchain_ux_onboarding_type_promotion {}
public final class L_blockchain_ux_onboarding_promotion_cowboys_refer: L, I_blockchain_ux_onboarding_promotion_cowboys_refer {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.cowboys.refer", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_cowboys_refer: I {}
public extension I_blockchain_ux_onboarding_promotion_cowboys_refer {
	var `friends`: L_blockchain_ux_onboarding_promotion_cowboys_refer_friends { .init("\(__).friends") }
}
public final class L_blockchain_ux_onboarding_promotion_cowboys_refer_friends: L, I_blockchain_ux_onboarding_promotion_cowboys_refer_friends {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.cowboys.refer.friends", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_cowboys_refer_friends: I_blockchain_ux_onboarding_type_promotion {}
public final class L_blockchain_ux_onboarding_promotion_cowboys_user: L, I_blockchain_ux_onboarding_promotion_cowboys_user {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.cowboys.user", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_cowboys_user: I {}
public extension I_blockchain_ux_onboarding_promotion_cowboys_user {
	var `kyc`: L_blockchain_ux_onboarding_promotion_cowboys_user_kyc { .init("\(__).kyc") }
}
public final class L_blockchain_ux_onboarding_promotion_cowboys_user_kyc: L, I_blockchain_ux_onboarding_promotion_cowboys_user_kyc {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.cowboys.user.kyc", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_cowboys_user_kyc: I {}
public extension I_blockchain_ux_onboarding_promotion_cowboys_user_kyc {
	var `is`: L_blockchain_ux_onboarding_promotion_cowboys_user_kyc_is { .init("\(__).is") }
}
public final class L_blockchain_ux_onboarding_promotion_cowboys_user_kyc_is: L, I_blockchain_ux_onboarding_promotion_cowboys_user_kyc_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.cowboys.user.kyc.is", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_cowboys_user_kyc_is: I {}
public extension I_blockchain_ux_onboarding_promotion_cowboys_user_kyc_is {
	var `under`: L_blockchain_ux_onboarding_promotion_cowboys_user_kyc_is_under { .init("\(__).under") }
}
public final class L_blockchain_ux_onboarding_promotion_cowboys_user_kyc_is_under: L, I_blockchain_ux_onboarding_promotion_cowboys_user_kyc_is_under {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.cowboys.user.kyc.is.under", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_cowboys_user_kyc_is_under: I {}
public extension I_blockchain_ux_onboarding_promotion_cowboys_user_kyc_is_under {
	var `review`: L_blockchain_ux_onboarding_promotion_cowboys_user_kyc_is_under_review { .init("\(__).review") }
}
public final class L_blockchain_ux_onboarding_promotion_cowboys_user_kyc_is_under_review: L, I_blockchain_ux_onboarding_promotion_cowboys_user_kyc_is_under_review {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.cowboys.user.kyc.is.under.review", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_cowboys_user_kyc_is_under_review: I_blockchain_ux_onboarding_type_promotion {}
public final class L_blockchain_ux_onboarding_promotion_cowboys_verify: L, I_blockchain_ux_onboarding_promotion_cowboys_verify {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.cowboys.verify", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_cowboys_verify: I {}
public extension I_blockchain_ux_onboarding_promotion_cowboys_verify {
	var `identity`: L_blockchain_ux_onboarding_promotion_cowboys_verify_identity { .init("\(__).identity") }
}
public final class L_blockchain_ux_onboarding_promotion_cowboys_verify_identity: L, I_blockchain_ux_onboarding_promotion_cowboys_verify_identity {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.cowboys.verify.identity", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_cowboys_verify_identity: I_blockchain_ux_onboarding_type_promotion {}
public final class L_blockchain_ux_onboarding_promotion_cowboys_welcome: L, I_blockchain_ux_onboarding_promotion_cowboys_welcome {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.cowboys.welcome", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_cowboys_welcome: I_blockchain_ux_onboarding_type_promotion {}
public final class L_blockchain_ux_onboarding_promotion_launch: L, I_blockchain_ux_onboarding_promotion_launch {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.launch", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_launch: I_blockchain_ux_type_analytics_event {}
public extension I_blockchain_ux_onboarding_promotion_launch {
	var `story`: L_blockchain_ux_onboarding_promotion_launch_story { .init("\(__).story") }
}
public final class L_blockchain_ux_onboarding_promotion_launch_story: L, I_blockchain_ux_onboarding_promotion_launch_story {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.launch.story", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_launch_story: I_blockchain_db_type_tag, I_blockchain_session_state_value {}
public final class L_blockchain_ux_onboarding_promotion_product: L, I_blockchain_ux_onboarding_promotion_product {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.promotion.product", comment: "") }
}
public protocol I_blockchain_ux_onboarding_promotion_product: I_blockchain_ux_onboarding_type_promotion, I_blockchain_db_collection {}
public final class L_blockchain_ux_onboarding_type: L, I_blockchain_ux_onboarding_type {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.type", comment: "") }
}
public protocol I_blockchain_ux_onboarding_type: I {}
public extension I_blockchain_ux_onboarding_type {
	var `promotion`: L_blockchain_ux_onboarding_type_promotion { .init("\(__).promotion") }
}
public final class L_blockchain_ux_onboarding_type_promotion: L, I_blockchain_ux_onboarding_type_promotion {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.type.promotion", comment: "") }
}
public protocol I_blockchain_ux_onboarding_type_promotion: I {}
public extension I_blockchain_ux_onboarding_type_promotion {
	var `announcement`: L_blockchain_ux_onboarding_type_promotion_announcement { .init("\(__).announcement") }
	var `story`: L_blockchain_ux_onboarding_type_promotion_story { .init("\(__).story") }
}
public final class L_blockchain_ux_onboarding_type_promotion_announcement: L, I_blockchain_ux_onboarding_type_promotion_announcement {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.type.promotion.announcement", comment: "") }
}
public protocol I_blockchain_ux_onboarding_type_promotion_announcement: I_blockchain_ux_type_story, I_blockchain_session_configuration_value {}
public extension I_blockchain_ux_onboarding_type_promotion_announcement {
	var `action`: L_blockchain_ux_onboarding_type_promotion_announcement_action { .init("\(__).action") }
}
public final class L_blockchain_ux_onboarding_type_promotion_announcement_action: L, I_blockchain_ux_onboarding_type_promotion_announcement_action {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.type.promotion.announcement.action", comment: "") }
}
public protocol I_blockchain_ux_onboarding_type_promotion_announcement_action: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_onboarding_type_promotion_story: L, I_blockchain_ux_onboarding_type_promotion_story {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.type.promotion.story", comment: "") }
}
public protocol I_blockchain_ux_onboarding_type_promotion_story: I_blockchain_ux_type_story, I_blockchain_session_configuration_value {}
public extension I_blockchain_ux_onboarding_type_promotion_story {
	var `action`: L_blockchain_ux_onboarding_type_promotion_story_action { .init("\(__).action") }
}
public final class L_blockchain_ux_onboarding_type_promotion_story_action: L, I_blockchain_ux_onboarding_type_promotion_story_action {
	public override class var localized: String { NSLocalizedString("blockchain.ux.onboarding.type.promotion.story.action", comment: "") }
}
public protocol I_blockchain_ux_onboarding_type_promotion_story_action: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_payment: L, I_blockchain_ux_payment {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment", comment: "") }
}
public protocol I_blockchain_ux_payment: I {}
public extension I_blockchain_ux_payment {
	var `method`: L_blockchain_ux_payment_method { .init("\(__).method") }
}
public final class L_blockchain_ux_payment_method: L, I_blockchain_ux_payment_method {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method", comment: "") }
}
public protocol I_blockchain_ux_payment_method: I {}
public extension I_blockchain_ux_payment_method {
	var `link`: L_blockchain_ux_payment_method_link { .init("\(__).link") }
	var `open`: L_blockchain_ux_payment_method_open { .init("\(__).open") }
	var `plaid`: L_blockchain_ux_payment_method_plaid { .init("\(__).plaid") }
}
public final class L_blockchain_ux_payment_method_link: L, I_blockchain_ux_payment_method_link {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.link", comment: "") }
}
public protocol I_blockchain_ux_payment_method_link: I {}
public extension I_blockchain_ux_payment_method_link {
	var `bank`: L_blockchain_ux_payment_method_link_bank { .init("\(__).bank") }
	var `card`: L_blockchain_ux_payment_method_link_card { .init("\(__).card") }
}
public final class L_blockchain_ux_payment_method_link_bank: L, I_blockchain_ux_payment_method_link_bank {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.link.bank", comment: "") }
}
public protocol I_blockchain_ux_payment_method_link_bank: I {}
public extension I_blockchain_ux_payment_method_link_bank {
	var `wire`: L_blockchain_ux_payment_method_link_bank_wire { .init("\(__).wire") }
}
public final class L_blockchain_ux_payment_method_link_bank_wire: L, I_blockchain_ux_payment_method_link_bank_wire {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.link.bank.wire", comment: "") }
}
public protocol I_blockchain_ux_payment_method_link_bank_wire: I {}
public final class L_blockchain_ux_payment_method_link_card: L, I_blockchain_ux_payment_method_link_card {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.link.card", comment: "") }
}
public protocol I_blockchain_ux_payment_method_link_card: I {}
public final class L_blockchain_ux_payment_method_open: L, I_blockchain_ux_payment_method_open {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open: I {}
public extension I_blockchain_ux_payment_method_open {
	var `banking`: L_blockchain_ux_payment_method_open_banking { .init("\(__).banking") }
}
public final class L_blockchain_ux_payment_method_open_banking: L, I_blockchain_ux_payment_method_open_banking {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking: I {}
public extension I_blockchain_ux_payment_method_open_banking {
	var `account`: L_blockchain_ux_payment_method_open_banking_account { .init("\(__).account") }
	var `authorisation`: L_blockchain_ux_payment_method_open_banking_authorisation { .init("\(__).authorisation") }
	var `callback`: L_blockchain_ux_payment_method_open_banking_callback { .init("\(__).callback") }
	var `consent`: L_blockchain_ux_payment_method_open_banking_consent { .init("\(__).consent") }
	var `currency`: L_blockchain_ux_payment_method_open_banking_currency { .init("\(__).currency") }
	var `error`: L_blockchain_ux_payment_method_open_banking_error { .init("\(__).error") }
	var `is`: L_blockchain_ux_payment_method_open_banking_is { .init("\(__).is") }
}
public final class L_blockchain_ux_payment_method_open_banking_account: L, I_blockchain_ux_payment_method_open_banking_account {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.account", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_account: I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_open_banking_authorisation: L, I_blockchain_ux_payment_method_open_banking_authorisation {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.authorisation", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_authorisation: I {}
public extension I_blockchain_ux_payment_method_open_banking_authorisation {
	var `url`: L_blockchain_ux_payment_method_open_banking_authorisation_url { .init("\(__).url") }
}
public final class L_blockchain_ux_payment_method_open_banking_authorisation_url: L, I_blockchain_ux_payment_method_open_banking_authorisation_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.authorisation.url", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_authorisation_url: I_blockchain_db_type_url, I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_open_banking_callback: L, I_blockchain_ux_payment_method_open_banking_callback {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.callback", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_callback: I {}
public extension I_blockchain_ux_payment_method_open_banking_callback {
	var `base`: L_blockchain_ux_payment_method_open_banking_callback_base { .init("\(__).base") }
	var `path`: L_blockchain_ux_payment_method_open_banking_callback_path { .init("\(__).path") }
}
public final class L_blockchain_ux_payment_method_open_banking_callback_base: L, I_blockchain_ux_payment_method_open_banking_callback_base {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.callback.base", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_callback_base: I {}
public extension I_blockchain_ux_payment_method_open_banking_callback_base {
	var `url`: L_blockchain_ux_payment_method_open_banking_callback_base_url { .init("\(__).url") }
}
public final class L_blockchain_ux_payment_method_open_banking_callback_base_url: L, I_blockchain_ux_payment_method_open_banking_callback_base_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.callback.base.url", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_callback_base_url: I_blockchain_db_type_url, I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_open_banking_callback_path: L, I_blockchain_ux_payment_method_open_banking_callback_path {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.callback.path", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_callback_path: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_open_banking_consent: L, I_blockchain_ux_payment_method_open_banking_consent {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.consent", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_consent: I {}
public extension I_blockchain_ux_payment_method_open_banking_consent {
	var `error`: L_blockchain_ux_payment_method_open_banking_consent_error { .init("\(__).error") }
	var `token`: L_blockchain_ux_payment_method_open_banking_consent_token { .init("\(__).token") }
}
public final class L_blockchain_ux_payment_method_open_banking_consent_error: L, I_blockchain_ux_payment_method_open_banking_consent_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.consent.error", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_consent_error: I_blockchain_ux_type_analytics_error, I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_open_banking_consent_token: L, I_blockchain_ux_payment_method_open_banking_consent_token {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.consent.token", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_consent_token: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_open_banking_currency: L, I_blockchain_ux_payment_method_open_banking_currency {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.currency", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_currency: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_open_banking_error: L, I_blockchain_ux_payment_method_open_banking_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.error", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_error: I {}
public extension I_blockchain_ux_payment_method_open_banking_error {
	var `code`: L_blockchain_ux_payment_method_open_banking_error_code { .init("\(__).code") }
}
public final class L_blockchain_ux_payment_method_open_banking_error_code: L, I_blockchain_ux_payment_method_open_banking_error_code {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.error.code", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_error_code: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_open_banking_is: L, I_blockchain_ux_payment_method_open_banking_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.is", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_is: I {}
public extension I_blockchain_ux_payment_method_open_banking_is {
	var `authorised`: L_blockchain_ux_payment_method_open_banking_is_authorised { .init("\(__).authorised") }
}
public final class L_blockchain_ux_payment_method_open_banking_is_authorised: L, I_blockchain_ux_payment_method_open_banking_is_authorised {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.open.banking.is.authorised", comment: "") }
}
public protocol I_blockchain_ux_payment_method_open_banking_is_authorised: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_plaid: L, I_blockchain_ux_payment_method_plaid {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid: I {}
public extension I_blockchain_ux_payment_method_plaid {
	var `event`: L_blockchain_ux_payment_method_plaid_event { .init("\(__).event") }
	var `is`: L_blockchain_ux_payment_method_plaid_is { .init("\(__).is") }
}
public final class L_blockchain_ux_payment_method_plaid_event: L, I_blockchain_ux_payment_method_plaid_event {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.event", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_event: I {}
public extension I_blockchain_ux_payment_method_plaid_event {
	var `finished`: L_blockchain_ux_payment_method_plaid_event_finished { .init("\(__).finished") }
	var `receive`: L_blockchain_ux_payment_method_plaid_event_receive { .init("\(__).receive") }
	var `reload`: L_blockchain_ux_payment_method_plaid_event_reload { .init("\(__).reload") }
	var `update`: L_blockchain_ux_payment_method_plaid_event_update { .init("\(__).update") }
}
public final class L_blockchain_ux_payment_method_plaid_event_finished: L, I_blockchain_ux_payment_method_plaid_event_finished {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.event.finished", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_event_finished: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_payment_method_plaid_event_receive: L, I_blockchain_ux_payment_method_plaid_event_receive {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.event.receive", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_event_receive: I {}
public extension I_blockchain_ux_payment_method_plaid_event_receive {
	var `link`: L_blockchain_ux_payment_method_plaid_event_receive_link { .init("\(__).link") }
	var `OAuth`: L_blockchain_ux_payment_method_plaid_event_receive_OAuth { .init("\(__).OAuth") }
	var `success`: L_blockchain_ux_payment_method_plaid_event_receive_success { .init("\(__).success") }
}
public final class L_blockchain_ux_payment_method_plaid_event_receive_link: L, I_blockchain_ux_payment_method_plaid_event_receive_link {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.event.receive.link", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_event_receive_link: I {}
public extension I_blockchain_ux_payment_method_plaid_event_receive_link {
	var `token`: L_blockchain_ux_payment_method_plaid_event_receive_link_token { .init("\(__).token") }
}
public final class L_blockchain_ux_payment_method_plaid_event_receive_link_token: L, I_blockchain_ux_payment_method_plaid_event_receive_link_token {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.event.receive.link.token", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_event_receive_link_token: I_blockchain_db_type_string {}
public final class L_blockchain_ux_payment_method_plaid_event_receive_OAuth: L, I_blockchain_ux_payment_method_plaid_event_receive_OAuth {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.event.receive.OAuth", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_event_receive_OAuth: I {}
public extension I_blockchain_ux_payment_method_plaid_event_receive_OAuth {
	var `token`: L_blockchain_ux_payment_method_plaid_event_receive_OAuth_token { .init("\(__).token") }
}
public final class L_blockchain_ux_payment_method_plaid_event_receive_OAuth_token: L, I_blockchain_ux_payment_method_plaid_event_receive_OAuth_token {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.event.receive.OAuth.token", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_event_receive_OAuth_token: I_blockchain_db_type_string {}
public final class L_blockchain_ux_payment_method_plaid_event_receive_success: L, I_blockchain_ux_payment_method_plaid_event_receive_success {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.event.receive.success", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_event_receive_success: I {}
public extension I_blockchain_ux_payment_method_plaid_event_receive_success {
	var `id`: L_blockchain_ux_payment_method_plaid_event_receive_success_id { .init("\(__).id") }
	var `token`: L_blockchain_ux_payment_method_plaid_event_receive_success_token { .init("\(__).token") }
}
public final class L_blockchain_ux_payment_method_plaid_event_receive_success_id: L, I_blockchain_ux_payment_method_plaid_event_receive_success_id {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.event.receive.success.id", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_event_receive_success_id: I_blockchain_db_type_string {}
public final class L_blockchain_ux_payment_method_plaid_event_receive_success_token: L, I_blockchain_ux_payment_method_plaid_event_receive_success_token {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.event.receive.success.token", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_event_receive_success_token: I_blockchain_db_type_string {}
public final class L_blockchain_ux_payment_method_plaid_event_reload: L, I_blockchain_ux_payment_method_plaid_event_reload {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.event.reload", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_event_reload: I {}
public extension I_blockchain_ux_payment_method_plaid_event_reload {
	var `linked_banks`: L_blockchain_ux_payment_method_plaid_event_reload_linked__banks { .init("\(__).linked_banks") }
}
public final class L_blockchain_ux_payment_method_plaid_event_reload_linked__banks: L, I_blockchain_ux_payment_method_plaid_event_reload_linked__banks {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.event.reload.linked_banks", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_event_reload_linked__banks: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_payment_method_plaid_event_update: L, I_blockchain_ux_payment_method_plaid_event_update {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.event.update", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_event_update: I {}
public extension I_blockchain_ux_payment_method_plaid_event_update {
	var `account_id`: L_blockchain_ux_payment_method_plaid_event_update_account__id { .init("\(__).account_id") }
}
public final class L_blockchain_ux_payment_method_plaid_event_update_account__id: L, I_blockchain_ux_payment_method_plaid_event_update_account__id {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.event.update.account_id", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_event_update_account__id: I_blockchain_db_type_string {}
public final class L_blockchain_ux_payment_method_plaid_is: L, I_blockchain_ux_payment_method_plaid_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.is", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_is: I {}
public extension I_blockchain_ux_payment_method_plaid_is {
	var `available`: L_blockchain_ux_payment_method_plaid_is_available { .init("\(__).available") }
	var `enabled`: L_blockchain_ux_payment_method_plaid_is_enabled { .init("\(__).enabled") }
	var `linking`: L_blockchain_ux_payment_method_plaid_is_linking { .init("\(__).linking") }
}
public final class L_blockchain_ux_payment_method_plaid_is_available: L, I_blockchain_ux_payment_method_plaid_is_available {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.is.available", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_is_available: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_payment_method_plaid_is_enabled: L, I_blockchain_ux_payment_method_plaid_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.is.enabled", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_payment_method_plaid_is_linking: L, I_blockchain_ux_payment_method_plaid_is_linking {
	public override class var localized: String { NSLocalizedString("blockchain.ux.payment.method.plaid.is.linking", comment: "") }
}
public protocol I_blockchain_ux_payment_method_plaid_is_linking: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_pin: L, I_blockchain_ux_pin {
	public override class var localized: String { NSLocalizedString("blockchain.ux.pin", comment: "") }
}
public protocol I_blockchain_ux_pin: I {}
public extension I_blockchain_ux_pin {
	var `is`: L_blockchain_ux_pin_is { .init("\(__).is") }
}
public final class L_blockchain_ux_pin_is: L, I_blockchain_ux_pin_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.pin.is", comment: "") }
}
public protocol I_blockchain_ux_pin_is: I {}
public extension I_blockchain_ux_pin_is {
	var `disabled`: L_blockchain_ux_pin_is_disabled { .init("\(__).disabled") }
}
public final class L_blockchain_ux_pin_is_disabled: L, I_blockchain_ux_pin_is_disabled {
	public override class var localized: String { NSLocalizedString("blockchain.ux.pin.is.disabled", comment: "") }
}
public protocol I_blockchain_ux_pin_is_disabled: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_prices: L, I_blockchain_ux_prices {
	public override class var localized: String { NSLocalizedString("blockchain.ux.prices", comment: "") }
}
public protocol I_blockchain_ux_prices: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_referral: L, I_blockchain_ux_referral {
	public override class var localized: String { NSLocalizedString("blockchain.ux.referral", comment: "") }
}
public protocol I_blockchain_ux_referral: I {}
public extension I_blockchain_ux_referral {
	var `entry`: L_blockchain_ux_referral_entry { .init("\(__).entry") }
	var `giftbox`: L_blockchain_ux_referral_giftbox { .init("\(__).giftbox") }
}
public final class L_blockchain_ux_referral_entry: L, I_blockchain_ux_referral_entry {
	public override class var localized: String { NSLocalizedString("blockchain.ux.referral.entry", comment: "") }
}
public protocol I_blockchain_ux_referral_entry: I_blockchain_ux_type_story_entry {}
public final class L_blockchain_ux_referral_giftbox: L, I_blockchain_ux_referral_giftbox {
	public override class var localized: String { NSLocalizedString("blockchain.ux.referral.giftbox", comment: "") }
}
public protocol I_blockchain_ux_referral_giftbox: I {}
public extension I_blockchain_ux_referral_giftbox {
	var `seen`: L_blockchain_ux_referral_giftbox_seen { .init("\(__).seen") }
}
public final class L_blockchain_ux_referral_giftbox_seen: L, I_blockchain_ux_referral_giftbox_seen {
	public override class var localized: String { NSLocalizedString("blockchain.ux.referral.giftbox.seen", comment: "") }
}
public protocol I_blockchain_ux_referral_giftbox_seen: I_blockchain_db_type_boolean, I_blockchain_session_state_preference_value {}
public final class L_blockchain_ux_scan: L, I_blockchain_ux_scan {
	public override class var localized: String { NSLocalizedString("blockchain.ux.scan", comment: "") }
}
public protocol I_blockchain_ux_scan: I {}
public extension I_blockchain_ux_scan {
	var `QR`: L_blockchain_ux_scan_QR { .init("\(__).QR") }
}
public final class L_blockchain_ux_scan_QR: L, I_blockchain_ux_scan_QR {
	public override class var localized: String { NSLocalizedString("blockchain.ux.scan.QR", comment: "") }
}
public protocol I_blockchain_ux_scan_QR: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_switcher: L, I_blockchain_ux_switcher {
	public override class var localized: String { NSLocalizedString("blockchain.ux.switcher", comment: "") }
}
public protocol I_blockchain_ux_switcher: I {}
public extension I_blockchain_ux_switcher {
	var `entry`: L_blockchain_ux_switcher_entry { .init("\(__).entry") }
}
public final class L_blockchain_ux_switcher_entry: L, I_blockchain_ux_switcher_entry {
	public override class var localized: String { NSLocalizedString("blockchain.ux.switcher.entry", comment: "") }
}
public protocol I_blockchain_ux_switcher_entry: I_blockchain_ux_type_story_entry {}
public final class L_blockchain_ux_transaction: L, I_blockchain_ux_transaction {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction", comment: "") }
}
public protocol I_blockchain_ux_transaction: I_blockchain_db_collection {}
public extension I_blockchain_ux_transaction {
	var `action`: L_blockchain_ux_transaction_action { .init("\(__).action") }
	var `checkout`: L_blockchain_ux_transaction_checkout { .init("\(__).checkout") }
	var `configuration`: L_blockchain_ux_transaction_configuration { .init("\(__).configuration") }
	var `details`: L_blockchain_ux_transaction_details { .init("\(__).details") }
	var `disclaimer`: L_blockchain_ux_transaction_disclaimer { .init("\(__).disclaimer") }
	var `enter`: L_blockchain_ux_transaction_enter { .init("\(__).enter") }
	var `event`: L_blockchain_ux_transaction_event { .init("\(__).event") }
	var `loading`: L_blockchain_ux_transaction_loading { .init("\(__).loading") }
	var `payment`: L_blockchain_ux_transaction_payment { .init("\(__).payment") }
	var `previous`: L_blockchain_ux_transaction_previous { .init("\(__).previous") }
	var `smart`: L_blockchain_ux_transaction_smart { .init("\(__).smart") }
	var `source`: L_blockchain_ux_transaction_source { .init("\(__).source") }
}
public final class L_blockchain_ux_transaction_action: L, I_blockchain_ux_transaction_action {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action", comment: "") }
}
public protocol I_blockchain_ux_transaction_action: I {}
public extension I_blockchain_ux_transaction_action {
	var `add`: L_blockchain_ux_transaction_action_add { .init("\(__).add") }
	var `change`: L_blockchain_ux_transaction_action_change { .init("\(__).change") }
	var `go`: L_blockchain_ux_transaction_action_go { .init("\(__).go") }
	var `reset`: L_blockchain_ux_transaction_action_reset { .init("\(__).reset") }
	var `select`: L_blockchain_ux_transaction_action_select { .init("\(__).select") }
	var `show`: L_blockchain_ux_transaction_action_show { .init("\(__).show") }
}
public final class L_blockchain_ux_transaction_action_add: L, I_blockchain_ux_transaction_action_add {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.add", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_add: I {}
public extension I_blockchain_ux_transaction_action_add {
	var `account`: L_blockchain_ux_transaction_action_add_account { .init("\(__).account") }
	var `bank`: L_blockchain_ux_transaction_action_add_bank { .init("\(__).bank") }
	var `card`: L_blockchain_ux_transaction_action_add_card { .init("\(__).card") }
}
public final class L_blockchain_ux_transaction_action_add_account: L, I_blockchain_ux_transaction_action_add_account {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.add.account", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_add_account: I {}
public final class L_blockchain_ux_transaction_action_add_bank: L, I_blockchain_ux_transaction_action_add_bank {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.add.bank", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_add_bank: I {}
public final class L_blockchain_ux_transaction_action_add_card: L, I_blockchain_ux_transaction_action_add_card {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.add.card", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_add_card: I {}
public final class L_blockchain_ux_transaction_action_change: L, I_blockchain_ux_transaction_action_change {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.change", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_change: I {}
public extension I_blockchain_ux_transaction_action_change {
	var `payment`: L_blockchain_ux_transaction_action_change_payment { .init("\(__).payment") }
}
public final class L_blockchain_ux_transaction_action_change_payment: L, I_blockchain_ux_transaction_action_change_payment {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.change.payment", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_change_payment: I {}
public extension I_blockchain_ux_transaction_action_change_payment {
	var `method`: L_blockchain_ux_transaction_action_change_payment_method { .init("\(__).method") }
}
public final class L_blockchain_ux_transaction_action_change_payment_method: L, I_blockchain_ux_transaction_action_change_payment_method {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.change.payment.method", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_change_payment_method: I {}
public final class L_blockchain_ux_transaction_action_go: L, I_blockchain_ux_transaction_action_go {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.go", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_go: I {}
public extension I_blockchain_ux_transaction_action_go {
	var `back`: L_blockchain_ux_transaction_action_go_back { .init("\(__).back") }
}
public final class L_blockchain_ux_transaction_action_go_back: L, I_blockchain_ux_transaction_action_go_back {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.go.back", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_go_back: I {}
public extension I_blockchain_ux_transaction_action_go_back {
	var `to`: L_blockchain_ux_transaction_action_go_back_to { .init("\(__).to") }
}
public final class L_blockchain_ux_transaction_action_go_back_to: L, I_blockchain_ux_transaction_action_go_back_to {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.go.back.to", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_go_back_to: I {}
public extension I_blockchain_ux_transaction_action_go_back_to {
	var `enter`: L_blockchain_ux_transaction_action_go_back_to_enter { .init("\(__).enter") }
}
public final class L_blockchain_ux_transaction_action_go_back_to_enter: L, I_blockchain_ux_transaction_action_go_back_to_enter {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.go.back.to.enter", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_go_back_to_enter: I {}
public extension I_blockchain_ux_transaction_action_go_back_to_enter {
	var `amount`: L_blockchain_ux_transaction_action_go_back_to_enter_amount { .init("\(__).amount") }
}
public final class L_blockchain_ux_transaction_action_go_back_to_enter_amount: L, I_blockchain_ux_transaction_action_go_back_to_enter_amount {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.go.back.to.enter.amount", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_go_back_to_enter_amount: I {}
public final class L_blockchain_ux_transaction_action_reset: L, I_blockchain_ux_transaction_action_reset {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.reset", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_reset: I {}
public final class L_blockchain_ux_transaction_action_select: L, I_blockchain_ux_transaction_action_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.select", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_select: I {}
public extension I_blockchain_ux_transaction_action_select {
	var `payment`: L_blockchain_ux_transaction_action_select_payment { .init("\(__).payment") }
	var `recurring`: L_blockchain_ux_transaction_action_select_recurring { .init("\(__).recurring") }
}
public final class L_blockchain_ux_transaction_action_select_payment: L, I_blockchain_ux_transaction_action_select_payment {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.select.payment", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_select_payment: I {}
public extension I_blockchain_ux_transaction_action_select_payment {
	var `method`: L_blockchain_ux_transaction_action_select_payment_method { .init("\(__).method") }
}
public final class L_blockchain_ux_transaction_action_select_payment_method: L, I_blockchain_ux_transaction_action_select_payment_method {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.select.payment.method", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_select_payment_method: I_blockchain_ux_type_action {}
public extension I_blockchain_ux_transaction_action_select_payment_method {
	var `id`: L_blockchain_ux_transaction_action_select_payment_method_id { .init("\(__).id") }
}
public final class L_blockchain_ux_transaction_action_select_payment_method_id: L, I_blockchain_ux_transaction_action_select_payment_method_id {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.select.payment.method.id", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_select_payment_method_id: I_blockchain_db_type_string {}
public final class L_blockchain_ux_transaction_action_select_recurring: L, I_blockchain_ux_transaction_action_select_recurring {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.select.recurring", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_select_recurring: I {}
public extension I_blockchain_ux_transaction_action_select_recurring {
	var `buy`: L_blockchain_ux_transaction_action_select_recurring_buy { .init("\(__).buy") }
}
public final class L_blockchain_ux_transaction_action_select_recurring_buy: L, I_blockchain_ux_transaction_action_select_recurring_buy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.select.recurring.buy", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_select_recurring_buy: I {}
public extension I_blockchain_ux_transaction_action_select_recurring_buy {
	var `frequency`: L_blockchain_ux_transaction_action_select_recurring_buy_frequency { .init("\(__).frequency") }
}
public final class L_blockchain_ux_transaction_action_select_recurring_buy_frequency: L, I_blockchain_ux_transaction_action_select_recurring_buy_frequency {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.select.recurring.buy.frequency", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_select_recurring_buy_frequency: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public extension I_blockchain_ux_transaction_action_select_recurring_buy_frequency {
	var `localized`: L_blockchain_ux_transaction_action_select_recurring_buy_frequency_localized { .init("\(__).localized") }
}
public final class L_blockchain_ux_transaction_action_select_recurring_buy_frequency_localized: L, I_blockchain_ux_transaction_action_select_recurring_buy_frequency_localized {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.select.recurring.buy.frequency.localized", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_select_recurring_buy_frequency_localized: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_action_show: L, I_blockchain_ux_transaction_action_show {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.show", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_show: I {}
public extension I_blockchain_ux_transaction_action_show {
	var `recurring`: L_blockchain_ux_transaction_action_show_recurring { .init("\(__).recurring") }
	var `wire`: L_blockchain_ux_transaction_action_show_wire { .init("\(__).wire") }
}
public final class L_blockchain_ux_transaction_action_show_recurring: L, I_blockchain_ux_transaction_action_show_recurring {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.show.recurring", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_show_recurring: I {}
public extension I_blockchain_ux_transaction_action_show_recurring {
	var `buy`: L_blockchain_ux_transaction_action_show_recurring_buy { .init("\(__).buy") }
}
public final class L_blockchain_ux_transaction_action_show_recurring_buy: L, I_blockchain_ux_transaction_action_show_recurring_buy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.show.recurring.buy", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_show_recurring_buy: I {}
public extension I_blockchain_ux_transaction_action_show_recurring_buy {
	var `unavailable`: L_blockchain_ux_transaction_action_show_recurring_buy_unavailable { .init("\(__).unavailable") }
}
public final class L_blockchain_ux_transaction_action_show_recurring_buy_unavailable: L, I_blockchain_ux_transaction_action_show_recurring_buy_unavailable {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.show.recurring.buy.unavailable", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_show_recurring_buy_unavailable: I {}
public final class L_blockchain_ux_transaction_action_show_wire: L, I_blockchain_ux_transaction_action_show_wire {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.show.wire", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_show_wire: I {}
public extension I_blockchain_ux_transaction_action_show_wire {
	var `transfer`: L_blockchain_ux_transaction_action_show_wire_transfer { .init("\(__).transfer") }
}
public final class L_blockchain_ux_transaction_action_show_wire_transfer: L, I_blockchain_ux_transaction_action_show_wire_transfer {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.show.wire.transfer", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_show_wire_transfer: I {}
public extension I_blockchain_ux_transaction_action_show_wire_transfer {
	var `instructions`: L_blockchain_ux_transaction_action_show_wire_transfer_instructions { .init("\(__).instructions") }
}
public final class L_blockchain_ux_transaction_action_show_wire_transfer_instructions: L, I_blockchain_ux_transaction_action_show_wire_transfer_instructions {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.action.show.wire.transfer.instructions", comment: "") }
}
public protocol I_blockchain_ux_transaction_action_show_wire_transfer_instructions: I {}
public final class L_blockchain_ux_transaction_checkout: L, I_blockchain_ux_transaction_checkout {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_transaction_checkout {
	var `confirmed`: L_blockchain_ux_transaction_checkout_confirmed { .init("\(__).confirmed") }
	var `exchange`: L_blockchain_ux_transaction_checkout_exchange { .init("\(__).exchange") }
	var `fee`: L_blockchain_ux_transaction_checkout_fee { .init("\(__).fee") }
	var `is`: L_blockchain_ux_transaction_checkout_is { .init("\(__).is") }
	var `quote`: L_blockchain_ux_transaction_checkout_quote { .init("\(__).quote") }
	var `recurring`: L_blockchain_ux_transaction_checkout_recurring { .init("\(__).recurring") }
	var `refund`: L_blockchain_ux_transaction_checkout_refund { .init("\(__).refund") }
	var `terms`: L_blockchain_ux_transaction_checkout_terms { .init("\(__).terms") }
}
public final class L_blockchain_ux_transaction_checkout_confirmed: L, I_blockchain_ux_transaction_checkout_confirmed {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.confirmed", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_confirmed: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_checkout_exchange: L, I_blockchain_ux_transaction_checkout_exchange {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.exchange", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_exchange: I {}
public extension I_blockchain_ux_transaction_checkout_exchange {
	var `rate`: L_blockchain_ux_transaction_checkout_exchange_rate { .init("\(__).rate") }
}
public final class L_blockchain_ux_transaction_checkout_exchange_rate: L, I_blockchain_ux_transaction_checkout_exchange_rate {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.exchange.rate", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_exchange_rate: I {}
public extension I_blockchain_ux_transaction_checkout_exchange_rate {
	var `disclaimer`: L_blockchain_ux_transaction_checkout_exchange_rate_disclaimer { .init("\(__).disclaimer") }
}
public final class L_blockchain_ux_transaction_checkout_exchange_rate_disclaimer: L, I_blockchain_ux_transaction_checkout_exchange_rate_disclaimer {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.exchange.rate.disclaimer", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_exchange_rate_disclaimer: I_blockchain_ux_type_action {}
public extension I_blockchain_ux_transaction_checkout_exchange_rate_disclaimer {
	var `url`: L_blockchain_ux_transaction_checkout_exchange_rate_disclaimer_url { .init("\(__).url") }
}
public final class L_blockchain_ux_transaction_checkout_exchange_rate_disclaimer_url: L, I_blockchain_ux_transaction_checkout_exchange_rate_disclaimer_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.exchange.rate.disclaimer.url", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_exchange_rate_disclaimer_url: I_blockchain_db_type_url, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_transaction_checkout_fee: L, I_blockchain_ux_transaction_checkout_fee {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.fee", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_fee: I {}
public extension I_blockchain_ux_transaction_checkout_fee {
	var `disclaimer`: L_blockchain_ux_transaction_checkout_fee_disclaimer { .init("\(__).disclaimer") }
}
public final class L_blockchain_ux_transaction_checkout_fee_disclaimer: L, I_blockchain_ux_transaction_checkout_fee_disclaimer {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.fee.disclaimer", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_fee_disclaimer: I_blockchain_ux_type_action {}
public extension I_blockchain_ux_transaction_checkout_fee_disclaimer {
	var `url`: L_blockchain_ux_transaction_checkout_fee_disclaimer_url { .init("\(__).url") }
}
public final class L_blockchain_ux_transaction_checkout_fee_disclaimer_url: L, I_blockchain_ux_transaction_checkout_fee_disclaimer_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.fee.disclaimer.url", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_fee_disclaimer_url: I_blockchain_db_type_url, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_transaction_checkout_is: L, I_blockchain_ux_transaction_checkout_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.is", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_is: I {}
public extension I_blockchain_ux_transaction_checkout_is {
	var `enabled`: L_blockchain_ux_transaction_checkout_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_ux_transaction_checkout_is_enabled: L, I_blockchain_ux_transaction_checkout_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.is.enabled", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_transaction_checkout_quote: L, I_blockchain_ux_transaction_checkout_quote {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.quote", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_quote: I {}
public extension I_blockchain_ux_transaction_checkout_quote {
	var `refresh`: L_blockchain_ux_transaction_checkout_quote_refresh { .init("\(__).refresh") }
}
public final class L_blockchain_ux_transaction_checkout_quote_refresh: L, I_blockchain_ux_transaction_checkout_quote_refresh {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.quote.refresh", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_quote_refresh: I {}
public extension I_blockchain_ux_transaction_checkout_quote_refresh {
	var `is`: L_blockchain_ux_transaction_checkout_quote_refresh_is { .init("\(__).is") }
	var `max`: L_blockchain_ux_transaction_checkout_quote_refresh_max { .init("\(__).max") }
}
public final class L_blockchain_ux_transaction_checkout_quote_refresh_is: L, I_blockchain_ux_transaction_checkout_quote_refresh_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.quote.refresh.is", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_quote_refresh_is: I {}
public extension I_blockchain_ux_transaction_checkout_quote_refresh_is {
	var `enabled`: L_blockchain_ux_transaction_checkout_quote_refresh_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_ux_transaction_checkout_quote_refresh_is_enabled: L, I_blockchain_ux_transaction_checkout_quote_refresh_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.quote.refresh.is.enabled", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_quote_refresh_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_transaction_checkout_quote_refresh_max: L, I_blockchain_ux_transaction_checkout_quote_refresh_max {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.quote.refresh.max", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_quote_refresh_max: I {}
public extension I_blockchain_ux_transaction_checkout_quote_refresh_max {
	var `duration`: L_blockchain_ux_transaction_checkout_quote_refresh_max_duration { .init("\(__).duration") }
}
public final class L_blockchain_ux_transaction_checkout_quote_refresh_max_duration: L, I_blockchain_ux_transaction_checkout_quote_refresh_max_duration {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.quote.refresh.max.duration", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_quote_refresh_max_duration: I_blockchain_db_type_number, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_transaction_checkout_recurring: L, I_blockchain_ux_transaction_checkout_recurring {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.recurring", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_recurring: I {}
public extension I_blockchain_ux_transaction_checkout_recurring {
	var `buy`: L_blockchain_ux_transaction_checkout_recurring_buy { .init("\(__).buy") }
}
public final class L_blockchain_ux_transaction_checkout_recurring_buy: L, I_blockchain_ux_transaction_checkout_recurring_buy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.recurring.buy", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_recurring_buy: I {}
public extension I_blockchain_ux_transaction_checkout_recurring_buy {
	var `frequency`: L_blockchain_ux_transaction_checkout_recurring_buy_frequency { .init("\(__).frequency") }
}
public final class L_blockchain_ux_transaction_checkout_recurring_buy_frequency: L, I_blockchain_ux_transaction_checkout_recurring_buy_frequency {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.recurring.buy.frequency", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_recurring_buy_frequency: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public extension I_blockchain_ux_transaction_checkout_recurring_buy_frequency {
	var `localized`: L_blockchain_ux_transaction_checkout_recurring_buy_frequency_localized { .init("\(__).localized") }
}
public final class L_blockchain_ux_transaction_checkout_recurring_buy_frequency_localized: L, I_blockchain_ux_transaction_checkout_recurring_buy_frequency_localized {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.recurring.buy.frequency.localized", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_recurring_buy_frequency_localized: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_checkout_refund: L, I_blockchain_ux_transaction_checkout_refund {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.refund", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_refund: I {}
public extension I_blockchain_ux_transaction_checkout_refund {
	var `policy`: L_blockchain_ux_transaction_checkout_refund_policy { .init("\(__).policy") }
}
public final class L_blockchain_ux_transaction_checkout_refund_policy: L, I_blockchain_ux_transaction_checkout_refund_policy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.refund.policy", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_refund_policy: I {}
public extension I_blockchain_ux_transaction_checkout_refund_policy {
	var `disclaimer`: L_blockchain_ux_transaction_checkout_refund_policy_disclaimer { .init("\(__).disclaimer") }
}
public final class L_blockchain_ux_transaction_checkout_refund_policy_disclaimer: L, I_blockchain_ux_transaction_checkout_refund_policy_disclaimer {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.refund.policy.disclaimer", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_refund_policy_disclaimer: I_blockchain_ux_type_action {}
public extension I_blockchain_ux_transaction_checkout_refund_policy_disclaimer {
	var `url`: L_blockchain_ux_transaction_checkout_refund_policy_disclaimer_url { .init("\(__).url") }
}
public final class L_blockchain_ux_transaction_checkout_refund_policy_disclaimer_url: L, I_blockchain_ux_transaction_checkout_refund_policy_disclaimer_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.refund.policy.disclaimer.url", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_refund_policy_disclaimer_url: I_blockchain_db_type_url, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_transaction_checkout_terms: L, I_blockchain_ux_transaction_checkout_terms {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.terms", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_terms: I {}
public extension I_blockchain_ux_transaction_checkout_terms {
	var `of`: L_blockchain_ux_transaction_checkout_terms_of { .init("\(__).of") }
}
public final class L_blockchain_ux_transaction_checkout_terms_of: L, I_blockchain_ux_transaction_checkout_terms_of {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.terms.of", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_terms_of: I {}
public extension I_blockchain_ux_transaction_checkout_terms_of {
	var `service`: L_blockchain_ux_transaction_checkout_terms_of_service { .init("\(__).service") }
	var `withdraw`: L_blockchain_ux_transaction_checkout_terms_of_withdraw { .init("\(__).withdraw") }
}
public final class L_blockchain_ux_transaction_checkout_terms_of_service: L, I_blockchain_ux_transaction_checkout_terms_of_service {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.terms.of.service", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_terms_of_service: I_blockchain_ux_type_action {}
public extension I_blockchain_ux_transaction_checkout_terms_of_service {
	var `url`: L_blockchain_ux_transaction_checkout_terms_of_service_url { .init("\(__).url") }
}
public final class L_blockchain_ux_transaction_checkout_terms_of_service_url: L, I_blockchain_ux_transaction_checkout_terms_of_service_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.terms.of.service.url", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_terms_of_service_url: I_blockchain_db_type_url, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_transaction_checkout_terms_of_withdraw: L, I_blockchain_ux_transaction_checkout_terms_of_withdraw {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.checkout.terms.of.withdraw", comment: "") }
}
public protocol I_blockchain_ux_transaction_checkout_terms_of_withdraw: I_blockchain_db_type_url, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_transaction_configuration: L, I_blockchain_ux_transaction_configuration {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration: I {}
public extension I_blockchain_ux_transaction_configuration {
	var `link`: L_blockchain_ux_transaction_configuration_link { .init("\(__).link") }
}
public final class L_blockchain_ux_transaction_configuration_link: L, I_blockchain_ux_transaction_configuration_link {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration.link", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration_link: I {}
public extension I_blockchain_ux_transaction_configuration_link {
	var `a`: L_blockchain_ux_transaction_configuration_link_a { .init("\(__).a") }
}
public final class L_blockchain_ux_transaction_configuration_link_a: L, I_blockchain_ux_transaction_configuration_link_a {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration.link.a", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration_link_a: I {}
public extension I_blockchain_ux_transaction_configuration_link_a {
	var `card`: L_blockchain_ux_transaction_configuration_link_a_card { .init("\(__).card") }
}
public final class L_blockchain_ux_transaction_configuration_link_a_card: L, I_blockchain_ux_transaction_configuration_link_a_card {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration.link.a.card", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration_link_a_card: I {}
public extension I_blockchain_ux_transaction_configuration_link_a_card {
	var `credit`: L_blockchain_ux_transaction_configuration_link_a_card_credit { .init("\(__).credit") }
}
public final class L_blockchain_ux_transaction_configuration_link_a_card_credit: L, I_blockchain_ux_transaction_configuration_link_a_card_credit {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration.link.a.card.credit", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration_link_a_card_credit: I {}
public extension I_blockchain_ux_transaction_configuration_link_a_card_credit {
	var `card`: L_blockchain_ux_transaction_configuration_link_a_card_credit_card { .init("\(__).card") }
}
public final class L_blockchain_ux_transaction_configuration_link_a_card_credit_card: L, I_blockchain_ux_transaction_configuration_link_a_card_credit_card {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration.link.a.card.credit.card", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration_link_a_card_credit_card: I {}
public extension I_blockchain_ux_transaction_configuration_link_a_card_credit_card {
	var `learn`: L_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn { .init("\(__).learn") }
}
public final class L_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn: L, I_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration.link.a.card.credit.card.learn", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn: I {}
public extension I_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn {
	var `more`: L_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more { .init("\(__).more") }
}
public final class L_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more: L, I_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration.link.a.card.credit.card.learn.more", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more: I {}
public extension I_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more {
	var `url`: L_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more_url { .init("\(__).url") }
}
public final class L_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more_url: L, I_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more_url {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.configuration.link.a.card.credit.card.learn.more.url", comment: "") }
}
public protocol I_blockchain_ux_transaction_configuration_link_a_card_credit_card_learn_more_url: I_blockchain_db_type_url, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_transaction_details: L, I_blockchain_ux_transaction_details {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.details", comment: "") }
}
public protocol I_blockchain_ux_transaction_details: I {}
public extension I_blockchain_ux_transaction_details {
	var `button`: L_blockchain_ux_transaction_details_button { .init("\(__).button") }
}
public final class L_blockchain_ux_transaction_details_button: L, I_blockchain_ux_transaction_details_button {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.details.button", comment: "") }
}
public protocol I_blockchain_ux_transaction_details_button: I {}
public extension I_blockchain_ux_transaction_details_button {
	var `copy`: L_blockchain_ux_transaction_details_button_copy { .init("\(__).copy") }
}
public final class L_blockchain_ux_transaction_details_button_copy: L, I_blockchain_ux_transaction_details_button_copy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.details.button.copy", comment: "") }
}
public protocol I_blockchain_ux_transaction_details_button_copy: I_blockchain_ui_type_button_secondary {}
public final class L_blockchain_ux_transaction_disclaimer: L, I_blockchain_ux_transaction_disclaimer {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.disclaimer", comment: "") }
}
public protocol I_blockchain_ux_transaction_disclaimer: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_transaction_disclaimer {
	var `explain`: L_blockchain_ux_transaction_disclaimer_explain { .init("\(__).explain") }
	var `finish`: L_blockchain_ux_transaction_disclaimer_finish { .init("\(__).finish") }
	var `next`: L_blockchain_ux_transaction_disclaimer_next { .init("\(__).next") }
}
public final class L_blockchain_ux_transaction_disclaimer_explain: L, I_blockchain_ux_transaction_disclaimer_explain {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.disclaimer.explain", comment: "") }
}
public protocol I_blockchain_ux_transaction_disclaimer_explain: I_blockchain_db_collection, I_blockchain_ux_type_story {}
public extension I_blockchain_ux_transaction_disclaimer_explain {
	var `learn`: L_blockchain_ux_transaction_disclaimer_explain_learn { .init("\(__).learn") }
}
public final class L_blockchain_ux_transaction_disclaimer_explain_learn: L, I_blockchain_ux_transaction_disclaimer_explain_learn {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.disclaimer.explain.learn", comment: "") }
}
public protocol I_blockchain_ux_transaction_disclaimer_explain_learn: I {}
public extension I_blockchain_ux_transaction_disclaimer_explain_learn {
	var `more`: L_blockchain_ux_transaction_disclaimer_explain_learn_more { .init("\(__).more") }
}
public final class L_blockchain_ux_transaction_disclaimer_explain_learn_more: L, I_blockchain_ux_transaction_disclaimer_explain_learn_more {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.disclaimer.explain.learn.more", comment: "") }
}
public protocol I_blockchain_ux_transaction_disclaimer_explain_learn_more: I_blockchain_ui_type_button_minimal {}
public final class L_blockchain_ux_transaction_disclaimer_finish: L, I_blockchain_ux_transaction_disclaimer_finish {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.disclaimer.finish", comment: "") }
}
public protocol I_blockchain_ux_transaction_disclaimer_finish: I_blockchain_ui_type_button_primary {}
public final class L_blockchain_ux_transaction_disclaimer_next: L, I_blockchain_ux_transaction_disclaimer_next {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.disclaimer.next", comment: "") }
}
public protocol I_blockchain_ux_transaction_disclaimer_next: I_blockchain_ui_type_button_primary {}
public final class L_blockchain_ux_transaction_enter: L, I_blockchain_ux_transaction_enter {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter: I {}
public extension I_blockchain_ux_transaction_enter {
	var `amount`: L_blockchain_ux_transaction_enter_amount { .init("\(__).amount") }
}
public final class L_blockchain_ux_transaction_enter_amount: L, I_blockchain_ux_transaction_enter_amount {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_transaction_enter_amount {
	var `button`: L_blockchain_ux_transaction_enter_amount_button { .init("\(__).button") }
	var `default`: L_blockchain_ux_transaction_enter_amount_default { .init("\(__).default") }
	var `input`: L_blockchain_ux_transaction_enter_amount_input { .init("\(__).input") }
	var `output`: L_blockchain_ux_transaction_enter_amount_output { .init("\(__).output") }
	var `quick`: L_blockchain_ux_transaction_enter_amount_quick { .init("\(__).quick") }
	var `swap`: L_blockchain_ux_transaction_enter_amount_swap { .init("\(__).swap") }
}
public final class L_blockchain_ux_transaction_enter_amount_button: L, I_blockchain_ux_transaction_enter_amount_button {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.button", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_button: I {}
public extension I_blockchain_ux_transaction_enter_amount_button {
	var `confirm`: L_blockchain_ux_transaction_enter_amount_button_confirm { .init("\(__).confirm") }
	var `max`: L_blockchain_ux_transaction_enter_amount_button_max { .init("\(__).max") }
	var `min`: L_blockchain_ux_transaction_enter_amount_button_min { .init("\(__).min") }
}
public final class L_blockchain_ux_transaction_enter_amount_button_confirm: L, I_blockchain_ux_transaction_enter_amount_button_confirm {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.button.confirm", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_button_confirm: I_blockchain_ui_type_button_primary {}
public final class L_blockchain_ux_transaction_enter_amount_button_max: L, I_blockchain_ux_transaction_enter_amount_button_max {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.button.max", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_button_max: I_blockchain_ui_type_button_secondary {}
public final class L_blockchain_ux_transaction_enter_amount_button_min: L, I_blockchain_ux_transaction_enter_amount_button_min {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.button.min", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_button_min: I_blockchain_ui_type_button_secondary {}
public final class L_blockchain_ux_transaction_enter_amount_default: L, I_blockchain_ux_transaction_enter_amount_default {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.default", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_default: I {}
public extension I_blockchain_ux_transaction_enter_amount_default {
	var `input`: L_blockchain_ux_transaction_enter_amount_default_input { .init("\(__).input") }
}
public final class L_blockchain_ux_transaction_enter_amount_default_input: L, I_blockchain_ux_transaction_enter_amount_default_input {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.default.input", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_default_input: I {}
public extension I_blockchain_ux_transaction_enter_amount_default_input {
	var `amount`: L_blockchain_ux_transaction_enter_amount_default_input_amount { .init("\(__).amount") }
	var `currency`: L_blockchain_ux_transaction_enter_amount_default_input_currency { .init("\(__).currency") }
}
public final class L_blockchain_ux_transaction_enter_amount_default_input_amount: L, I_blockchain_ux_transaction_enter_amount_default_input_amount {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.default.input.amount", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_default_input_amount: I_blockchain_db_type_bigint, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_enter_amount_default_input_currency: L, I_blockchain_ux_transaction_enter_amount_default_input_currency {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.default.input.currency", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_default_input_currency: I {}
public extension I_blockchain_ux_transaction_enter_amount_default_input_currency {
	var `code`: L_blockchain_ux_transaction_enter_amount_default_input_currency_code { .init("\(__).code") }
}
public final class L_blockchain_ux_transaction_enter_amount_default_input_currency_code: L, I_blockchain_ux_transaction_enter_amount_default_input_currency_code {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.default.input.currency.code", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_default_input_currency_code: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_enter_amount_input: L, I_blockchain_ux_transaction_enter_amount_input {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.input", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_input: I_blockchain_ui_type_input {}
public final class L_blockchain_ux_transaction_enter_amount_output: L, I_blockchain_ux_transaction_enter_amount_output {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.output", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_output: I_blockchain_ui_type_input {}
public final class L_blockchain_ux_transaction_enter_amount_quick: L, I_blockchain_ux_transaction_enter_amount_quick {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.quick", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_quick: I {}
public extension I_blockchain_ux_transaction_enter_amount_quick {
	var `fill`: L_blockchain_ux_transaction_enter_amount_quick_fill { .init("\(__).fill") }
}
public final class L_blockchain_ux_transaction_enter_amount_quick_fill: L, I_blockchain_ux_transaction_enter_amount_quick_fill {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.quick.fill", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_quick_fill: I_blockchain_ux_type_analytics_event {}
public extension I_blockchain_ux_transaction_enter_amount_quick_fill {
	var `amount`: L_blockchain_ux_transaction_enter_amount_quick_fill_amount { .init("\(__).amount") }
	var `type`: L_blockchain_ux_transaction_enter_amount_quick_fill_type { .init("\(__).type") }
}
public final class L_blockchain_ux_transaction_enter_amount_quick_fill_amount: L, I_blockchain_ux_transaction_enter_amount_quick_fill_amount {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.quick.fill.amount", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_quick_fill_amount: I {}
public final class L_blockchain_ux_transaction_enter_amount_quick_fill_type: L, I_blockchain_ux_transaction_enter_amount_quick_fill_type {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.quick.fill.type", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_quick_fill_type: I {}
public final class L_blockchain_ux_transaction_enter_amount_swap: L, I_blockchain_ux_transaction_enter_amount_swap {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.swap", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_swap: I {}
public extension I_blockchain_ux_transaction_enter_amount_swap {
	var `input`: L_blockchain_ux_transaction_enter_amount_swap_input { .init("\(__).input") }
}
public final class L_blockchain_ux_transaction_enter_amount_swap_input: L, I_blockchain_ux_transaction_enter_amount_swap_input {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.swap.input", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_swap_input: I_blockchain_ux_type_analytics_event {}
public extension I_blockchain_ux_transaction_enter_amount_swap_input {
	var `crypto`: L_blockchain_ux_transaction_enter_amount_swap_input_crypto { .init("\(__).crypto") }
	var `fiat`: L_blockchain_ux_transaction_enter_amount_swap_input_fiat { .init("\(__).fiat") }
}
public final class L_blockchain_ux_transaction_enter_amount_swap_input_crypto: L, I_blockchain_ux_transaction_enter_amount_swap_input_crypto {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.swap.input.crypto", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_swap_input_crypto: I_blockchain_db_type_boolean {}
public final class L_blockchain_ux_transaction_enter_amount_swap_input_fiat: L, I_blockchain_ux_transaction_enter_amount_swap_input_fiat {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.enter.amount.swap.input.fiat", comment: "") }
}
public protocol I_blockchain_ux_transaction_enter_amount_swap_input_fiat: I_blockchain_db_type_boolean {}
public final class L_blockchain_ux_transaction_event: L, I_blockchain_ux_transaction_event {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event", comment: "") }
}
public protocol I_blockchain_ux_transaction_event: I {}
public extension I_blockchain_ux_transaction_event {
	var `did`: L_blockchain_ux_transaction_event_did { .init("\(__).did") }
	var `enter`: L_blockchain_ux_transaction_event_enter { .init("\(__).enter") }
	var `execution`: L_blockchain_ux_transaction_event_execution { .init("\(__).execution") }
	var `in`: L_blockchain_ux_transaction_event_in { .init("\(__).in") }
	var `link`: L_blockchain_ux_transaction_event_link { .init("\(__).link") }
	var `select`: L_blockchain_ux_transaction_event_select { .init("\(__).select") }
	var `should`: L_blockchain_ux_transaction_event_should { .init("\(__).should") }
	var `validate`: L_blockchain_ux_transaction_event_validate { .init("\(__).validate") }
	var `will`: L_blockchain_ux_transaction_event_will { .init("\(__).will") }
}
public final class L_blockchain_ux_transaction_event_did: L, I_blockchain_ux_transaction_event_did {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did: I {}
public extension I_blockchain_ux_transaction_event_did {
	var `error`: L_blockchain_ux_transaction_event_did_error { .init("\(__).error") }
	var `fetch`: L_blockchain_ux_transaction_event_did_fetch { .init("\(__).fetch") }
	var `finish`: L_blockchain_ux_transaction_event_did_finish { .init("\(__).finish") }
	var `go`: L_blockchain_ux_transaction_event_did_go { .init("\(__).go") }
	var `link`: L_blockchain_ux_transaction_event_did_link { .init("\(__).link") }
	var `select`: L_blockchain_ux_transaction_event_did_select { .init("\(__).select") }
	var `start`: L_blockchain_ux_transaction_event_did_start { .init("\(__).start") }
}
public final class L_blockchain_ux_transaction_event_did_error: L, I_blockchain_ux_transaction_event_did_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.error", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_error: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_did_fetch: L, I_blockchain_ux_transaction_event_did_fetch {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.fetch", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_fetch: I {}
public extension I_blockchain_ux_transaction_event_did_fetch {
	var `recurring`: L_blockchain_ux_transaction_event_did_fetch_recurring { .init("\(__).recurring") }
}
public final class L_blockchain_ux_transaction_event_did_fetch_recurring: L, I_blockchain_ux_transaction_event_did_fetch_recurring {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.fetch.recurring", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_fetch_recurring: I {}
public extension I_blockchain_ux_transaction_event_did_fetch_recurring {
	var `buy`: L_blockchain_ux_transaction_event_did_fetch_recurring_buy { .init("\(__).buy") }
}
public final class L_blockchain_ux_transaction_event_did_fetch_recurring_buy: L, I_blockchain_ux_transaction_event_did_fetch_recurring_buy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.fetch.recurring.buy", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_fetch_recurring_buy: I {}
public extension I_blockchain_ux_transaction_event_did_fetch_recurring_buy {
	var `frequencies`: L_blockchain_ux_transaction_event_did_fetch_recurring_buy_frequencies { .init("\(__).frequencies") }
}
public final class L_blockchain_ux_transaction_event_did_fetch_recurring_buy_frequencies: L, I_blockchain_ux_transaction_event_did_fetch_recurring_buy_frequencies {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.fetch.recurring.buy.frequencies", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_fetch_recurring_buy_frequencies: I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_event_did_finish: L, I_blockchain_ux_transaction_event_did_finish {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.finish", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_finish: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_did_go: L, I_blockchain_ux_transaction_event_did_go {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.go", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_go: I {}
public extension I_blockchain_ux_transaction_event_did_go {
	var `back`: L_blockchain_ux_transaction_event_did_go_back { .init("\(__).back") }
}
public final class L_blockchain_ux_transaction_event_did_go_back: L, I_blockchain_ux_transaction_event_did_go_back {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.go.back", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_go_back: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_did_link: L, I_blockchain_ux_transaction_event_did_link {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.link", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_link: I {}
public extension I_blockchain_ux_transaction_event_did_link {
	var `a`: L_blockchain_ux_transaction_event_did_link_a { .init("\(__).a") }
	var `payment`: L_blockchain_ux_transaction_event_did_link_payment { .init("\(__).payment") }
}
public final class L_blockchain_ux_transaction_event_did_link_a: L, I_blockchain_ux_transaction_event_did_link_a {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.link.a", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_link_a: I {}
public extension I_blockchain_ux_transaction_event_did_link_a {
	var `bank`: L_blockchain_ux_transaction_event_did_link_a_bank { .init("\(__).bank") }
	var `card`: L_blockchain_ux_transaction_event_did_link_a_card { .init("\(__).card") }
}
public final class L_blockchain_ux_transaction_event_did_link_a_bank: L, I_blockchain_ux_transaction_event_did_link_a_bank {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.link.a.bank", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_link_a_bank: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_did_link_a_card: L, I_blockchain_ux_transaction_event_did_link_a_card {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.link.a.card", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_link_a_card: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_did_link_payment: L, I_blockchain_ux_transaction_event_did_link_payment {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.link.payment", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_link_payment: I {}
public extension I_blockchain_ux_transaction_event_did_link_payment {
	var `method`: L_blockchain_ux_transaction_event_did_link_payment_method { .init("\(__).method") }
}
public final class L_blockchain_ux_transaction_event_did_link_payment_method: L, I_blockchain_ux_transaction_event_did_link_payment_method {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.link.payment.method", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_link_payment_method: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_did_select: L, I_blockchain_ux_transaction_event_did_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.select", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_select: I {}
public extension I_blockchain_ux_transaction_event_did_select {
	var `source`: L_blockchain_ux_transaction_event_did_select_source { .init("\(__).source") }
	var `target`: L_blockchain_ux_transaction_event_did_select_target { .init("\(__).target") }
}
public final class L_blockchain_ux_transaction_event_did_select_source: L, I_blockchain_ux_transaction_event_did_select_source {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.select.source", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_select_source: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_did_select_target: L, I_blockchain_ux_transaction_event_did_select_target {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.select.target", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_select_target: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_did_start: L, I_blockchain_ux_transaction_event_did_start {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.did.start", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_did_start: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_enter: L, I_blockchain_ux_transaction_event_enter {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.enter", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_enter: I {}
public extension I_blockchain_ux_transaction_event_enter {
	var `address`: L_blockchain_ux_transaction_event_enter_address { .init("\(__).address") }
}
public final class L_blockchain_ux_transaction_event_enter_address: L, I_blockchain_ux_transaction_event_enter_address {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.enter.address", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_enter_address: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_execution: L, I_blockchain_ux_transaction_event_execution {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.execution", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_execution: I {}
public extension I_blockchain_ux_transaction_event_execution {
	var `status`: L_blockchain_ux_transaction_event_execution_status { .init("\(__).status") }
}
public final class L_blockchain_ux_transaction_event_execution_status: L, I_blockchain_ux_transaction_event_execution_status {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.execution.status", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_execution_status: I_blockchain_db_type_enum {}
public extension I_blockchain_ux_transaction_event_execution_status {
	var `completed`: L_blockchain_ux_transaction_event_execution_status_completed { .init("\(__).completed") }
	var `error`: L_blockchain_ux_transaction_event_execution_status_error { .init("\(__).error") }
	var `in`: L_blockchain_ux_transaction_event_execution_status_in { .init("\(__).in") }
	var `pending`: L_blockchain_ux_transaction_event_execution_status_pending { .init("\(__).pending") }
	var `starting`: L_blockchain_ux_transaction_event_execution_status_starting { .init("\(__).starting") }
}
public final class L_blockchain_ux_transaction_event_execution_status_completed: L, I_blockchain_ux_transaction_event_execution_status_completed {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.execution.status.completed", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_execution_status_completed: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_execution_status_error: L, I_blockchain_ux_transaction_event_execution_status_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.execution.status.error", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_execution_status_error: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_execution_status_in: L, I_blockchain_ux_transaction_event_execution_status_in {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.execution.status.in", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_execution_status_in: I {}
public extension I_blockchain_ux_transaction_event_execution_status_in {
	var `progress`: L_blockchain_ux_transaction_event_execution_status_in_progress { .init("\(__).progress") }
}
public final class L_blockchain_ux_transaction_event_execution_status_in_progress: L, I_blockchain_ux_transaction_event_execution_status_in_progress {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.execution.status.in.progress", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_execution_status_in_progress: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_execution_status_pending: L, I_blockchain_ux_transaction_event_execution_status_pending {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.execution.status.pending", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_execution_status_pending: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_execution_status_starting: L, I_blockchain_ux_transaction_event_execution_status_starting {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.execution.status.starting", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_execution_status_starting: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_in: L, I_blockchain_ux_transaction_event_in {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.in", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_in: I {}
public extension I_blockchain_ux_transaction_event_in {
	var `progress`: L_blockchain_ux_transaction_event_in_progress { .init("\(__).progress") }
}
public final class L_blockchain_ux_transaction_event_in_progress: L, I_blockchain_ux_transaction_event_in_progress {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.in.progress", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_in_progress: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_link: L, I_blockchain_ux_transaction_event_link {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.link", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_link: I {}
public extension I_blockchain_ux_transaction_event_link {
	var `a`: L_blockchain_ux_transaction_event_link_a { .init("\(__).a") }
	var `payment`: L_blockchain_ux_transaction_event_link_payment { .init("\(__).payment") }
}
public final class L_blockchain_ux_transaction_event_link_a: L, I_blockchain_ux_transaction_event_link_a {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.link.a", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_link_a: I {}
public extension I_blockchain_ux_transaction_event_link_a {
	var `bank`: L_blockchain_ux_transaction_event_link_a_bank { .init("\(__).bank") }
	var `card`: L_blockchain_ux_transaction_event_link_a_card { .init("\(__).card") }
}
public final class L_blockchain_ux_transaction_event_link_a_bank: L, I_blockchain_ux_transaction_event_link_a_bank {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.link.a.bank", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_link_a_bank: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_link_a_card: L, I_blockchain_ux_transaction_event_link_a_card {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.link.a.card", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_link_a_card: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_link_payment: L, I_blockchain_ux_transaction_event_link_payment {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.link.payment", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_link_payment: I {}
public extension I_blockchain_ux_transaction_event_link_payment {
	var `method`: L_blockchain_ux_transaction_event_link_payment_method { .init("\(__).method") }
}
public final class L_blockchain_ux_transaction_event_link_payment_method: L, I_blockchain_ux_transaction_event_link_payment_method {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.link.payment.method", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_link_payment_method: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_select: L, I_blockchain_ux_transaction_event_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.select", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_select: I {}
public extension I_blockchain_ux_transaction_event_select {
	var `source`: L_blockchain_ux_transaction_event_select_source { .init("\(__).source") }
	var `target`: L_blockchain_ux_transaction_event_select_target { .init("\(__).target") }
}
public final class L_blockchain_ux_transaction_event_select_source: L, I_blockchain_ux_transaction_event_select_source {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.select.source", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_select_source: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_select_target: L, I_blockchain_ux_transaction_event_select_target {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.select.target", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_select_target: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_should: L, I_blockchain_ux_transaction_event_should {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.should", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_should: I {}
public extension I_blockchain_ux_transaction_event_should {
	var `show`: L_blockchain_ux_transaction_event_should_show { .init("\(__).show") }
}
public final class L_blockchain_ux_transaction_event_should_show: L, I_blockchain_ux_transaction_event_should_show {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.should.show", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_should_show: I {}
public extension I_blockchain_ux_transaction_event_should_show {
	var `disclaimer`: L_blockchain_ux_transaction_event_should_show_disclaimer { .init("\(__).disclaimer") }
}
public final class L_blockchain_ux_transaction_event_should_show_disclaimer: L, I_blockchain_ux_transaction_event_should_show_disclaimer {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.should.show.disclaimer", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_should_show_disclaimer: I_blockchain_ux_type_action {}
public final class L_blockchain_ux_transaction_event_validate: L, I_blockchain_ux_transaction_event_validate {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.validate", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_validate: I {}
public extension I_blockchain_ux_transaction_event_validate {
	var `source`: L_blockchain_ux_transaction_event_validate_source { .init("\(__).source") }
	var `transaction`: L_blockchain_ux_transaction_event_validate_transaction { .init("\(__).transaction") }
}
public final class L_blockchain_ux_transaction_event_validate_source: L, I_blockchain_ux_transaction_event_validate_source {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.validate.source", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_validate_source: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_validate_transaction: L, I_blockchain_ux_transaction_event_validate_transaction {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.validate.transaction", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_validate_transaction: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_will: L, I_blockchain_ux_transaction_event_will {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.will", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_will: I {}
public extension I_blockchain_ux_transaction_event_will {
	var `finish`: L_blockchain_ux_transaction_event_will_finish { .init("\(__).finish") }
	var `start`: L_blockchain_ux_transaction_event_will_start { .init("\(__).start") }
}
public final class L_blockchain_ux_transaction_event_will_finish: L, I_blockchain_ux_transaction_event_will_finish {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.will.finish", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_will_finish: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_event_will_start: L, I_blockchain_ux_transaction_event_will_start {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.event.will.start", comment: "") }
}
public protocol I_blockchain_ux_transaction_event_will_start: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_transaction_loading: L, I_blockchain_ux_transaction_loading {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.loading", comment: "") }
}
public protocol I_blockchain_ux_transaction_loading: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_transaction_loading {
	var `close`: L_blockchain_ux_transaction_loading_close { .init("\(__).close") }
}
public final class L_blockchain_ux_transaction_loading_close: L, I_blockchain_ux_transaction_loading_close {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.loading.close", comment: "") }
}
public protocol I_blockchain_ux_transaction_loading_close: I_blockchain_ui_type_button_primary {}
public final class L_blockchain_ux_transaction_payment: L, I_blockchain_ux_transaction_payment {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment: I {}
public extension I_blockchain_ux_transaction_payment {
	var `method`: L_blockchain_ux_transaction_payment_method { .init("\(__).method") }
}
public final class L_blockchain_ux_transaction_payment_method: L, I_blockchain_ux_transaction_payment_method {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method: I {}
public extension I_blockchain_ux_transaction_payment_method {
	var `is`: L_blockchain_ux_transaction_payment_method_is { .init("\(__).is") }
	var `link`: L_blockchain_ux_transaction_payment_method_link { .init("\(__).link") }
}
public final class L_blockchain_ux_transaction_payment_method_is: L, I_blockchain_ux_transaction_payment_method_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.is", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_is: I {}
public extension I_blockchain_ux_transaction_payment_method_is {
	var `ApplePay`: L_blockchain_ux_transaction_payment_method_is_ApplePay { .init("\(__).ApplePay") }
	var `available`: L_blockchain_ux_transaction_payment_method_is_available { .init("\(__).available") }
	var `bank`: L_blockchain_ux_transaction_payment_method_is_bank { .init("\(__).bank") }
	var `card`: L_blockchain_ux_transaction_payment_method_is_card { .init("\(__).card") }
	var `funds`: L_blockchain_ux_transaction_payment_method_is_funds { .init("\(__).funds") }
	var `GooglePay`: L_blockchain_ux_transaction_payment_method_is_GooglePay { .init("\(__).GooglePay") }
}
public final class L_blockchain_ux_transaction_payment_method_is_ApplePay: L, I_blockchain_ux_transaction_payment_method_is_ApplePay {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.is.ApplePay", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_is_ApplePay: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_payment_method_is_available: L, I_blockchain_ux_transaction_payment_method_is_available {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.is.available", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_is_available: I {}
public extension I_blockchain_ux_transaction_payment_method_is_available {
	var `for`: L_blockchain_ux_transaction_payment_method_is_available_for { .init("\(__).for") }
}
public final class L_blockchain_ux_transaction_payment_method_is_available_for: L, I_blockchain_ux_transaction_payment_method_is_available_for {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.is.available.for", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_is_available_for: I {}
public extension I_blockchain_ux_transaction_payment_method_is_available_for {
	var `recurring`: L_blockchain_ux_transaction_payment_method_is_available_for_recurring { .init("\(__).recurring") }
}
public final class L_blockchain_ux_transaction_payment_method_is_available_for_recurring: L, I_blockchain_ux_transaction_payment_method_is_available_for_recurring {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.is.available.for.recurring", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_is_available_for_recurring: I {}
public extension I_blockchain_ux_transaction_payment_method_is_available_for_recurring {
	var `buy`: L_blockchain_ux_transaction_payment_method_is_available_for_recurring_buy { .init("\(__).buy") }
}
public final class L_blockchain_ux_transaction_payment_method_is_available_for_recurring_buy: L, I_blockchain_ux_transaction_payment_method_is_available_for_recurring_buy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.is.available.for.recurring.buy", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_is_available_for_recurring_buy: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_payment_method_is_bank: L, I_blockchain_ux_transaction_payment_method_is_bank {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.is.bank", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_is_bank: I {}
public extension I_blockchain_ux_transaction_payment_method_is_bank {
	var `ACH`: L_blockchain_ux_transaction_payment_method_is_bank_ACH { .init("\(__).ACH") }
	var `OpenBanking`: L_blockchain_ux_transaction_payment_method_is_bank_OpenBanking { .init("\(__).OpenBanking") }
}
public final class L_blockchain_ux_transaction_payment_method_is_bank_ACH: L, I_blockchain_ux_transaction_payment_method_is_bank_ACH {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.is.bank.ACH", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_is_bank_ACH: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_payment_method_is_bank_OpenBanking: L, I_blockchain_ux_transaction_payment_method_is_bank_OpenBanking {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.is.bank.OpenBanking", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_is_bank_OpenBanking: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_payment_method_is_card: L, I_blockchain_ux_transaction_payment_method_is_card {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.is.card", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_is_card: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_payment_method_is_funds: L, I_blockchain_ux_transaction_payment_method_is_funds {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.is.funds", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_is_funds: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_payment_method_is_GooglePay: L, I_blockchain_ux_transaction_payment_method_is_GooglePay {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.is.GooglePay", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_is_GooglePay: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_payment_method_link: L, I_blockchain_ux_transaction_payment_method_link {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.link", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_link: I {}
public extension I_blockchain_ux_transaction_payment_method_link {
	var `a`: L_blockchain_ux_transaction_payment_method_link_a { .init("\(__).a") }
}
public final class L_blockchain_ux_transaction_payment_method_link_a: L, I_blockchain_ux_transaction_payment_method_link_a {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.link.a", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_link_a: I {}
public extension I_blockchain_ux_transaction_payment_method_link_a {
	var `bank`: L_blockchain_ux_transaction_payment_method_link_a_bank { .init("\(__).bank") }
	var `card`: L_blockchain_ux_transaction_payment_method_link_a_card { .init("\(__).card") }
}
public final class L_blockchain_ux_transaction_payment_method_link_a_bank: L, I_blockchain_ux_transaction_payment_method_link_a_bank {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.link.a.bank", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_link_a_bank: I {}
public extension I_blockchain_ux_transaction_payment_method_link_a_bank {
	var `type`: L_blockchain_ux_transaction_payment_method_link_a_bank_type { .init("\(__).type") }
	var `via`: L_blockchain_ux_transaction_payment_method_link_a_bank_via { .init("\(__).via") }
}
public final class L_blockchain_ux_transaction_payment_method_link_a_bank_type: L, I_blockchain_ux_transaction_payment_method_link_a_bank_type {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.link.a.bank.type", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_link_a_bank_type: I {}
public final class L_blockchain_ux_transaction_payment_method_link_a_bank_via: L, I_blockchain_ux_transaction_payment_method_link_a_bank_via {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.link.a.bank.via", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_link_a_bank_via: I {}
public extension I_blockchain_ux_transaction_payment_method_link_a_bank_via {
	var `ACH`: L_blockchain_ux_transaction_payment_method_link_a_bank_via_ACH { .init("\(__).ACH") }
	var `OpenBanking`: L_blockchain_ux_transaction_payment_method_link_a_bank_via_OpenBanking { .init("\(__).OpenBanking") }
}
public final class L_blockchain_ux_transaction_payment_method_link_a_bank_via_ACH: L, I_blockchain_ux_transaction_payment_method_link_a_bank_via_ACH {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.link.a.bank.via.ACH", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_link_a_bank_via_ACH: I_blockchain_ux_type_story, I_blockchain_ux_transaction_payment_method_link_a_bank_type {}
public final class L_blockchain_ux_transaction_payment_method_link_a_bank_via_OpenBanking: L, I_blockchain_ux_transaction_payment_method_link_a_bank_via_OpenBanking {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.link.a.bank.via.OpenBanking", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_link_a_bank_via_OpenBanking: I_blockchain_ux_type_story, I_blockchain_ux_transaction_payment_method_link_a_bank_type {}
public final class L_blockchain_ux_transaction_payment_method_link_a_card: L, I_blockchain_ux_transaction_payment_method_link_a_card {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.link.a.card", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_link_a_card: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_transaction_payment_method_link_a_card {
	var `billing`: L_blockchain_ux_transaction_payment_method_link_a_card_billing { .init("\(__).billing") }
	var `next`: L_blockchain_ux_transaction_payment_method_link_a_card_next { .init("\(__).next") }
}
public final class L_blockchain_ux_transaction_payment_method_link_a_card_billing: L, I_blockchain_ux_transaction_payment_method_link_a_card_billing {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.link.a.card.billing", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_link_a_card_billing: I {}
public extension I_blockchain_ux_transaction_payment_method_link_a_card_billing {
	var `address`: L_blockchain_ux_transaction_payment_method_link_a_card_billing_address { .init("\(__).address") }
}
public final class L_blockchain_ux_transaction_payment_method_link_a_card_billing_address: L, I_blockchain_ux_transaction_payment_method_link_a_card_billing_address {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.link.a.card.billing.address", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_link_a_card_billing_address: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_transaction_payment_method_link_a_card_billing_address {
	var `save`: L_blockchain_ux_transaction_payment_method_link_a_card_billing_address_save { .init("\(__).save") }
}
public final class L_blockchain_ux_transaction_payment_method_link_a_card_billing_address_save: L, I_blockchain_ux_transaction_payment_method_link_a_card_billing_address_save {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.link.a.card.billing.address.save", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_link_a_card_billing_address_save: I {}
public extension I_blockchain_ux_transaction_payment_method_link_a_card_billing_address_save {
	var `my`: L_blockchain_ux_transaction_payment_method_link_a_card_billing_address_save_my { .init("\(__).my") }
}
public final class L_blockchain_ux_transaction_payment_method_link_a_card_billing_address_save_my: L, I_blockchain_ux_transaction_payment_method_link_a_card_billing_address_save_my {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.link.a.card.billing.address.save.my", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_link_a_card_billing_address_save_my: I {}
public extension I_blockchain_ux_transaction_payment_method_link_a_card_billing_address_save_my {
	var `card`: L_blockchain_ux_transaction_payment_method_link_a_card_billing_address_save_my_card { .init("\(__).card") }
}
public final class L_blockchain_ux_transaction_payment_method_link_a_card_billing_address_save_my_card: L, I_blockchain_ux_transaction_payment_method_link_a_card_billing_address_save_my_card {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.link.a.card.billing.address.save.my.card", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_link_a_card_billing_address_save_my_card: I_blockchain_ui_type_button_primary {}
public final class L_blockchain_ux_transaction_payment_method_link_a_card_next: L, I_blockchain_ux_transaction_payment_method_link_a_card_next {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.payment.method.link.a.card.next", comment: "") }
}
public protocol I_blockchain_ux_transaction_payment_method_link_a_card_next: I_blockchain_ui_type_button_primary {}
public final class L_blockchain_ux_transaction_previous: L, I_blockchain_ux_transaction_previous {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.previous", comment: "") }
}
public protocol I_blockchain_ux_transaction_previous: I {}
public extension I_blockchain_ux_transaction_previous {
	var `payment`: L_blockchain_ux_transaction_previous_payment { .init("\(__).payment") }
}
public final class L_blockchain_ux_transaction_previous_payment: L, I_blockchain_ux_transaction_previous_payment {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.previous.payment", comment: "") }
}
public protocol I_blockchain_ux_transaction_previous_payment: I {}
public extension I_blockchain_ux_transaction_previous_payment {
	var `method`: L_blockchain_ux_transaction_previous_payment_method { .init("\(__).method") }
}
public final class L_blockchain_ux_transaction_previous_payment_method: L, I_blockchain_ux_transaction_previous_payment_method {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.previous.payment.method", comment: "") }
}
public protocol I_blockchain_ux_transaction_previous_payment_method: I {}
public extension I_blockchain_ux_transaction_previous_payment_method {
	var `id`: L_blockchain_ux_transaction_previous_payment_method_id { .init("\(__).id") }
}
public final class L_blockchain_ux_transaction_previous_payment_method_id: L, I_blockchain_ux_transaction_previous_payment_method_id {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.previous.payment.method.id", comment: "") }
}
public protocol I_blockchain_ux_transaction_previous_payment_method_id: I_blockchain_db_type_string, I_blockchain_session_state_preference_value {}
public final class L_blockchain_ux_transaction_smart: L, I_blockchain_ux_transaction_smart {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.smart", comment: "") }
}
public protocol I_blockchain_ux_transaction_smart: I {}
public extension I_blockchain_ux_transaction_smart {
	var `sort`: L_blockchain_ux_transaction_smart_sort { .init("\(__).sort") }
}
public final class L_blockchain_ux_transaction_smart_sort: L, I_blockchain_ux_transaction_smart_sort {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.smart.sort", comment: "") }
}
public protocol I_blockchain_ux_transaction_smart_sort: I {}
public extension I_blockchain_ux_transaction_smart_sort {
	var `order`: L_blockchain_ux_transaction_smart_sort_order { .init("\(__).order") }
}
public final class L_blockchain_ux_transaction_smart_sort_order: L, I_blockchain_ux_transaction_smart_sort_order {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.smart.sort.order", comment: "") }
}
public protocol I_blockchain_ux_transaction_smart_sort_order: I {}
public extension I_blockchain_ux_transaction_smart_sort_order {
	var `is`: L_blockchain_ux_transaction_smart_sort_order_is { .init("\(__).is") }
}
public final class L_blockchain_ux_transaction_smart_sort_order_is: L, I_blockchain_ux_transaction_smart_sort_order_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.smart.sort.order.is", comment: "") }
}
public protocol I_blockchain_ux_transaction_smart_sort_order_is: I {}
public extension I_blockchain_ux_transaction_smart_sort_order_is {
	var `enabled`: L_blockchain_ux_transaction_smart_sort_order_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_ux_transaction_smart_sort_order_is_enabled: L, I_blockchain_ux_transaction_smart_sort_order_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.smart.sort.order.is.enabled", comment: "") }
}
public protocol I_blockchain_ux_transaction_smart_sort_order_is_enabled: I_blockchain_db_type_boolean, I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_transaction_source: L, I_blockchain_ux_transaction_source {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source", comment: "") }
}
public protocol I_blockchain_ux_transaction_source: I_blockchain_db_collection {}
public extension I_blockchain_ux_transaction_source {
	var `analytics`: L_blockchain_ux_transaction_source_analytics { .init("\(__).analytics") }
	var `is`: L_blockchain_ux_transaction_source_is { .init("\(__).is") }
	var `label`: L_blockchain_ux_transaction_source_label { .init("\(__).label") }
	var `target`: L_blockchain_ux_transaction_source_target { .init("\(__).target") }
}
public final class L_blockchain_ux_transaction_source_analytics: L, I_blockchain_ux_transaction_source_analytics {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.analytics", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_analytics: I {}
public extension I_blockchain_ux_transaction_source_analytics {
	var `type`: L_blockchain_ux_transaction_source_analytics_type { .init("\(__).type") }
}
public final class L_blockchain_ux_transaction_source_analytics_type: L, I_blockchain_ux_transaction_source_analytics_type {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.analytics.type", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_analytics_type: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_source_is: L, I_blockchain_ux_transaction_source_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.is", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_is: I {}
public extension I_blockchain_ux_transaction_source_is {
	var `private`: L_blockchain_ux_transaction_source_is_private { .init("\(__).private") }
}
public final class L_blockchain_ux_transaction_source_is_private: L, I_blockchain_ux_transaction_source_is_private {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.is.private", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_is_private: I {}
public extension I_blockchain_ux_transaction_source_is_private {
	var `key`: L_blockchain_ux_transaction_source_is_private_key { .init("\(__).key") }
}
public final class L_blockchain_ux_transaction_source_is_private_key: L, I_blockchain_ux_transaction_source_is_private_key {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.is.private.key", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_is_private_key: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_source_label: L, I_blockchain_ux_transaction_source_label {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.label", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_label: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_source_target: L, I_blockchain_ux_transaction_source_target {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target: I_blockchain_db_collection {}
public extension I_blockchain_ux_transaction_source_target {
	var `analytics`: L_blockchain_ux_transaction_source_target_analytics { .init("\(__).analytics") }
	var `count`: L_blockchain_ux_transaction_source_target_count { .init("\(__).count") }
	var `is`: L_blockchain_ux_transaction_source_target_is { .init("\(__).is") }
	var `label`: L_blockchain_ux_transaction_source_target_label { .init("\(__).label") }
	var `previous`: L_blockchain_ux_transaction_source_target_previous { .init("\(__).previous") }
	var `quote`: L_blockchain_ux_transaction_source_target_quote { .init("\(__).quote") }
}
public final class L_blockchain_ux_transaction_source_target_analytics: L, I_blockchain_ux_transaction_source_target_analytics {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.analytics", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_analytics: I {}
public extension I_blockchain_ux_transaction_source_target_analytics {
	var `type`: L_blockchain_ux_transaction_source_target_analytics_type { .init("\(__).type") }
}
public final class L_blockchain_ux_transaction_source_target_analytics_type: L, I_blockchain_ux_transaction_source_target_analytics_type {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.analytics.type", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_analytics_type: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_source_target_count: L, I_blockchain_ux_transaction_source_target_count {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.count", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_count: I {}
public extension I_blockchain_ux_transaction_source_target_count {
	var `of`: L_blockchain_ux_transaction_source_target_count_of { .init("\(__).of") }
}
public final class L_blockchain_ux_transaction_source_target_count_of: L, I_blockchain_ux_transaction_source_target_count_of {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.count.of", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_count_of: I {}
public extension I_blockchain_ux_transaction_source_target_count_of {
	var `completed`: L_blockchain_ux_transaction_source_target_count_of_completed { .init("\(__).completed") }
}
public final class L_blockchain_ux_transaction_source_target_count_of_completed: L, I_blockchain_ux_transaction_source_target_count_of_completed {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.count.of.completed", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_count_of_completed: I_blockchain_db_type_integer, I_blockchain_session_state_preference_value {}
public final class L_blockchain_ux_transaction_source_target_is: L, I_blockchain_ux_transaction_source_target_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.is", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_is: I {}
public extension I_blockchain_ux_transaction_source_target_is {
	var `private`: L_blockchain_ux_transaction_source_target_is_private { .init("\(__).private") }
}
public final class L_blockchain_ux_transaction_source_target_is_private: L, I_blockchain_ux_transaction_source_target_is_private {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.is.private", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_is_private: I {}
public extension I_blockchain_ux_transaction_source_target_is_private {
	var `key`: L_blockchain_ux_transaction_source_target_is_private_key { .init("\(__).key") }
}
public final class L_blockchain_ux_transaction_source_target_is_private_key: L, I_blockchain_ux_transaction_source_target_is_private_key {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.is.private.key", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_is_private_key: I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_source_target_label: L, I_blockchain_ux_transaction_source_target_label {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.label", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_label: I_blockchain_db_type_string, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_source_target_previous: L, I_blockchain_ux_transaction_source_target_previous {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.previous", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_previous: I {}
public extension I_blockchain_ux_transaction_source_target_previous {
	var `did`: L_blockchain_ux_transaction_source_target_previous_did { .init("\(__).did") }
	var `input`: L_blockchain_ux_transaction_source_target_previous_input { .init("\(__).input") }
}
public final class L_blockchain_ux_transaction_source_target_previous_did: L, I_blockchain_ux_transaction_source_target_previous_did {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.previous.did", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_previous_did: I {}
public extension I_blockchain_ux_transaction_source_target_previous_did {
	var `error`: L_blockchain_ux_transaction_source_target_previous_did_error { .init("\(__).error") }
}
public final class L_blockchain_ux_transaction_source_target_previous_did_error: L, I_blockchain_ux_transaction_source_target_previous_did_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.previous.did.error", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_previous_did_error: I_blockchain_db_type_boolean, I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_source_target_previous_input: L, I_blockchain_ux_transaction_source_target_previous_input {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.previous.input", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_previous_input: I {}
public extension I_blockchain_ux_transaction_source_target_previous_input {
	var `amount`: L_blockchain_ux_transaction_source_target_previous_input_amount { .init("\(__).amount") }
	var `currency`: L_blockchain_ux_transaction_source_target_previous_input_currency { .init("\(__).currency") }
}
public final class L_blockchain_ux_transaction_source_target_previous_input_amount: L, I_blockchain_ux_transaction_source_target_previous_input_amount {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.previous.input.amount", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_previous_input_amount: I_blockchain_db_type_bigint, I_blockchain_session_state_preference_value {}
public final class L_blockchain_ux_transaction_source_target_previous_input_currency: L, I_blockchain_ux_transaction_source_target_previous_input_currency {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.previous.input.currency", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_previous_input_currency: I {}
public extension I_blockchain_ux_transaction_source_target_previous_input_currency {
	var `code`: L_blockchain_ux_transaction_source_target_previous_input_currency_code { .init("\(__).code") }
}
public final class L_blockchain_ux_transaction_source_target_previous_input_currency_code: L, I_blockchain_ux_transaction_source_target_previous_input_currency_code {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.previous.input.currency.code", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_previous_input_currency_code: I_blockchain_db_type_string, I_blockchain_session_state_preference_value {}
public final class L_blockchain_ux_transaction_source_target_quote: L, I_blockchain_ux_transaction_source_target_quote {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.quote", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_quote: I_blockchain_session_state_value {}
public extension I_blockchain_ux_transaction_source_target_quote {
	var `payment`: L_blockchain_ux_transaction_source_target_quote_payment { .init("\(__).payment") }
	var `price`: L_blockchain_ux_transaction_source_target_quote_price { .init("\(__).price") }
	var `profile`: L_blockchain_ux_transaction_source_target_quote_profile { .init("\(__).profile") }
	var `value`: L_blockchain_ux_transaction_source_target_quote_value { .init("\(__).value") }
}
public final class L_blockchain_ux_transaction_source_target_quote_payment: L, I_blockchain_ux_transaction_source_target_quote_payment {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.quote.payment", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_quote_payment: I {}
public extension I_blockchain_ux_transaction_source_target_quote_payment {
	var `method`: L_blockchain_ux_transaction_source_target_quote_payment_method { .init("\(__).method") }
}
public final class L_blockchain_ux_transaction_source_target_quote_payment_method: L, I_blockchain_ux_transaction_source_target_quote_payment_method {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.quote.payment.method", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_quote_payment_method: I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_source_target_quote_price: L, I_blockchain_ux_transaction_source_target_quote_price {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.quote.price", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_quote_price: I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_source_target_quote_profile: L, I_blockchain_ux_transaction_source_target_quote_profile {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.quote.profile", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_quote_profile: I_blockchain_session_state_value {}
public final class L_blockchain_ux_transaction_source_target_quote_value: L, I_blockchain_ux_transaction_source_target_quote_value {
	public override class var localized: String { NSLocalizedString("blockchain.ux.transaction.source.target.quote.value", comment: "") }
}
public protocol I_blockchain_ux_transaction_source_target_quote_value: I_blockchain_session_state_value {}
public final class L_blockchain_ux_type: L, I_blockchain_ux_type {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type", comment: "") }
}
public protocol I_blockchain_ux_type: I {}
public extension I_blockchain_ux_type {
	var `action`: L_blockchain_ux_type_action { .init("\(__).action") }
	var `analytics`: L_blockchain_ux_type_analytics { .init("\(__).analytics") }
	var `story`: L_blockchain_ux_type_story { .init("\(__).story") }
	var `task`: L_blockchain_ux_type_task { .init("\(__).task") }
}
public final class L_blockchain_ux_type_action: L, I_blockchain_ux_type_action {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.action", comment: "") }
}
public protocol I_blockchain_ux_type_action: I_blockchain_ui_type_action {}
public final class L_blockchain_ux_type_analytics: L, I_blockchain_ux_type_analytics {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics", comment: "") }
}
public protocol I_blockchain_ux_type_analytics: I {}
public extension I_blockchain_ux_type_analytics {
	var `action`: L_blockchain_ux_type_analytics_action { .init("\(__).action") }
	var `configuration`: L_blockchain_ux_type_analytics_configuration { .init("\(__).configuration") }
	var `current`: L_blockchain_ux_type_analytics_current { .init("\(__).current") }
	var `error`: L_blockchain_ux_type_analytics_error { .init("\(__).error") }
	var `event`: L_blockchain_ux_type_analytics_event { .init("\(__).event") }
	var `privacy`: L_blockchain_ux_type_analytics_privacy { .init("\(__).privacy") }
	var `state`: L_blockchain_ux_type_analytics_state { .init("\(__).state") }
}
public final class L_blockchain_ux_type_analytics_action: L, I_blockchain_ux_type_analytics_action {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.action", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_action: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_type_analytics_configuration: L, I_blockchain_ux_type_analytics_configuration {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.configuration", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_configuration: I {}
public extension I_blockchain_ux_type_analytics_configuration {
	var `firebase`: L_blockchain_ux_type_analytics_configuration_firebase { .init("\(__).firebase") }
	var `segment`: L_blockchain_ux_type_analytics_configuration_segment { .init("\(__).segment") }
}
public final class L_blockchain_ux_type_analytics_configuration_firebase: L, I_blockchain_ux_type_analytics_configuration_firebase {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.configuration.firebase", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_configuration_firebase: I {}
public extension I_blockchain_ux_type_analytics_configuration_firebase {
	var `map`: L_blockchain_ux_type_analytics_configuration_firebase_map { .init("\(__).map") }
	var `user`: L_blockchain_ux_type_analytics_configuration_firebase_user { .init("\(__).user") }
}
public final class L_blockchain_ux_type_analytics_configuration_firebase_map: L, I_blockchain_ux_type_analytics_configuration_firebase_map {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.configuration.firebase.map", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_configuration_firebase_map: I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_type_analytics_configuration_firebase_user: L, I_blockchain_ux_type_analytics_configuration_firebase_user {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.configuration.firebase.user", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_configuration_firebase_user: I {}
public extension I_blockchain_ux_type_analytics_configuration_firebase_user {
	var `traits`: L_blockchain_ux_type_analytics_configuration_firebase_user_traits { .init("\(__).traits") }
}
public final class L_blockchain_ux_type_analytics_configuration_firebase_user_traits: L, I_blockchain_ux_type_analytics_configuration_firebase_user_traits {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.configuration.firebase.user.traits", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_configuration_firebase_user_traits: I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_type_analytics_configuration_segment: L, I_blockchain_ux_type_analytics_configuration_segment {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.configuration.segment", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_configuration_segment: I {}
public extension I_blockchain_ux_type_analytics_configuration_segment {
	var `map`: L_blockchain_ux_type_analytics_configuration_segment_map { .init("\(__).map") }
	var `user`: L_blockchain_ux_type_analytics_configuration_segment_user { .init("\(__).user") }
}
public final class L_blockchain_ux_type_analytics_configuration_segment_map: L, I_blockchain_ux_type_analytics_configuration_segment_map {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.configuration.segment.map", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_configuration_segment_map: I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_type_analytics_configuration_segment_user: L, I_blockchain_ux_type_analytics_configuration_segment_user {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.configuration.segment.user", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_configuration_segment_user: I {}
public extension I_blockchain_ux_type_analytics_configuration_segment_user {
	var `traits`: L_blockchain_ux_type_analytics_configuration_segment_user_traits { .init("\(__).traits") }
}
public final class L_blockchain_ux_type_analytics_configuration_segment_user_traits: L, I_blockchain_ux_type_analytics_configuration_segment_user_traits {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.configuration.segment.user.traits", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_configuration_segment_user_traits: I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_type_analytics_current: L, I_blockchain_ux_type_analytics_current {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.current", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_current: I {}
public extension I_blockchain_ux_type_analytics_current {
	var `state`: L_blockchain_ux_type_analytics_current_state { .init("\(__).state") }
}
public final class L_blockchain_ux_type_analytics_current_state: L, I_blockchain_ux_type_analytics_current_state {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.current.state", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_current_state: I_blockchain_db_type_tag, I_blockchain_session_state_value {}
public final class L_blockchain_ux_type_analytics_error: L, I_blockchain_ux_type_analytics_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.error", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_error: I_blockchain_ux_type_analytics_event {}
public extension I_blockchain_ux_type_analytics_error {
	var `message`: L_blockchain_ux_type_analytics_error_message { .init("\(__).message") }
}
public final class L_blockchain_ux_type_analytics_error_message: L, I_blockchain_ux_type_analytics_error_message {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.error.message", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_error_message: I {}
public final class L_blockchain_ux_type_analytics_event: L, I_blockchain_ux_type_analytics_event {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.event", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_event: I {}
public extension I_blockchain_ux_type_analytics_event {
	var `source`: L_blockchain_ux_type_analytics_event_source { .init("\(__).source") }
}
public final class L_blockchain_ux_type_analytics_event_source: L, I_blockchain_ux_type_analytics_event_source {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.event.source", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_event_source: I {}
public extension I_blockchain_ux_type_analytics_event_source {
	var `file`: L_blockchain_ux_type_analytics_event_source_file { .init("\(__).file") }
	var `line`: L_blockchain_ux_type_analytics_event_source_line { .init("\(__).line") }
}
public final class L_blockchain_ux_type_analytics_event_source_file: L, I_blockchain_ux_type_analytics_event_source_file {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.event.source.file", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_event_source_file: I {}
public final class L_blockchain_ux_type_analytics_event_source_line: L, I_blockchain_ux_type_analytics_event_source_line {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.event.source.line", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_event_source_line: I {}
public final class L_blockchain_ux_type_analytics_privacy: L, I_blockchain_ux_type_analytics_privacy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.privacy", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_privacy: I {}
public extension I_blockchain_ux_type_analytics_privacy {
	var `policy`: L_blockchain_ux_type_analytics_privacy_policy { .init("\(__).policy") }
}
public final class L_blockchain_ux_type_analytics_privacy_policy: L, I_blockchain_ux_type_analytics_privacy_policy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.privacy.policy", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_privacy_policy: I {}
public extension I_blockchain_ux_type_analytics_privacy_policy {
	var `exclude`: L_blockchain_ux_type_analytics_privacy_policy_exclude { .init("\(__).exclude") }
	var `include`: L_blockchain_ux_type_analytics_privacy_policy_include { .init("\(__).include") }
	var `obfuscate`: L_blockchain_ux_type_analytics_privacy_policy_obfuscate { .init("\(__).obfuscate") }
}
public final class L_blockchain_ux_type_analytics_privacy_policy_exclude: L, I_blockchain_ux_type_analytics_privacy_policy_exclude {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.privacy.policy.exclude", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_privacy_policy_exclude: I_blockchain_ux_type_analytics_privacy_policy {}
public final class L_blockchain_ux_type_analytics_privacy_policy_include: L, I_blockchain_ux_type_analytics_privacy_policy_include {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.privacy.policy.include", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_privacy_policy_include: I_blockchain_ux_type_analytics_privacy_policy {}
public final class L_blockchain_ux_type_analytics_privacy_policy_obfuscate: L, I_blockchain_ux_type_analytics_privacy_policy_obfuscate {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.privacy.policy.obfuscate", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_privacy_policy_obfuscate: I_blockchain_ux_type_analytics_privacy_policy {}
public final class L_blockchain_ux_type_analytics_state: L, I_blockchain_ux_type_analytics_state {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.analytics.state", comment: "") }
}
public protocol I_blockchain_ux_type_analytics_state: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_type_story: L, I_blockchain_ux_type_story {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.story", comment: "") }
}
public protocol I_blockchain_ux_type_story: I_blockchain_ui_type_story, I_blockchain_ux_type_analytics_state {}
public extension I_blockchain_ux_type_story {
	var `entry`: L_blockchain_ux_type_story_entry { .init("\(__).entry") }
}
public final class L_blockchain_ux_type_story_entry: L, I_blockchain_ux_type_story_entry {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.story.entry", comment: "") }
}
public protocol I_blockchain_ux_type_story_entry: I_blockchain_ux_type_task {}
public final class L_blockchain_ux_type_task: L, I_blockchain_ux_type_task {
	public override class var localized: String { NSLocalizedString("blockchain.ux.type.task", comment: "") }
}
public protocol I_blockchain_ux_type_task: I_blockchain_ui_type_task {}
public final class L_blockchain_ux_user: L, I_blockchain_ux_user {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user", comment: "") }
}
public protocol I_blockchain_ux_user: I {}
public extension I_blockchain_ux_user {
	var `account`: L_blockchain_ux_user_account { .init("\(__).account") }
	var `activity`: L_blockchain_ux_user_activity { .init("\(__).activity") }
	var `assets`: L_blockchain_ux_user_assets { .init("\(__).assets") }
	var `authentication`: L_blockchain_ux_user_authentication { .init("\(__).authentication") }
	var `event`: L_blockchain_ux_user_event { .init("\(__).event") }
	var `experiments`: L_blockchain_ux_user_experiments { .init("\(__).experiments") }
	var `KYC`: L_blockchain_ux_user_KYC { .init("\(__).KYC") }
	var `nabu`: L_blockchain_ux_user_nabu { .init("\(__).nabu") }
	var `portfolio`: L_blockchain_ux_user_portfolio { .init("\(__).portfolio") }
	var `rewards`: L_blockchain_ux_user_rewards { .init("\(__).rewards") }
}
public final class L_blockchain_ux_user_account: L, I_blockchain_ux_user_account {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account", comment: "") }
}
public protocol I_blockchain_ux_user_account: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_account {
	var `airdrops`: L_blockchain_ux_user_account_airdrops { .init("\(__).airdrops") }
	var `connect`: L_blockchain_ux_user_account_connect { .init("\(__).connect") }
	var `currency`: L_blockchain_ux_user_account_currency { .init("\(__).currency") }
	var `help`: L_blockchain_ux_user_account_help { .init("\(__).help") }
	var `linked`: L_blockchain_ux_user_account_linked { .init("\(__).linked") }
	var `notification`: L_blockchain_ux_user_account_notification { .init("\(__).notification") }
	var `preferences`: L_blockchain_ux_user_account_preferences { .init("\(__).preferences") }
	var `profile`: L_blockchain_ux_user_account_profile { .init("\(__).profile") }
	var `rate`: L_blockchain_ux_user_account_rate { .init("\(__).rate") }
	var `security`: L_blockchain_ux_user_account_security { .init("\(__).security") }
	var `sign`: L_blockchain_ux_user_account_sign { .init("\(__).sign") }
	var `web`: L_blockchain_ux_user_account_web { .init("\(__).web") }
}
public final class L_blockchain_ux_user_account_airdrops: L, I_blockchain_ux_user_account_airdrops {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.airdrops", comment: "") }
}
public protocol I_blockchain_ux_user_account_airdrops: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_connect: L, I_blockchain_ux_user_account_connect {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.connect", comment: "") }
}
public protocol I_blockchain_ux_user_account_connect: I {}
public extension I_blockchain_ux_user_account_connect {
	var `with`: L_blockchain_ux_user_account_connect_with { .init("\(__).with") }
}
public final class L_blockchain_ux_user_account_connect_with: L, I_blockchain_ux_user_account_connect_with {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.connect.with", comment: "") }
}
public protocol I_blockchain_ux_user_account_connect_with: I {}
public extension I_blockchain_ux_user_account_connect_with {
	var `exchange`: L_blockchain_ux_user_account_connect_with_exchange { .init("\(__).exchange") }
}
public final class L_blockchain_ux_user_account_connect_with_exchange: L, I_blockchain_ux_user_account_connect_with_exchange {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.connect.with.exchange", comment: "") }
}
public protocol I_blockchain_ux_user_account_connect_with_exchange: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_account_connect_with_exchange {
	var `connect`: L_blockchain_ux_user_account_connect_with_exchange_connect { .init("\(__).connect") }
}
public final class L_blockchain_ux_user_account_connect_with_exchange_connect: L, I_blockchain_ux_user_account_connect_with_exchange_connect {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.connect.with.exchange.connect", comment: "") }
}
public protocol I_blockchain_ux_user_account_connect_with_exchange_connect: I {}
public final class L_blockchain_ux_user_account_currency: L, I_blockchain_ux_user_account_currency {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.currency", comment: "") }
}
public protocol I_blockchain_ux_user_account_currency: I {}
public extension I_blockchain_ux_user_account_currency {
	var `native`: L_blockchain_ux_user_account_currency_native { .init("\(__).native") }
	var `trading`: L_blockchain_ux_user_account_currency_trading { .init("\(__).trading") }
}
public final class L_blockchain_ux_user_account_currency_native: L, I_blockchain_ux_user_account_currency_native {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.currency.native", comment: "") }
}
public protocol I_blockchain_ux_user_account_currency_native: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_account_currency_native {
	var `select`: L_blockchain_ux_user_account_currency_native_select { .init("\(__).select") }
}
public final class L_blockchain_ux_user_account_currency_native_select: L, I_blockchain_ux_user_account_currency_native_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.currency.native.select", comment: "") }
}
public protocol I_blockchain_ux_user_account_currency_native_select: I {}
public final class L_blockchain_ux_user_account_currency_trading: L, I_blockchain_ux_user_account_currency_trading {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.currency.trading", comment: "") }
}
public protocol I_blockchain_ux_user_account_currency_trading: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_account_currency_trading {
	var `select`: L_blockchain_ux_user_account_currency_trading_select { .init("\(__).select") }
}
public final class L_blockchain_ux_user_account_currency_trading_select: L, I_blockchain_ux_user_account_currency_trading_select {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.currency.trading.select", comment: "") }
}
public protocol I_blockchain_ux_user_account_currency_trading_select: I {}
public final class L_blockchain_ux_user_account_help: L, I_blockchain_ux_user_account_help {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.help", comment: "") }
}
public protocol I_blockchain_ux_user_account_help: I {}
public extension I_blockchain_ux_user_account_help {
	var `contact`: L_blockchain_ux_user_account_help_contact { .init("\(__).contact") }
	var `policy`: L_blockchain_ux_user_account_help_policy { .init("\(__).policy") }
	var `terms_and_conditions`: L_blockchain_ux_user_account_help_terms__and__conditions { .init("\(__).terms_and_conditions") }
}
public final class L_blockchain_ux_user_account_help_contact: L, I_blockchain_ux_user_account_help_contact {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.help.contact", comment: "") }
}
public protocol I_blockchain_ux_user_account_help_contact: I {}
public extension I_blockchain_ux_user_account_help_contact {
	var `support`: L_blockchain_ux_user_account_help_contact_support { .init("\(__).support") }
}
public final class L_blockchain_ux_user_account_help_contact_support: L, I_blockchain_ux_user_account_help_contact_support {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.help.contact.support", comment: "") }
}
public protocol I_blockchain_ux_user_account_help_contact_support: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_help_policy: L, I_blockchain_ux_user_account_help_policy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.help.policy", comment: "") }
}
public protocol I_blockchain_ux_user_account_help_policy: I {}
public extension I_blockchain_ux_user_account_help_policy {
	var `cookie`: L_blockchain_ux_user_account_help_policy_cookie { .init("\(__).cookie") }
	var `privacy`: L_blockchain_ux_user_account_help_policy_privacy { .init("\(__).privacy") }
}
public final class L_blockchain_ux_user_account_help_policy_cookie: L, I_blockchain_ux_user_account_help_policy_cookie {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.help.policy.cookie", comment: "") }
}
public protocol I_blockchain_ux_user_account_help_policy_cookie: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_help_policy_privacy: L, I_blockchain_ux_user_account_help_policy_privacy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.help.policy.privacy", comment: "") }
}
public protocol I_blockchain_ux_user_account_help_policy_privacy: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_help_terms__and__conditions: L, I_blockchain_ux_user_account_help_terms__and__conditions {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.help.terms_and_conditions", comment: "") }
}
public protocol I_blockchain_ux_user_account_help_terms__and__conditions: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_linked: L, I_blockchain_ux_user_account_linked {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.linked", comment: "") }
}
public protocol I_blockchain_ux_user_account_linked: I {}
public extension I_blockchain_ux_user_account_linked {
	var `accounts`: L_blockchain_ux_user_account_linked_accounts { .init("\(__).accounts") }
}
public final class L_blockchain_ux_user_account_linked_accounts: L, I_blockchain_ux_user_account_linked_accounts {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.linked.accounts", comment: "") }
}
public protocol I_blockchain_ux_user_account_linked_accounts: I {}
public extension I_blockchain_ux_user_account_linked_accounts {
	var `add`: L_blockchain_ux_user_account_linked_accounts_add { .init("\(__).add") }
}
public final class L_blockchain_ux_user_account_linked_accounts_add: L, I_blockchain_ux_user_account_linked_accounts_add {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.linked.accounts.add", comment: "") }
}
public protocol I_blockchain_ux_user_account_linked_accounts_add: I {}
public extension I_blockchain_ux_user_account_linked_accounts_add {
	var `new`: L_blockchain_ux_user_account_linked_accounts_add_new { .init("\(__).new") }
}
public final class L_blockchain_ux_user_account_linked_accounts_add_new: L, I_blockchain_ux_user_account_linked_accounts_add_new {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.linked.accounts.add.new", comment: "") }
}
public protocol I_blockchain_ux_user_account_linked_accounts_add_new: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_notification: L, I_blockchain_ux_user_account_notification {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.notification", comment: "") }
}
public protocol I_blockchain_ux_user_account_notification: I {}
public extension I_blockchain_ux_user_account_notification {
	var `email`: L_blockchain_ux_user_account_notification_email { .init("\(__).email") }
	var `push`: L_blockchain_ux_user_account_notification_push { .init("\(__).push") }
}
public final class L_blockchain_ux_user_account_notification_email: L, I_blockchain_ux_user_account_notification_email {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.notification.email", comment: "") }
}
public protocol I_blockchain_ux_user_account_notification_email: I {}
public final class L_blockchain_ux_user_account_notification_push: L, I_blockchain_ux_user_account_notification_push {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.notification.push", comment: "") }
}
public protocol I_blockchain_ux_user_account_notification_push: I {}
public final class L_blockchain_ux_user_account_preferences: L, I_blockchain_ux_user_account_preferences {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.preferences", comment: "") }
}
public protocol I_blockchain_ux_user_account_preferences: I {}
public extension I_blockchain_ux_user_account_preferences {
	var `small`: L_blockchain_ux_user_account_preferences_small { .init("\(__).small") }
}
public final class L_blockchain_ux_user_account_preferences_small: L, I_blockchain_ux_user_account_preferences_small {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.preferences.small", comment: "") }
}
public protocol I_blockchain_ux_user_account_preferences_small: I {}
public extension I_blockchain_ux_user_account_preferences_small {
	var `balances`: L_blockchain_ux_user_account_preferences_small_balances { .init("\(__).balances") }
}
public final class L_blockchain_ux_user_account_preferences_small_balances: L, I_blockchain_ux_user_account_preferences_small_balances {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.preferences.small.balances", comment: "") }
}
public protocol I_blockchain_ux_user_account_preferences_small_balances: I {}
public extension I_blockchain_ux_user_account_preferences_small_balances {
	var `are`: L_blockchain_ux_user_account_preferences_small_balances_are { .init("\(__).are") }
}
public final class L_blockchain_ux_user_account_preferences_small_balances_are: L, I_blockchain_ux_user_account_preferences_small_balances_are {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.preferences.small.balances.are", comment: "") }
}
public protocol I_blockchain_ux_user_account_preferences_small_balances_are: I {}
public extension I_blockchain_ux_user_account_preferences_small_balances_are {
	var `hidden`: L_blockchain_ux_user_account_preferences_small_balances_are_hidden { .init("\(__).hidden") }
}
public final class L_blockchain_ux_user_account_preferences_small_balances_are_hidden: L, I_blockchain_ux_user_account_preferences_small_balances_are_hidden {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.preferences.small.balances.are.hidden", comment: "") }
}
public protocol I_blockchain_ux_user_account_preferences_small_balances_are_hidden: I_blockchain_db_type_boolean, I_blockchain_session_state_preference_value {}
public final class L_blockchain_ux_user_account_profile: L, I_blockchain_ux_user_account_profile {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile: I {}
public extension I_blockchain_ux_user_account_profile {
	var `email`: L_blockchain_ux_user_account_profile_email { .init("\(__).email") }
	var `limits`: L_blockchain_ux_user_account_profile_limits { .init("\(__).limits") }
	var `mobile`: L_blockchain_ux_user_account_profile_mobile { .init("\(__).mobile") }
	var `wallet`: L_blockchain_ux_user_account_profile_wallet { .init("\(__).wallet") }
}
public final class L_blockchain_ux_user_account_profile_email: L, I_blockchain_ux_user_account_profile_email {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.email", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_email: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_account_profile_email {
	var `change`: L_blockchain_ux_user_account_profile_email_change { .init("\(__).change") }
}
public final class L_blockchain_ux_user_account_profile_email_change: L, I_blockchain_ux_user_account_profile_email_change {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.email.change", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_email_change: I {}
public final class L_blockchain_ux_user_account_profile_limits: L, I_blockchain_ux_user_account_profile_limits {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.limits", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_limits: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_profile_mobile: L, I_blockchain_ux_user_account_profile_mobile {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.mobile", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_mobile: I {}
public extension I_blockchain_ux_user_account_profile_mobile {
	var `number`: L_blockchain_ux_user_account_profile_mobile_number { .init("\(__).number") }
}
public final class L_blockchain_ux_user_account_profile_mobile_number: L, I_blockchain_ux_user_account_profile_mobile_number {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.mobile.number", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_mobile_number: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_account_profile_mobile_number {
	var `verify`: L_blockchain_ux_user_account_profile_mobile_number_verify { .init("\(__).verify") }
}
public final class L_blockchain_ux_user_account_profile_mobile_number_verify: L, I_blockchain_ux_user_account_profile_mobile_number_verify {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.mobile.number.verify", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_mobile_number_verify: I {}
public final class L_blockchain_ux_user_account_profile_wallet: L, I_blockchain_ux_user_account_profile_wallet {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.wallet", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_wallet: I {}
public extension I_blockchain_ux_user_account_profile_wallet {
	var `id`: L_blockchain_ux_user_account_profile_wallet_id { .init("\(__).id") }
}
public final class L_blockchain_ux_user_account_profile_wallet_id: L, I_blockchain_ux_user_account_profile_wallet_id {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.wallet.id", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_wallet_id: I {}
public extension I_blockchain_ux_user_account_profile_wallet_id {
	var `copy`: L_blockchain_ux_user_account_profile_wallet_id_copy { .init("\(__).copy") }
}
public final class L_blockchain_ux_user_account_profile_wallet_id_copy: L, I_blockchain_ux_user_account_profile_wallet_id_copy {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.profile.wallet.id.copy", comment: "") }
}
public protocol I_blockchain_ux_user_account_profile_wallet_id_copy: I {}
public final class L_blockchain_ux_user_account_rate: L, I_blockchain_ux_user_account_rate {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.rate", comment: "") }
}
public protocol I_blockchain_ux_user_account_rate: I {}
public extension I_blockchain_ux_user_account_rate {
	var `the`: L_blockchain_ux_user_account_rate_the { .init("\(__).the") }
}
public final class L_blockchain_ux_user_account_rate_the: L, I_blockchain_ux_user_account_rate_the {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.rate.the", comment: "") }
}
public protocol I_blockchain_ux_user_account_rate_the: I {}
public extension I_blockchain_ux_user_account_rate_the {
	var `app`: L_blockchain_ux_user_account_rate_the_app { .init("\(__).app") }
}
public final class L_blockchain_ux_user_account_rate_the_app: L, I_blockchain_ux_user_account_rate_the_app {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.rate.the.app", comment: "") }
}
public protocol I_blockchain_ux_user_account_rate_the_app: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_security: L, I_blockchain_ux_user_account_security {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security", comment: "") }
}
public protocol I_blockchain_ux_user_account_security: I {}
public extension I_blockchain_ux_user_account_security {
	var `backup`: L_blockchain_ux_user_account_security_backup { .init("\(__).backup") }
	var `biometric`: L_blockchain_ux_user_account_security_biometric { .init("\(__).biometric") }
	var `change`: L_blockchain_ux_user_account_security_change { .init("\(__).change") }
	var `cloud`: L_blockchain_ux_user_account_security_cloud { .init("\(__).cloud") }
	var `synchronize`: L_blockchain_ux_user_account_security_synchronize { .init("\(__).synchronize") }
	var `two_factor_authentication`: L_blockchain_ux_user_account_security_two__factor__authentication { .init("\(__).two_factor_authentication") }
}
public final class L_blockchain_ux_user_account_security_backup: L, I_blockchain_ux_user_account_security_backup {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.backup", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_backup: I {}
public extension I_blockchain_ux_user_account_security_backup {
	var `phrase`: L_blockchain_ux_user_account_security_backup_phrase { .init("\(__).phrase") }
}
public final class L_blockchain_ux_user_account_security_backup_phrase: L, I_blockchain_ux_user_account_security_backup_phrase {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.backup.phrase", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_backup_phrase: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_account_security_backup_phrase {
	var `verify`: L_blockchain_ux_user_account_security_backup_phrase_verify { .init("\(__).verify") }
	var `view`: L_blockchain_ux_user_account_security_backup_phrase_view { .init("\(__).view") }
	var `warning`: L_blockchain_ux_user_account_security_backup_phrase_warning { .init("\(__).warning") }
}
public final class L_blockchain_ux_user_account_security_backup_phrase_verify: L, I_blockchain_ux_user_account_security_backup_phrase_verify {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.backup.phrase.verify", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_backup_phrase_verify: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_security_backup_phrase_view: L, I_blockchain_ux_user_account_security_backup_phrase_view {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.backup.phrase.view", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_backup_phrase_view: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_security_backup_phrase_warning: L, I_blockchain_ux_user_account_security_backup_phrase_warning {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.backup.phrase.warning", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_backup_phrase_warning: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_security_biometric: L, I_blockchain_ux_user_account_security_biometric {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.biometric", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_biometric: I {}
public final class L_blockchain_ux_user_account_security_change: L, I_blockchain_ux_user_account_security_change {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.change", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_change: I {}
public extension I_blockchain_ux_user_account_security_change {
	var `password`: L_blockchain_ux_user_account_security_change_password { .init("\(__).password") }
	var `pin`: L_blockchain_ux_user_account_security_change_pin { .init("\(__).pin") }
}
public final class L_blockchain_ux_user_account_security_change_password: L, I_blockchain_ux_user_account_security_change_password {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.change.password", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_change_password: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_security_change_pin: L, I_blockchain_ux_user_account_security_change_pin {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.change.pin", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_change_pin: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_account_security_cloud: L, I_blockchain_ux_user_account_security_cloud {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.cloud", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_cloud: I {}
public extension I_blockchain_ux_user_account_security_cloud {
	var `backup`: L_blockchain_ux_user_account_security_cloud_backup { .init("\(__).backup") }
}
public final class L_blockchain_ux_user_account_security_cloud_backup: L, I_blockchain_ux_user_account_security_cloud_backup {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.cloud.backup", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_cloud_backup: I {}
public extension I_blockchain_ux_user_account_security_cloud_backup {
	var `enable`: L_blockchain_ux_user_account_security_cloud_backup_enable { .init("\(__).enable") }
}
public final class L_blockchain_ux_user_account_security_cloud_backup_enable: L, I_blockchain_ux_user_account_security_cloud_backup_enable {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.cloud.backup.enable", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_cloud_backup_enable: I {}
public final class L_blockchain_ux_user_account_security_synchronize: L, I_blockchain_ux_user_account_security_synchronize {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.synchronize", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_synchronize: I {}
public extension I_blockchain_ux_user_account_security_synchronize {
	var `widget`: L_blockchain_ux_user_account_security_synchronize_widget { .init("\(__).widget") }
}
public final class L_blockchain_ux_user_account_security_synchronize_widget: L, I_blockchain_ux_user_account_security_synchronize_widget {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.synchronize.widget", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_synchronize_widget: I {}
public final class L_blockchain_ux_user_account_security_two__factor__authentication: L, I_blockchain_ux_user_account_security_two__factor__authentication {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.two_factor_authentication", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_two__factor__authentication: I {}
public extension I_blockchain_ux_user_account_security_two__factor__authentication {
	var `add`: L_blockchain_ux_user_account_security_two__factor__authentication_add { .init("\(__).add") }
	var `remove`: L_blockchain_ux_user_account_security_two__factor__authentication_remove { .init("\(__).remove") }
}
public final class L_blockchain_ux_user_account_security_two__factor__authentication_add: L, I_blockchain_ux_user_account_security_two__factor__authentication_add {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.two_factor_authentication.add", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_two__factor__authentication_add: I {}
public final class L_blockchain_ux_user_account_security_two__factor__authentication_remove: L, I_blockchain_ux_user_account_security_two__factor__authentication_remove {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.security.two_factor_authentication.remove", comment: "") }
}
public protocol I_blockchain_ux_user_account_security_two__factor__authentication_remove: I {}
public final class L_blockchain_ux_user_account_sign: L, I_blockchain_ux_user_account_sign {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.sign", comment: "") }
}
public protocol I_blockchain_ux_user_account_sign: I {}
public extension I_blockchain_ux_user_account_sign {
	var `out`: L_blockchain_ux_user_account_sign_out { .init("\(__).out") }
}
public final class L_blockchain_ux_user_account_sign_out: L, I_blockchain_ux_user_account_sign_out {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.sign.out", comment: "") }
}
public protocol I_blockchain_ux_user_account_sign_out: I {}
public final class L_blockchain_ux_user_account_web: L, I_blockchain_ux_user_account_web {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.web", comment: "") }
}
public protocol I_blockchain_ux_user_account_web: I {}
public extension I_blockchain_ux_user_account_web {
	var `login`: L_blockchain_ux_user_account_web_login { .init("\(__).login") }
}
public final class L_blockchain_ux_user_account_web_login: L, I_blockchain_ux_user_account_web_login {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.account.web.login", comment: "") }
}
public protocol I_blockchain_ux_user_account_web_login: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_activity: L, I_blockchain_ux_user_activity {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.activity", comment: "") }
}
public protocol I_blockchain_ux_user_activity: I {}
public extension I_blockchain_ux_user_activity {
	var `all`: L_blockchain_ux_user_activity_all { .init("\(__).all") }
}
public final class L_blockchain_ux_user_activity_all: L, I_blockchain_ux_user_activity_all {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.activity.all", comment: "") }
}
public protocol I_blockchain_ux_user_activity_all: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_activity_all {
	var `model`: L_blockchain_ux_user_activity_all_model { .init("\(__).model") }
}
public final class L_blockchain_ux_user_activity_all_model: L, I_blockchain_ux_user_activity_all_model {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.activity.all.model", comment: "") }
}
public protocol I_blockchain_ux_user_activity_all_model: I {}
public final class L_blockchain_ux_user_assets: L, I_blockchain_ux_user_assets {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.assets", comment: "") }
}
public protocol I_blockchain_ux_user_assets: I {}
public extension I_blockchain_ux_user_assets {
	var `all`: L_blockchain_ux_user_assets_all { .init("\(__).all") }
}
public final class L_blockchain_ux_user_assets_all: L, I_blockchain_ux_user_assets_all {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.assets.all", comment: "") }
}
public protocol I_blockchain_ux_user_assets_all: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_assets_all {
	var `model`: L_blockchain_ux_user_assets_all_model { .init("\(__).model") }
}
public final class L_blockchain_ux_user_assets_all_model: L, I_blockchain_ux_user_assets_all_model {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.assets.all.model", comment: "") }
}
public protocol I_blockchain_ux_user_assets_all_model: I {}
public final class L_blockchain_ux_user_authentication: L, I_blockchain_ux_user_authentication {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication", comment: "") }
}
public protocol I_blockchain_ux_user_authentication: I {}
public extension I_blockchain_ux_user_authentication {
	var `sign`: L_blockchain_ux_user_authentication_sign { .init("\(__).sign") }
}
public final class L_blockchain_ux_user_authentication_sign: L, I_blockchain_ux_user_authentication_sign {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign: I {}
public extension I_blockchain_ux_user_authentication_sign {
	var `in`: L_blockchain_ux_user_authentication_sign_in { .init("\(__).in") }
	var `up`: L_blockchain_ux_user_authentication_sign_up { .init("\(__).up") }
}
public final class L_blockchain_ux_user_authentication_sign_in: L, I_blockchain_ux_user_authentication_sign_in {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.in", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_in: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_authentication_sign_in {
	var `continue`: L_blockchain_ux_user_authentication_sign_in_continue { .init("\(__).continue") }
	var `did`: L_blockchain_ux_user_authentication_sign_in_did { .init("\(__).did") }
	var `enter`: L_blockchain_ux_user_authentication_sign_in_enter { .init("\(__).enter") }
	var `unlock`: L_blockchain_ux_user_authentication_sign_in_unlock { .init("\(__).unlock") }
}
public final class L_blockchain_ux_user_authentication_sign_in_continue: L, I_blockchain_ux_user_authentication_sign_in_continue {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.in.continue", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_in_continue: I_blockchain_ui_type_button_primary {}
public final class L_blockchain_ux_user_authentication_sign_in_did: L, I_blockchain_ux_user_authentication_sign_in_did {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.in.did", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_in_did: I {}
public extension I_blockchain_ux_user_authentication_sign_in_did {
	var `fail`: L_blockchain_ux_user_authentication_sign_in_did_fail { .init("\(__).fail") }
	var `succeed`: L_blockchain_ux_user_authentication_sign_in_did_succeed { .init("\(__).succeed") }
}
public final class L_blockchain_ux_user_authentication_sign_in_did_fail: L, I_blockchain_ux_user_authentication_sign_in_did_fail {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.in.did.fail", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_in_did_fail: I_blockchain_ux_type_analytics_event {}
public extension I_blockchain_ux_user_authentication_sign_in_did_fail {
	var `error`: L_blockchain_ux_user_authentication_sign_in_did_fail_error { .init("\(__).error") }
}
public final class L_blockchain_ux_user_authentication_sign_in_did_fail_error: L, I_blockchain_ux_user_authentication_sign_in_did_fail_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.in.did.fail.error", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_in_did_fail_error: I_blockchain_db_type_any {}
public final class L_blockchain_ux_user_authentication_sign_in_did_succeed: L, I_blockchain_ux_user_authentication_sign_in_did_succeed {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.in.did.succeed", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_in_did_succeed: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_user_authentication_sign_in_enter: L, I_blockchain_ux_user_authentication_sign_in_enter {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.in.enter", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_in_enter: I {}
public extension I_blockchain_ux_user_authentication_sign_in_enter {
	var `pin`: L_blockchain_ux_user_authentication_sign_in_enter_pin { .init("\(__).pin") }
}
public final class L_blockchain_ux_user_authentication_sign_in_enter_pin: L, I_blockchain_ux_user_authentication_sign_in_enter_pin {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.in.enter.pin", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_in_enter_pin: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_authentication_sign_in_unlock: L, I_blockchain_ux_user_authentication_sign_in_unlock {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.in.unlock", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_in_unlock: I {}
public extension I_blockchain_ux_user_authentication_sign_in_unlock {
	var `wallet`: L_blockchain_ux_user_authentication_sign_in_unlock_wallet { .init("\(__).wallet") }
}
public final class L_blockchain_ux_user_authentication_sign_in_unlock_wallet: L, I_blockchain_ux_user_authentication_sign_in_unlock_wallet {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.in.unlock.wallet", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_in_unlock_wallet: I {}
public extension I_blockchain_ux_user_authentication_sign_in_unlock_wallet {
	var `password`: L_blockchain_ux_user_authentication_sign_in_unlock_wallet_password { .init("\(__).password") }
}
public final class L_blockchain_ux_user_authentication_sign_in_unlock_wallet_password: L, I_blockchain_ux_user_authentication_sign_in_unlock_wallet_password {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.in.unlock.wallet.password", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_in_unlock_wallet_password: I {}
public extension I_blockchain_ux_user_authentication_sign_in_unlock_wallet_password {
	var `required`: L_blockchain_ux_user_authentication_sign_in_unlock_wallet_password_required { .init("\(__).required") }
}
public final class L_blockchain_ux_user_authentication_sign_in_unlock_wallet_password_required: L, I_blockchain_ux_user_authentication_sign_in_unlock_wallet_password_required {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.in.unlock.wallet.password.required", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_in_unlock_wallet_password_required: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_authentication_sign_up: L, I_blockchain_ux_user_authentication_sign_up {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.up", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_up: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_user_authentication_sign_up {
	var `create`: L_blockchain_ux_user_authentication_sign_up_create { .init("\(__).create") }
	var `did`: L_blockchain_ux_user_authentication_sign_up_did { .init("\(__).did") }
}
public final class L_blockchain_ux_user_authentication_sign_up_create: L, I_blockchain_ux_user_authentication_sign_up_create {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.up.create", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_up_create: I_blockchain_ui_type_button_primary {}
public final class L_blockchain_ux_user_authentication_sign_up_did: L, I_blockchain_ux_user_authentication_sign_up_did {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.up.did", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_up_did: I {}
public extension I_blockchain_ux_user_authentication_sign_up_did {
	var `fail`: L_blockchain_ux_user_authentication_sign_up_did_fail { .init("\(__).fail") }
	var `succeed`: L_blockchain_ux_user_authentication_sign_up_did_succeed { .init("\(__).succeed") }
}
public final class L_blockchain_ux_user_authentication_sign_up_did_fail: L, I_blockchain_ux_user_authentication_sign_up_did_fail {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.up.did.fail", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_up_did_fail: I_blockchain_ux_type_analytics_event {}
public extension I_blockchain_ux_user_authentication_sign_up_did_fail {
	var `error`: L_blockchain_ux_user_authentication_sign_up_did_fail_error { .init("\(__).error") }
}
public final class L_blockchain_ux_user_authentication_sign_up_did_fail_error: L, I_blockchain_ux_user_authentication_sign_up_did_fail_error {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.up.did.fail.error", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_up_did_fail_error: I_blockchain_db_type_any {}
public final class L_blockchain_ux_user_authentication_sign_up_did_succeed: L, I_blockchain_ux_user_authentication_sign_up_did_succeed {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.authentication.sign.up.did.succeed", comment: "") }
}
public protocol I_blockchain_ux_user_authentication_sign_up_did_succeed: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_user_event: L, I_blockchain_ux_user_event {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.event", comment: "") }
}
public protocol I_blockchain_ux_user_event: I {}
public extension I_blockchain_ux_user_event {
	var `authenticated`: L_blockchain_ux_user_event_authenticated { .init("\(__).authenticated") }
}
public final class L_blockchain_ux_user_event_authenticated: L, I_blockchain_ux_user_event_authenticated {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.event.authenticated", comment: "") }
}
public protocol I_blockchain_ux_user_event_authenticated: I {}
public extension I_blockchain_ux_user_event_authenticated {
	var `pin`: L_blockchain_ux_user_event_authenticated_pin { .init("\(__).pin") }
}
public final class L_blockchain_ux_user_event_authenticated_pin: L, I_blockchain_ux_user_event_authenticated_pin {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.event.authenticated.pin", comment: "") }
}
public protocol I_blockchain_ux_user_event_authenticated_pin: I_blockchain_ux_type_analytics_event {}
public final class L_blockchain_ux_user_experiments: L, I_blockchain_ux_user_experiments {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.experiments", comment: "") }
}
public protocol I_blockchain_ux_user_experiments: I {}
public extension I_blockchain_ux_user_experiments {
	var `is`: L_blockchain_ux_user_experiments_is { .init("\(__).is") }
}
public final class L_blockchain_ux_user_experiments_is: L, I_blockchain_ux_user_experiments_is {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.experiments.is", comment: "") }
}
public protocol I_blockchain_ux_user_experiments_is: I {}
public extension I_blockchain_ux_user_experiments_is {
	var `enabled`: L_blockchain_ux_user_experiments_is_enabled { .init("\(__).enabled") }
}
public final class L_blockchain_ux_user_experiments_is_enabled: L, I_blockchain_ux_user_experiments_is_enabled {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.experiments.is.enabled", comment: "") }
}
public protocol I_blockchain_ux_user_experiments_is_enabled: I_blockchain_session_configuration_value {}
public final class L_blockchain_ux_user_KYC: L, I_blockchain_ux_user_KYC {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.KYC", comment: "") }
}
public protocol I_blockchain_ux_user_KYC: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_nabu: L, I_blockchain_ux_user_nabu {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.nabu", comment: "") }
}
public protocol I_blockchain_ux_user_nabu: I {}
public extension I_blockchain_ux_user_nabu {
	var `experiment`: L_blockchain_ux_user_nabu_experiment { .init("\(__).experiment") }
	var `experiments`: L_blockchain_ux_user_nabu_experiments { .init("\(__).experiments") }
}
public final class L_blockchain_ux_user_nabu_experiment: L, I_blockchain_ux_user_nabu_experiment {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.nabu.experiment", comment: "") }
}
public protocol I_blockchain_ux_user_nabu_experiment: I_blockchain_db_collection {}
public extension I_blockchain_ux_user_nabu_experiment {
	var `group`: L_blockchain_ux_user_nabu_experiment_group { .init("\(__).group") }
}
public final class L_blockchain_ux_user_nabu_experiment_group: L, I_blockchain_ux_user_nabu_experiment_group {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.nabu.experiment.group", comment: "") }
}
public protocol I_blockchain_ux_user_nabu_experiment_group: I_blockchain_db_type_integer, I_blockchain_session_state_value {}
public final class L_blockchain_ux_user_nabu_experiments: L, I_blockchain_ux_user_nabu_experiments {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.nabu.experiments", comment: "") }
}
public protocol I_blockchain_ux_user_nabu_experiments: I_blockchain_db_type_array_of_strings, I_blockchain_session_state_value {}
public final class L_blockchain_ux_user_portfolio: L, I_blockchain_ux_user_portfolio {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.portfolio", comment: "") }
}
public protocol I_blockchain_ux_user_portfolio: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_user_rewards: L, I_blockchain_ux_user_rewards {
	public override class var localized: String { NSLocalizedString("blockchain.ux.user.rewards", comment: "") }
}
public protocol I_blockchain_ux_user_rewards: I_blockchain_ux_type_story {}
public final class L_blockchain_ux_web: L, I_blockchain_ux_web {
	public override class var localized: String { NSLocalizedString("blockchain.ux.web", comment: "") }
}
public protocol I_blockchain_ux_web: I_blockchain_db_collection, I_blockchain_ux_type_story {}
public final class L_blockchain_ux_withdrawal: L, I_blockchain_ux_withdrawal {
	public override class var localized: String { NSLocalizedString("blockchain.ux.withdrawal", comment: "") }
}
public protocol I_blockchain_ux_withdrawal: I {}
public extension I_blockchain_ux_withdrawal {
	var `locks`: L_blockchain_ux_withdrawal_locks { .init("\(__).locks") }
}
public final class L_blockchain_ux_withdrawal_locks: L, I_blockchain_ux_withdrawal_locks {
	public override class var localized: String { NSLocalizedString("blockchain.ux.withdrawal.locks", comment: "") }
}
public protocol I_blockchain_ux_withdrawal_locks: I_blockchain_ux_type_story {}
public extension I_blockchain_ux_withdrawal_locks {
	var `info`: L_blockchain_ux_withdrawal_locks_info { .init("\(__).info") }
}
public final class L_blockchain_ux_withdrawal_locks_info: L, I_blockchain_ux_withdrawal_locks_info {
	public override class var localized: String { NSLocalizedString("blockchain.ux.withdrawal.locks.info", comment: "") }
}
public protocol I_blockchain_ux_withdrawal_locks_info: I_blockchain_db_type_any {}