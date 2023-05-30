// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/**
 A fiat currency.

 This follows the `ISO 4217` alphabetic currency codes.

 To regenerate this enum, use the following code:

 ```swift
 let locale = NSLocale(localeIdentifier: "en_US")
 var s = "public enum FiatCurrency: String, Currency, Codable, CaseIterable {"
 for currencyCode in NSLocale.isoCurrencyCodes {
     s.append("\n")
     if let description = locale.localizedString(forCurrencyCode: currencyCode) {
         s.append("\n\t/// \(description)")
     }
     s.append("\n\tcase \(currencyCode)")
 }
 s.append("\n}")
 print(s)
 ```
 */
public enum FiatCurrency: String, Currency, Codable, CaseIterable, Equatable {

    /// Andorran Peseta
    case ADP

    /// United Arab Emirates Dirham
    case AED

    /// Afghan Afghani (1927–2002)
    case AFA

    /// Afghan Afghani
    case AFN

    /// Albanian Lek (1946–1965)
    case ALK

    /// Albanian Lek
    case ALL

    /// Armenian Dram
    case AMD

    /// Netherlands Antillean Guilder
    case ANG

    /// Angolan Kwanza
    case AOA

    /// Angolan Kwanza (1977–1991)
    case AOK

    /// Angolan New Kwanza (1990–2000)
    case AON

    /// Angolan Readjusted Kwanza (1995–1999)
    case AOR

    /// Argentine Austral
    case ARA

    /// Argentine Peso Ley (1970–1983)
    case ARL

    /// Argentine Peso (1881–1970)
    case ARM

    /// Argentine Peso (1983–1985)
    case ARP

    /// Argentine Peso
    case ARS

    /// Austrian Schilling
    case ATS

    /// Australian Dollar
    case AUD

    /// Aruban Florin
    case AWG

    /// Azerbaijani Manat (1993–2006)
    case AZM

    /// Azerbaijani Manat
    case AZN

    /// Bosnia-Herzegovina Dinar (1992–1994)
    case BAD

    /// Bosnia-Herzegovina Convertible Mark
    case BAM

    /// Bosnia-Herzegovina New Dinar (1994–1997)
    case BAN

    /// Barbadian Dollar
    case BBD

    /// Bangladeshi Taka
    case BDT

    /// Belgian Franc (convertible)
    case BEC

    /// Belgian Franc
    case BEF

    /// Belgian Franc (financial)
    case BEL

    /// Bulgarian Hard Lev
    case BGL

    /// Bulgarian Socialist Lev
    case BGM

    /// Bulgarian Lev
    case BGN

    /// Bulgarian Lev (1879–1952)
    case BGO

    /// Bahraini Dinar
    case BHD

    /// Burundian Franc
    case BIF

    /// Bermudan Dollar
    case BMD

    /// Brunei Dollar
    case BND

    /// Bolivian Boliviano
    case BOB

    /// Bolivian Boliviano (1863–1963)
    case BOL

    /// Bolivian Peso
    case BOP

    /// Bolivian Mvdol
    case BOV

    /// Brazilian New Cruzeiro (1967–1986)
    case BRB

    /// Brazilian Cruzado (1986–1989)
    case BRC

    /// Brazilian Cruzeiro (1990–1993)
    case BRE

    /// Brazilian Real
    case BRL

    /// Brazilian New Cruzado (1989–1990)
    case BRN

    /// Brazilian Cruzeiro (1993–1994)
    case BRR

    /// Brazilian Cruzeiro (1942–1967)
    case BRZ

    /// Bahamian Dollar
    case BSD

    /// Bhutanese Ngultrum
    case BTN

    /// Burmese Kyat
    case BUK

    /// Botswanan Pula
    case BWP

    /// Belarusian Ruble (1994–1999)
    case BYB

    /// Belarusian Ruble
    case BYN

    /// Belarusian Ruble (2000–2016)
    case BYR

    /// Belize Dollar
    case BZD

    /// Canadian Dollar
    case CAD

    /// Congolese Franc
    case CDF

