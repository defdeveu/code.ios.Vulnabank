import Foundation

final class Logger: @unchecked Sendable {
    private let lock = NSLock()

    func log(_ message: String) {
        guard !message.isEmpty, message != "\n" else {
            return
        }

        lock.lock()
        defer { lock.unlock() }

        let line = "\(Date()): \(message) "
        NSLog(line)

        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let fileURL = documentDirectory.appendingPathComponent(Constants.Values.logFilename)
        if let handle = try? FileHandle(forWritingTo: fileURL) {
            handle.seekToEndOfFile()
            handle.write(Data(line.utf8))
            handle.closeFile()
        } else {
            try? Data(line.utf8).write(to: fileURL)
        }
    }
}

let logger = Logger()
