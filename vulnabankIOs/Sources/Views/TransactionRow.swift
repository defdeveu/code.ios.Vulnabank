import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let transactionId = transaction.transactionId {
                Text(transaction.recipient)
                    .font(.headline)
                Text("Amount: " + String(transaction.amount))
                Text("Id: \(transactionId)")
                    .foregroundStyle(.secondary)
            } else {
                Text("Failed transaction")
                    .font(.headline)
                if let error = transaction.error {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
            Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
