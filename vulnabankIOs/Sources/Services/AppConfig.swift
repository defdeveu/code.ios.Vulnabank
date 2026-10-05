import Foundation

struct AppConfig: Equatable, Sendable {
    let endpoint: URL

    static func load(from bundle: Bundle = .main) -> AppConfig {
        if let value = bundle.object(forInfoDictionaryKey: "LabVulnaBankURL") as? String,
           let endpoint = URL(string: value) {
            return AppConfig(endpoint: endpoint)
        }
        return AppConfig(endpoint: URL(string: "https://zsk.labs.def.dev/secure-communication/request")!)
    }
}
