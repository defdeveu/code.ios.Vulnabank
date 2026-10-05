import Observation

@MainActor
@Observable
final class PinFieldModel {
    var text = ""
    var touched = false
    var dirty = false

    var valid: Bool {
        if dirty && text.count < Constants.Values.pinLength {
            return false
        }
        return true
    }

    var validLength: Bool {
        text.count == Constants.Values.pinLength
    }
}