    /// WIR Euro
    case CHE

    /// Swiss Franc
    case CHF

    /// WIR Franc
    case CHW

    /// Chilean Escudo
    case CLE

    /// Chilean Unit of Account (UF)
    case CLF

    /// Chilean Peso
    case CLP

    /// Chinese Yuan (offshore)
    case CNH

    /// Chinese People’s Bank Dollar
    case CNX

    /// Chinese Yuan
    case CNY

    /// Colombian Peso
    case COP

    /// Colombian Real Value Unit
    case COU

    /// Costa Rican Colón
    case CRC

    /// Serbian Dinar (2002–2006)
    case CSD

    /// Czechoslovak Hard Koruna
    case CSK

    /// Cuban Convertible Peso
    case CUC

    /// Cuban Peso
    case CUP

    /// Cape Verdean Escudo
    case CVE

    /// Cypriot Pound
    case CYP

    /// Czech Koruna
    case CZK

    /// East German Mark
    case DDM

    /// German Mark
    case DEM

    /// Djiboutian Franc
    case DJF

    /// Danish Krone
    case DKK

    /// Dominican Peso
    case DOP

    /// Algerian Dinar
    case DZD

    /// Ecuadorian Sucre
    case ECS

    /// Ecuadorian Unit of Constant Value
    case ECV

    /// Estonian Kroon
    case EEK

    /// Egyptian Pound
    case EGP

    case EQE

    /// Eritrean Nakfa
    case ERN

    /// Spanish Peseta (A account)
    case ESA

    /// Spanish Peseta (convertible account)
    case ESB

    /// Spanish Peseta
    case ESP

    /// Ethiopian Birr
    case ETB

    /// Euro
    case EUR

    /// Finnish Markka
    case FIM

    /// Fijian Dollar
    case FJD

    /// Falkland Islands Pound
    case FKP

    /// French Franc
    case FRF

    /// British Pound
    case GBP

    /// Georgian Kupon Larit
    case GEK

    /// Georgian Lari
    case GEL

    /// Ghanaian Cedi (1979–2007)
    case GHC

    /// Ghanaian Cedi
    case GHS

    /// Gibraltar Pound
    case GIP

    /// Gambian Dalasi
    case GMD

    /// Guinean Franc
    case GNF

    /// Guinean Syli
    case GNS

    /// Equatorial Guinean Ekwele
    case GQE

    /// Greek Drachma
    case GRD

    /// Guatemalan Quetzal
    case GTQ

    /// Portuguese Guinea Escudo
    case GWE

    /// Guinea-Bissau Peso
    case GWP

    /// Guyanaese Dollar
    case GYD

    /// Hong Kong Dollar
    case HKD

    /// Honduran Lempira
    case HNL

    /// Croatian Dinar
    case HRD

    /// Croatian Kuna
    case HRK

    /// Haitian Gourde
    case HTG

    /// Hungarian Forint
    case HUF

    /// Indonesian Rupiah
    case IDR

    /// Irish Pound
    case IEP

    /// Israeli Pound
    case ILP

    /// Israeli Shekel (1980–1985)
    case ILR

    /// Israeli New Shekel
    case ILS

    /// Indian Rupee
    case INR

    /// Iraqi Dinar
    case IQD

    /// Iranian Rial
    case IRR

    /// Icelandic Króna (1918–1981)
    case ISJ

    /// Icelandic Króna
    case ISK

    /// Italian Lira
    case ITL

    /// Jamaican Dollar
    case JMD

    /// Jordanian Dinar
    case JOD

    /// Japanese Yen
    case JPY

    /// Kenyan Shilling
    case KES

    /// Kyrgystani Som
    case KGS

    /// Cambodian Riel
    case KHR

    /// Comorian Franc
    case KMF

    /// North Korean Won
    case KPW

    /// South Korean Hwan (1953–1962)
    case KRH

    /// South Korean Won (1945–1953)
    case KRO

    /// South Korean Won
    case KRW

    /// Kuwaiti Dinar
    case KWD

