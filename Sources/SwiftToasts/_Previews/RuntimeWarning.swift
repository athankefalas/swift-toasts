//
//  RuntimeWarning.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 1/11/24.
//

#if DEBUG
import OSLog

func runtimeWarn(
    _ message: StaticString,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) {
    let logContent = "WARNING: [\(fileName(file)):\(line)] @ \(function) - \(message)"
    
    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
        print(logContent)
    }
    
    if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
        let logger = Logger(subsystem: "SwiftToasts", category: "RuntimeWarnings")
        logger.warning("\(logContent)")
    } else { // Fallback on earlier versions
        NSLog(logContent)
    }
}

private func fileName(_ file: StaticString) -> String {
    let file = "\(file)"
    
    guard file.contains("/"),
          let fileNameComponent = file.split(separator: "/").last else {
        return file
    }
    
    return String(fileNameComponent)
}

#endif
