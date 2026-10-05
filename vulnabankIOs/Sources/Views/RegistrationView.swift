import SwiftUI

struct RegistrationView: View {
    private enum Field: Hashable {
        case pin
        case confirmation
    }

    @Bindable var model: AppModel

    @State private var pin = PinFieldModel()
    @State private var confirmation = PinFieldModel()
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            BrandHeader()
            PinField(placeholder: "PIN", model: pin, focus: $focusedField, field: .pin)
            PinField(placeholder: "Confirm PIN", model: confirmation, focus: $focusedField, field: .confirmation)
            Text(errorMessage ?? " ")
                .foregroundStyle(.red)
                .opacity(errorMessage == nil ? 0 : 1)
                .accessibilityHidden(errorMessage == nil)
            Button("Register") {
                model.register(pin: pin.text)
            }
            .buttonStyle(SolidButtonStyle())
            .disabled(!registerEnabled)
            Spacer()
        }
        .padding(24)
        .onChange(of: focusedField) { previous, _ in
            switch previous {
            case .pin:
                pin.touched = true
            case .confirmation:
                confirmation.touched = true
            case nil:
                break
            }
        }
    }

    private var errorMessage: String? {
        let validPins = pin.valid && confirmation.valid
        let validLengths = pin.validLength && confirmation.validLength

        if !validPins && pin.touched {
            return Constants.Errors.pinLength
        }
        if validLengths && pin.text != confirmation.text {
            return Constants.Errors.pinMismatch
        }
        return nil
    }

    private var registerEnabled: Bool {
        pin.valid
            && confirmation.valid
            && pin.validLength
            && confirmation.validLength
            && pin.text == confirmation.text
    }
}
