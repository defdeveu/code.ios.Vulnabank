import Foundation

enum DeepLink {
    struct Action: Equatable, Sendable {
        let command: String
        let recipient: String
        let amount: Double
    }

    static func action(from url: URL) -> Action? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let command = components.host,
              let params = components.queryItems,
              let amountString = params.first(where: { $0.name == "amount" })?.value,
              let amount = Double(amountString),
              let recipient = params.first(where: { $0.name == "recipient" })?.value
        else {
            logger.log("DeepLink: Invalid URL or missing command")
            return nil
        }

        logger.log("DeepLink: command=\(command) amount = \(amount) recipient = \(recipient)")
        return Action(command: command, recipient: recipient, amount: amount)
    }
}
