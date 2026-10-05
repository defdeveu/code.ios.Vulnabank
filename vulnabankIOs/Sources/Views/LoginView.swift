import SwiftUI

struct LoginView: View {
    private enum Field: Hashable {
        case pin
    }

    @Bindable var model: AppModel

    @State private var pin = PinFieldModel()
    @State private var showError = false
    @State private var loginEnabled = false
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            BrandHeader()
            PinField(placeholder: "PIN", model: pin, focus: $focusedField, field: .pin)
            Text("Invalid Pin")
                .foregroundStyle(.red)
                .opacity(showError ? 1 : 0)
                .accessibilityHidden(!showError)
            Button("Login") {
                if !model.login(pin: pin.text) {
                    showError = true
                    loginEnabled = false
                }
            }
            .buttonStyle(SolidButtonStyle())
            .disabled(!loginEnabled)
            Spacer()
        }
        .padding(24)
        .onChange(of: pin.text) { _, _ in
            loginEnabled = pin.valid
            showError = false
        }
        .onChange(of: focusedField) { previous, _ in
            if previous == .pin {
                pin.touched = true
            }
        }
    }
}

struct BrandHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(.logoDddStamp1905)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundStyle(.primary)
                .frame(width: 96, height: 96)
                .accessibilityHidden(true)
            Text(AppStrings.appTitle)
                .font(.largeTitle.bold())
        }
    }
}
