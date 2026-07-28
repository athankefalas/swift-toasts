//
//  ToastPresentedRoleEnvironmentKey.swift
//  SwiftToasts
//
//  Created by Αθανάσιος Κεφαλάς on 15/7/26.
//

import SwiftUI

struct ToastPresentedRoleEnvironmentKey: EnvironmentKey {
    static let defaultValue: ToastRole? = nil
}

public extension EnvironmentValues {
    
    /// The role of the currently presented `Toast`.
    /// - Note: This environment value will be available only *inside* of a presented Toast.
    internal(set) var toastPresentedRole: ToastRole? {
        get { self[ToastPresentedRoleEnvironmentKey.self] }
        set { self[ToastPresentedRoleEnvironmentKey.self] = newValue }
    }
}
