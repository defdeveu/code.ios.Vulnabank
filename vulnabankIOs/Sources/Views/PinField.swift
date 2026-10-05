import SwiftUI

struct PinField<Field: Hashable>: View {
    let placeholder: String
    @Bindable var model: PinFieldModel
    let focus: FocusState<Field?>.Binding
    let field: Field

    var body: some View {
        SecureField(placeholder, text: $model.text)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .focused(focus, equals: field)
            .accessibilityLabel(placeholder)
            .onChange(of: model.text) { _, newValue in
                model.dirty = true
                if newValue.count > Constants.Values.pinLength {
                    model.text = String(newValue.prefix(Constants.Values.pinLength))
                }
            }
    }
}
