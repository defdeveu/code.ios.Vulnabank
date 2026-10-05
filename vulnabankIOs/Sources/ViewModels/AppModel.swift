import Observation
import SwiftUI

@MainActor
@Observable
final class AppModel {
    enum AuthScreen: Hashable, Identifiable {
        case login
        case registration

        var id: Self { self }
    }

    private(set) var isAuthenticated = false
    private(set) var isRegistered = false
    private(set) var transactions: [Transaction] = []
    private(set) var errorMessage: String?

    var authScreen: AuthScreen?
    var isNewTransactionPresented = false

    @ObservationIgnored private let authService: any AuthServiceProtocol
    @ObservationIgnored private let repository: any TransactionRepositoryProtocol

    init(
        authService: any AuthServiceProtocol,
        repository: any TransactionRepositoryProtocol,
        initialError: String? = nil
    ) {
        self.authService = authService
        self.repository = repository
        self.errorMessage = initialError
    }

    func start() {
        isRegistered = authService.isRegistered
        if !authService.isAuthenticated {
            presentAuth()
        }
    }

    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            isRegistered = authService.isRegistered
            resetAuthentication()
            presentAuth()
        case .background:
            resetAuthentication()
        default:
            break
        }
    }

    func presentAuth() {
        guard authScreen == nil else {
            return
        }
        authScreen = authService.isRegistered ? .login : .registration
    }

    func register(pin: String) {
        authService.register(pin: pin)
        isRegistered = true
        isAuthenticated = true
        authScreen = nil
        refreshTransactions()
    }

    func login(pin: String) -> Bool {
        guard authService.login(pin: pin) else {
            return false
        }
        isAuthenticated = true
        authScreen = nil
        refreshTransactions()
        return true
    }

    func refreshTransactions() {
        transactions = repository.getAll()
    }

    func createTransaction(amount: Double, recipient: String) async {
        let transaction = await repository.create(
            Transaction(amount: amount, recipient: recipient, date: Date())
        )
        transactions.append(transaction)
    }

    func delete(_ transaction: Transaction) {
        if repository.delete(transaction) {
            transactions.removeAll { $0.id == transaction.id }
        }
    }

    func delete(atOffsets offsets: IndexSet) {
        offsets.map { transactions[$0] }.forEach(delete)
    }

    func delete(ids: Set<Int>) {
        transactions
            .filter { transaction in
                guard let id = transaction.id else {
                    return false
                }
                return ids.contains(id)
            }
            .forEach(delete)
    }

    func handle(url: URL) async {
        guard let action = DeepLink.action(from: url) else {
            return
        }
        switch action.command.lowercased() {
        case "add":
            let transaction = await repository.create(
                Transaction(amount: action.amount, recipient: action.recipient, date: Date())
            )
            transactions.append(transaction)
        default:
            break
        }
    }

    func clearError() {
        errorMessage = nil
    }

    private func resetAuthentication() {
        authService.logout()
        isAuthenticated = false
        transactions = []
    }
}
