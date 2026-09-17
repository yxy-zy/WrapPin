import Foundation

/// Selects only the connection-launch policy. Both modes use the exact same
/// Bonjour discovery, remote-pairing, RSD, developer-session, and location
/// simulation implementations.
enum ConnectionMode: String, CaseIterable, Identifiable {
    case localDevVPN
    case singBoxExperimental = "clashMiExperimental"

    var id: Self { self }

    var title: String {
        switch self {
        case .localDevVPN: String(localized: "Default (LocalDevVPN)")
        case .singBoxExperimental: String(localized: "sing-box Experimental")
        }
    }

    var detail: String {
        switch self {
        case .localDevVPN:
            String(localized: "Keeps the existing LocalDevVPN startup and recovery behavior.")
        case .singBoxExperimental:
            String(localized: "Does not open LocalDevVPN. Tests sing-box's StosVPN-compatible loopback_address without changing Remote Pairing.")
        }
    }
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case automatic
    case light
    case dark

    var id: Self { self }

    var title: String {
        switch self {
        case .automatic: String(localized: "Auto")
        case .light: String(localized: "Light")
        case .dark: String(localized: "Dark")
        }
    }

    var systemImage: String {
        switch self {
        case .automatic: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }
}

enum MapDisplayStyle: String, CaseIterable, Identifiable {
    case standard
    case satellite
    case hybrid

    var id: Self { self }

    var title: String {
        switch self {
        case .standard: String(localized: "Standard")
        case .satellite: String(localized: "Satellite")
        case .hybrid: String(localized: "Hybrid")
        }
    }
}
