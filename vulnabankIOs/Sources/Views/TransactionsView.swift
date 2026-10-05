import SwiftUI

struct TransactionsView: View {
    @Bindable var model: AppModel
    @State private var selection = Set<Int>()
    @Environment(\.editMode) private var editMode

    var body: some View {
        List(selection: $selection) {
            ForEach(model.transactions) { transaction in
                TransactionRow(transaction: transaction)
                    .tag(transaction.id ?? -1)
            }
            .onDelete { offsets in
                model.delete(atOffsets: offsets)
            }
        }
        .listStyle(.plain)
        .refreshable {
            model.refreshTransactions()
        }
        .navigationTitle("Transactions")
        .toolbarTitleDisplayMode(.inline)
        .labToolbar()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    model.isNewTransactionPresented = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New transaction")
            }
            if editMode?.wrappedValue.isEditing == true {
                ToolbarItem(placement: .bottomBar) {
                    Button("Delete", role: .destructive) {
                        model.delete(ids: selection)
                        selection.removeAll()
                    }
                    .disabled(selection.isEmpty)
                }
            }
        }
        .sheet(isPresented: $model.isNewTransactionPresented) {
            NewTransactionView(model: model)
        }
    }
}
