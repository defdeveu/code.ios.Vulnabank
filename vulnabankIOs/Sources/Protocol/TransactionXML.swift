import Foundation

enum TransactionXMLError: LocalizedError, Equatable {
    case malformedResponse

    var errorDescription: String? {
        "XML parser error"
    }
}

enum TransactionXML {
    struct Response: Equatable, Sendable {
        let code: String
        let id: String
    }

    static func extractPayload(_ data: Data) throws -> Data {
        guard let text = String(data: data, encoding: .utf8),
              let opening = text.range(of: "<response>"),
              let closing = text.range(of: "</response>"),
              opening.upperBound <= closing.lowerBound,
              let payload = Data(base64Encoded: String(text[opening.upperBound..<closing.lowerBound]))
        else {
            throw TransactionXMLError.malformedResponse
        }
        return payload
    }

    static func decodeResponse(_ xml: String) throws -> Response {
        let parser = XMLParser(data: Data(xml.utf8))
        let delegate = ResponseParser()
        parser.delegate = delegate
        guard parser.parse(), let code = delegate.code, let id = delegate.id else {
            throw TransactionXMLError.malformedResponse
        }
        return Response(code: code, id: id)
    }
}

private final class ResponseParser: NSObject, XMLParserDelegate {
    var code: String?
    var id: String?

    private var currentText = ""

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String]
    ) {
        currentText = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        switch elementName {
        case "code": code = currentText
        case "id": id = currentText
        default: break
        }
    }
}
