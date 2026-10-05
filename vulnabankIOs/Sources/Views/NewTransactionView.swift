import SwiftUI

struct NewTransactionView: View {
    @Bindable var model: AppModel
    @Environment(\.dismiss) private var dismiss

    @State private var recipient = ""
    @State private var amountText = ""
    @State private var isSending = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Recipient name", text: $recipient)
                    .accessibilityLabel("Recipient name")
                TextField("Amount", text: $amountText)
                    .keyboardType(.decimalPad)
                    .accessibilityLabel("Amount")
            }
            .disabled(isSending)
            .navigationTitle("New transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSending {
                        ProgressView()
                    } else {
                        Button("Send") {
                            send()
                        }
                        .disabled(!sendEnabled)
                    }
                }
            }
        }
    }

    private var amount: Double? {
        Double(amountText)
    }

    private var sendEnabled: Bool {
        !recipient.isEmpty && (amount ?? 0) > 0
    }

    private func send() {
        guard let amount, !recipient.isEmpty else {
            return
        }
        isSending = true
        Task {
            await model.createTransaction(amount: amount, recipient: recipient)
            isSending = false
            dismiss()
        }
    }
}
