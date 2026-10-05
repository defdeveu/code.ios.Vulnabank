import Foundation
import Testing
@testable import vulnabankIOs

@Suite
struct TransactionXMLTests {
    @Test
    func extractsBase64Payload() throws {
        let body = Data("<response>aGVsbG8gd29ybGQ=</response>".utf8)
        let payload = try TransactionXML.extractPayload(body)
        #expect(payload == Data(base64Encoded: "aGVsbG8gd29ybGQ=")!)
    }

    @Test
    func decodesAcknowledgment() throws {
        let response = try TransactionXML.decodeResponse("<response><code>0</code><id>abc123</id></response>")
        #expect(response == TransactionXML.Response(code: "0", id: "abc123"))
    }

    @Test
    func rejectsMalformedEnvelope() {
        #expect(throws: TransactionXMLError.self) {
            _ = try TransactionXML.extractPayload(Data("<html>not a response</html>".utf8))
        }
    }

    @Test
    func rejectsIncompleteAcknowledgment() {
        #expect(throws: TransactionXMLError.self) {
            _ = try TransactionXML.decodeResponse("<response><code>0</code></response>")
        }
    }
}

@MainActor
@Suite
struct PinFieldModelTests {
    @Test
    func untouchedFieldIsValid() {
        let model = PinFieldModel()
        #expect(model.valid)
        #expect(!model.validLength)
    }

    @Test
    func shortDirtyFieldIsInvalid() {
        let model = PinFieldModel()
        model.dirty = true
        model.text = "12"
        #expect(!model.valid)
        #expect(!model.validLength)
    }

    @Test
    func fourDigitFieldIsValid() {
        let model = PinFieldModel()
        model.dirty = true
        model.text = "1234"
        #expect(model.valid)
        #expect(model.validLength)
    }
}

@MainActor
@Suite
struct AppModelTests {
    @Test
    func startPresentsLoginWhenRegistered() {
        let model = AppModel(authService: StubAuthService(isRegistered: true), repository: StubTransactionRepository())
        model.start()
        #expect(model.authScreen == .login)
    }

    @Test
    func startPresentsRegistrationWhenUnregistered() {
        let model = AppModel(authService: StubAuthService(isRegistered: false), repository: StubTransactionRepository())
        model.start()
        #expect(model.authScreen == .registration)
    }

    @Test
    func successfulLoginDismissesAuthAndLoadsTransactions() {
        let repository = StubTransactionRepository()
        repository.stored = [Transaction(amount: 5, recipient: "a", date: Date())]
        let model = AppModel(authService: StubAuthService(isRegistered: true), repository: repository)
        model.start()

        let authenticated = model.login(pin: "1234")

        #expect(authenticated)
        #expect(model.isAuthenticated)
        #expect(model.authScreen == nil)
        #expect(model.transactions.count == 1)
    }

    @Test
    func failedLoginKeepsAuthScreen() {
        let model = AppModel(authService: StubAuthService(isRegistered: true), repository: StubTransactionRepository())
        model.start()

        let authenticated = model.login(pin: "0000")

        #expect(!authenticated)
        #expect(!model.isAuthenticated)
        #expect(model.authScreen == .login)
    }

    @Test
    func backgroundClearsSession() {
        let model = AppModel(authService: StubAuthService(isRegistered: true), repository: StubTransactionRepository())
        model.start()
        _ = model.login(pin: "1234")

        model.handleScenePhase(.background)

        #expect(!model.isAuthenticated)
        #expect(model.transactions.isEmpty)
    }
}

@MainActor
private final class StubAuthService: AuthServiceProtocol {
    var isRegistered: Bool
    private(set) var isAuthenticated = false

    init(isRegistered: Bool) {
        self.isRegistered = isRegistered
    }

    func register(pin _: String) {
        isAuthenticated = true
    }

    func login(pin: String) -> Bool {
        isAuthenticated = pin == "1234"
        return isAuthenticated
    }

    func logout() {
        isAuthenticated = false
    }
}

@MainActor
private final class StubTransactionRepository: TransactionRepositoryProtocol {
    var stored: [Transaction] = []

    func getAll() -> [Transaction] {
        stored
    }

    func create(_ transaction: Transaction) async -> Transaction {
        var created = transaction
        created.id = stored.count + 1
        created.transactionId = "id-\(created.id ?? 0)"
        stored.append(created)
        return created
    }

    func delete(_ transaction: Transaction) -> Bool {
        stored.removeAll { $0.id == transaction.id }
        return true
    }
}