    /// Cayman Islands Dollar
    case KYD

    /// Kazakhstani Tenge
    case KZT

    /// Laotian Kip
    case LAK

    /// Lebanese Pound
    case LBP

    /// Sri Lankan Rupee
    case LKR

    /// Liberian Dollar
    case LRD

    /// Lesotho Loti
    case LSL

    case LSM

    /// Lithuanian Litas
    case LTL

    /// Lithuanian Talonas
    case LTT

    /// Luxembourgian Convertible Franc
    case LUC

    /// Luxembourgian Franc
    case LUF

    /// Luxembourg Financial Franc
    case LUL

    /// Latvian Lats
    case LVL

    /// Latvian Ruble
    case LVR

    /// Libyan Dinar
    case LYD

    /// Moroccan Dirham
    case MAD

    /// Moroccan Franc
    case MAF

    /// Monegasque Franc
    case MCF

    /// Moldovan Cupon
    case MDC

    /// Moldovan Leu
    case MDL

    /// Malagasy Ariary
    case MGA

    /// Malagasy Franc
    case MGF

    /// Macedonian Denar
    case MKD

    /// Macedonian Denar (1992–1993)
    case MKN

    /// Malian Franc
    case MLF

    /// Myanmar Kyat
    case MMK

    /// Mongolian Tugrik
    case MNT

    /// Macanese Pataca
    case MOP

    /// Mauritanian Ouguiya (1973–2017)
    case MRO

    /// Mauritanian Ouguiya
    case MRU

    /// Maltese Lira
    case MTL

    /// Maltese Pound
    case MTP

    /// Mauritian Rupee
    case MUR

    /// Maldivian Rupee (1947–1981)
    case MVP

    /// Maldivian Rufiyaa
    case MVR

    /// Malawian Kwacha
    case MWK

    /// Mexican Peso
    case MXN

    /// Mexican Silver Peso (1861–1992)
    case MXP

    /// Mexican Investment Unit
    case MXV

    /// Malaysian Ringgit
    case MYR

    /// Mozambican Escudo
    case MZE

    /// Mozambican Metical (1980–2006)
    case MZM

    /// Mozambican Metical
    case MZN

    /// Namibian Dollar
    case NAD

    /// Nigerian Naira
    case NGN

    /// Nicaraguan Córdoba (1988–1991)
    case NIC

    /// Nicaraguan Córdoba
    case NIO

    /// Dutch Guilder
    case NLG

    /// Norwegian Krone
    case NOK

    /// Nepalese Rupee
    case NPR

    /// New Zealand Dollar
    case NZD

    /// Omani Rial
    case OMR

    /// Panamanian Balboa
    case PAB

    /// Peruvian Inti
    case PEI

    /// Peruvian Sol
    case PEN

    /// Peruvian Sol (1863–1965)
    case PES

    /// Papua New Guinean Kina
    case PGK

    /// Philippine Piso
    case PHP

    /// Pakistani Rupee
    case PKR

    /// Polish Zloty
    case PLN

    /// Polish Zloty (1950–1995)
    case PLZ

    /// Portuguese Escudo
    case PTE

    /// Paraguayan Guarani
    case PYG

    /// Qatari Rial
    case QAR

    /// Rhodesian Dollar
    case RHD

    /// Romanian Leu (1952–2006)
    case ROL

    /// Romanian Leu
    case RON

    /// Serbian Dinar
    case RSD

    /// Russian Ruble
    case RUB

    /// Russian Ruble (1991–1998)
    case RUR

    /// Rwandan Franc
    case RWF

    /// Saudi Riyal
    case SAR

    /// Solomon Islands Dollar
    case SBD

    /// Seychellois Rupee
    case SCR

    /// Sudanese Dinar (1992–2007)
    case SDD

    /// Sudanese Pound
    case SDG

    /// Sudanese Pound (1957–1998)
    case SDP

    /// Swedish Krona
    case SEK

    /// Singapore Dollar
    case SGD

    /// St. Helena Pound
    case SHP

    /// Slovenian Tolar
    case SIT

