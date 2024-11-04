//
//  ToastRole.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 6/10/24.
//

import SwiftUI

/// A value that describes the purpose of a toast.
public enum ToastRole: Hashable, CaseIterable, Sendable {
    /// A plain role with no additional context.
    case plain
    
    /// A role that defines a toast with important information.
    case informational
    
    /// A role that defines a toast indicating the success of some operation.
    case success
    
    /// A role that defines a toast with an important warning.
    case warning
    
    /// A role that defines a toast indicating the failure of some operation.
    case failure
}

public extension ToastRole {
    
    static var defaultRole: ToastRole {
        .plain
    }
}
