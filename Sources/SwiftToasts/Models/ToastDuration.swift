//
//  ToastDuration.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 6/10/24.
//

import SwiftUI

/// A type that represents the duration of a toast presentation.
public struct ToastDuration: Hashable, Sendable {
    let rawValue: TimeInterval
    
    private init(rawValue: TimeInterval) {
        self.rawValue = rawValue
    }
    
    /// A short toast presentation duration, ideal for transient messages.
    public static let short = ToastDuration(rawValue: 2)
    
    /// A long toast presentation duration, ideal for transient messages with textual content.
    public static let long = ToastDuration(rawValue: 3.5)
    
    /// A longer toast presentation duration, ideal for transient messages with rich textual content.
    public static let longer = ToastDuration(rawValue: 5)
    
    /// A toast presentation duration that never expires, ideal for transient messages that require action.
    public static var indefinite: ToastDuration {
        ToastDuration(rawValue: 0)
    }
    
    /// A toast presentation duration that is defined in seconds.
    /// - Parameter value: The amount of seconds the toast will be presented for.
    /// - Returns: A toast duration with the given duration in seconds.
    public static func seconds(_ value: TimeInterval) -> ToastDuration {
        ToastDuration(rawValue: value)
    }
}

public extension ToastDuration {
    
    static var defaultDuration: ToastDuration {
        .short
    }
}

extension Task where Success == Never, Failure == Never {
    
    static func sleep(
        duration: ToastDuration
    ) async throws {
        guard duration.rawValue > 0 else {
            return try await sleepForever()
        }
        
        let seconds = duration.rawValue
        let timescale = await SwiftToastsConfiguration.current.timeScale
        try await sleep(seconds: seconds * timescale.rawValue)
    }
    
    private static func sleepForever() async throws {
        while !Task.isCancelled {
            await Task.yield()
            
            if Task.isCancelled {
                break
            }
            
            try await Task.sleep(seconds: 60)
        }
    }
    
    static func sleep(seconds: TimeInterval) async throws {
        let nsec_per_sec = TimeInterval(1_000_000_000)
        var nanoseconds = floor(seconds * nsec_per_sec)
        
        if nanoseconds.isNaN || nanoseconds.isInfinite {
            nanoseconds = TimeInterval(UInt64.max - 1)
        }
        
        nanoseconds = max(1, min(nanoseconds, TimeInterval(UInt64.max - 1)))
        try await sleep(nanoseconds: UInt64(nanoseconds))
    }
}