    /// Slovak Koruna
    case SKK

    /// Sierra Leonean Leone
    case SLL

    /// Somali Shilling
    case SOS

    /// Surinamese Dollar
    case SRD

    /// Surinamese Guilder
    case SRG

    /// South Sudanese Pound
    case SSP

    /// São Tomé & Príncipe Dobra (1977–2017)
    case STD

    /// São Tomé & Príncipe Dobra
    case STN

    /// Soviet Rouble
    case SUR

    /// Salvadoran Colón
    case SVC

    /// Syrian Pound
    case SYP

    /// Swazi Lilangeni
    case SZL

    /// Thai Baht
    case THB

    /// Tajikistani Ruble
    case TJR

    /// Tajikistani Somoni
    case TJS

    /// Turkmenistani Manat (1993–2009)
    case TMM

    /// Turkmenistani Manat
    case TMT

    /// Tunisian Dinar
    case TND

    /// Tongan Paʻanga
    case TOP

    /// Timorese Escudo
    case TPE

    /// Turkish Lira (1922–2005)
    case TRL

    /// Turkish Lira
    case TRY

    /// Trinidad & Tobago Dollar
    case TTD

    /// New Taiwan Dollar
    case TWD

    /// Tanzanian Shilling
    case TZS

    /// Ukrainian Hryvnia
    case UAH

    /// Ukrainian Karbovanets
    case UAK

    /// Ugandan Shilling (1966–1987)
    case UGS

    /// Ugandan Shilling
    case UGX

    /// US Dollar
    case USD

    /// US Dollar (Next day)
    case USN

    /// US Dollar (Same day)
    case USS

    /// Uruguayan Peso (Indexed Units)
    case UYI

    /// Uruguayan Peso (1975–1993)
    case UYP

    /// Uruguayan Peso
    case UYU

    /// Uzbekistani Som
    case UZS

    /// Venezuelan Bolívar (1871–2008)
    case VEB

    /// Venezuelan Bolívar (2008–2018)
    case VEF

    /// Vietnamese Dong
    case VND

    /// Vietnamese Dong (1978–1985)
    case VNN

    /// Vanuatu Vatu
    case VUV

    /// Samoan Tala
    case WST

    /// Central African CFA Franc
    case XAF

    /// Silver
    case XAG

    /// Gold
    case XAU

    /// European Composite Unit
    case XBA

    /// European Monetary Unit
    case XBB

    /// European Unit of Account (XBC)
    case XBC

    /// European Unit of Account (XBD)
    case XBD

    /// East Caribbean Dollar
    case XCD

    /// Special Drawing Rights
    case XDR

    /// European Currency Unit
    case XEU

    /// French Gold Franc
    case XFO

    /// French UIC-Franc
    case XFU

    /// West African CFA Franc
    case XOF

    /// Palladium
    case XPD

    /// CFP Franc
    case XPF

    /// Platinum
    case XPT

    /// RINET Funds
    case XRE

    /// Sucre
    case XSU

    /// Testing Currency Code
    case XTS

    /// ADB Unit of Account
    case XUA

    /// Unknown Currency
    case XXX

    /// Yemeni Dinar
    case YDD

    /// Yemeni Rial
    case YER

    /// Yugoslavian Hard Dinar (1966–1990)
    case YUD

    /// Yugoslavian New Dinar (1994–2002)
    case YUM

    /// Yugoslavian Convertible Dinar (1990–1992)
    case YUN

    /// Yugoslavian Reformed Dinar (1992–1993)
    case YUR

    /// South African Rand (financial)
    case ZAL

    /// South African Rand
    case ZAR

    /// Zambian Kwacha (1968–2012)
    case ZMK

    /// Zambian Kwacha
    case ZMW

    /// Zairean New Zaire (1993–1998)
    case ZRN

    /// Zairean Zaire (1971–1993)
    case ZRZ

    /// Zimbabwean Dollar (1980–2008)
    case ZWD

    /// Zimbabwean Dollar (2009)
    case ZWL

