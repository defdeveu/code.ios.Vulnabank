import Foundation
import Security

struct ApplicationKeys: @unchecked Sendable {
    let serverPublicKey: SecKey
    let clientPrivateKey: SecKey
}

protocol KeyRepositoryProtocol: Sendable {
    func loadKeys() throws -> ApplicationKeys
}

final class BundleKeyRepository: KeyRepositoryProtocol, @unchecked Sendable {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func loadKeys() throws -> ApplicationKeys {
        ApplicationKeys(
            serverPublicKey: try loadKey(resource: "server-public", label: "server public key", private: false),
            clientPrivateKey: try loadKey(resource: "client-private", label: "client private key", private: true)
        )
    }

    private func loadKey(resource: String, label: String, private isPrivate: Bool) throws -> SecKey {
        guard let url = bundle.url(forResource: resource, withExtension: "pem"),
              let text = try? String(contentsOf: url, encoding: .utf8),
              let der = pemPayload(from: text)
        else {
            throw MessageEncryptionError.keyLoading(label)
        }
        if isPrivate {
            try validatePrivateDER(der, label: label)
        } else {
            try validatePublicDER(der, label: label)
        }
        let attributes: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: isPrivate ? kSecAttrKeyClassPrivate : kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: 2048,
        ]
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(der as CFData, attributes as CFDictionary, &error) else {
            _ = error?.takeRetainedValue()
            throw MessageEncryptionError.keyLoading(label)
        }
        return key
    }

    private func pemPayload(from text: String) -> Data? {
        let payload = text
            .split(separator: "\n")
            .filter { !$0.hasPrefix("-----") }
            .joined()
        return Data(base64Encoded: payload)
    }

    private func validatePublicDER(_ der: Data, label: String) throws {
        guard der.count > 10,
              der[der.startIndex] == 0x30,
              der[der.startIndex + 1] == 0x82,
              der[der.startIndex + 4] == 0x02,
              der[der.startIndex + 5] == 0x82,
              der[der.startIndex + 6] == 0x01
        else {
            throw MessageEncryptionError.keyLoading(label)
        }
    }

    private func validatePrivateDER(_ der: Data, label: String) throws {
        guard der.count > 10,
              der[der.startIndex] == 0x30,
              der[der.startIndex + 1] == 0x82,
              der[der.startIndex + 4] == 0x02,
              der[der.startIndex + 5] == 0x01,
              der[der.startIndex + 6] == 0x00,
              der[der.startIndex + 7] == 0x02,
              der[der.startIndex + 8] == 0x82
        else {
            throw MessageEncryptionError.keyLoading(label)
        }
    }
}
