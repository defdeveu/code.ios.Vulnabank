import Foundation

struct Transaction: Codable, Identifiable, Equatable, Sendable {
    var id: Int?
    var transactionId: String?
    var error: String?
    let amount: Double
    let recipient: String
    let date: Date
}