    /// Zimbabwean Dollar (2008)
    case ZWR
}

extension FiatCurrency {

    /// The default fiat currency.
    public static let `default` = FiatCurrency.USD

    /// The fiat currency corresponding to the user's current locale. If this is not a valid currency, `default` is returned instead.
    public static var locale: FiatCurrency {
        let locale = NSLocale.current as NSLocale
        guard let code = locale.currencyCode else { return .default }
        return FiatCurrency(code: code) ?? .default
    }
}

// MARK: - Currency

extension FiatCurrency {

    public static let maxDisplayPrecision: Int = allCases.map(\.displayPrecision).max() ?? 0

    public var name: String {
        switch self {
        case .USD:
            return L10n.Fiat.usd
        case .GBP:
            return L10n.Fiat.gbp
        case .EUR:
            return L10n.Fiat.eur
        case .ARS:
            return L10n.Fiat.ars
        case .BRL:
            return L10n.Fiat.brl
        default:
            return currentLocale.localizedString(forCurrencyCode: code) ?? ""
        }
    }

    public var code: String { rawValue }

    public var displayCode: String { code }

    public var displaySymbol: String {
        currentLocale.displayName(forKey: .currencySymbol, value: code) ?? ""
    }

    public var precision: Int {
        switch self {
        case .ADP,
             .AOK,
             .AON,
             .AOR,
             .BIF,
             .BYR,
             .CLP,
             .DJF,
             .ECS,
             .ESP,
             .GEK,
             .GNF,
             .ISK,
             .ITL,
             .JPY,
             .KMF,
             .KRW,
             .MGF,
             .PTE,
             .PYG,
             .ROL,
             .RWF,
             .TJR,
             .TPE,
             .TRL,
             .UGX,
             .UYI,
             .VND,
             .VUV,
             .XAF,
             .XEU,
             .XOF,
             .XPF:
            return 0
        case .BHD,
             .IQD,
             .JOD,
             .KWD,
             .LYD,
             .OMR,
             .TND:
            return 3
        case .CLF:
            return 4
        default:
            return 2
        }
    }

    public var storeExtraPrecision: Int { 8 }

    public var displayPrecision: Int { precision }

    private var currentLocale: NSLocale {
        _currentLocale ?? NSLocale.current as NSLocale
    }

    /// Creates a fiat currency.
    ///
    /// If `code` is invalid, this initializer returns `nil`.
    ///
    /// - Parameter code: A fiat currency code.
    public init?(code: String) {
        self.init(rawValue: code.uppercased())
    }

    public static func == (lhs: FiatCurrency, rhs: FiatCurrency) -> Bool {
        lhs.code == rhs.code
    }
}

@_spi(Test) public var _currentLocale: NSLocale?

extension FiatCurrency {

    public static let allEnabledFiatCurrencies: [FiatCurrency] = [.USD, .EUR, .GBP, .ARS]

    /// The list of fiat currencies supported for ACH.
    static let achCurrencies: [FiatCurrency] = [.USD]

    /// The list of fiat currencies supported for bank wire transfers.
    static let bankWireSupported: [FiatCurrency] = FiatCurrency.allEnabledFiatCurrencies

    /// Whether the current fiat currency is supported for ACH.
    public var isACHSupportedCurrency: Bool {
        FiatCurrency.achCurrencies.contains(self)
    }

    /// Whether the current fiat currency is supported for bank wire transfers.
    public var isBankWireSupportedCurrency: Bool {
        FiatCurrency.bankWireSupported.contains(self)
    }

    /// The list of fiat currencies currently supported.
    public static let supported: [FiatCurrency] = [
        .ARS,
        .AUD,
        .BRL,
        .CAD,
        .CHF,
        .CLP,
        .CNY,
        .DKK,
        .EUR,
        .GBP,
        .HKD,
        .INR,
        .ISK,
        .JPY,
        .KRW,
        .NZD,
        .PLN,
        .RUB,
        .SEK,
        .SGD,
        .THB,
        .TWD,
        .USD
    ]
}
