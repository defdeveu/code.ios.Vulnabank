//
//  Logger.swift
//  vulnabankIOs
//

import Foundation

struct Log: TextOutputStream {
    
    func write(_ message: String) {
       
        var string: String
      
        if message.count > 0 && message != "\n"{
            string = "\(Date()): \(message) "
            NSLog(string)
        } else {
            string = message
        }
        
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
          
            let fileURL = documentDirectory.appendingPathComponent(Constants.Values.logFilename)
            
            if let handle = try? FileHandle(forWritingTo: fileURL) {
                handle.seekToEndOfFile()
                handle.write(string.data(using: .utf8)!)
                handle.closeFile()
            } else {
                try? string.data(using: .utf8)?.write(to:fileURL)
            }
        }
    }
}

var logger = Log()
