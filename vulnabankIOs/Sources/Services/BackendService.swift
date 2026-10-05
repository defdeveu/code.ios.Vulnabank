import Foundation

enum BackendError: LocalizedError, Equatable {
    case network(String)
    case parser(String)

    var errorDescription: String? {
        switch self {
        case let .network(message), let .parser(message):
            message
        }
    }
}

protocol BackendServiceProtocol: Sendable {
    func send(sealedBody: Data) async throws -> Data
}

final class BackendService: BackendServiceProtocol, @unchecked Sendable {
    private let endpoint: URL
    private let session: URLSession

    init(endpoint: URL, session: URLSession = URLSession(configuration: .default)) {
        self.endpoint = endpoint
        self.session = session
    }

    func send(sealedBody: Data) async throws -> Data {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Application/xml", forHTTPHeaderField: "Content-Type")
        request.httpBody = sealedBody

        logger.log("Transaction request: \(endpoint)")

        let data: Data
        do {
            (data, _) = try await session.data(for: request)
        } catch {
            throw BackendError.network("An error occurred during request: " + error.localizedDescription)
        }

        do {
            return try TransactionXML.extractPayload(data)
        } catch {
            throw BackendError.parser("XML parser error")
        }
    }
}
