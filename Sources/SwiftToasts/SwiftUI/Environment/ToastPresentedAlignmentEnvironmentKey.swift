//
//  ToastPresentedAlignmentEnvironmentKey.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI

private struct ToastPresentedAlignmentEnvironmentKey: EnvironmentKey {
    static let defaultValue: ToastAlignment? = nil
}

public extension EnvironmentValues {
    
    /// The alignment of the presented toast.
    internal(set) var toastPresentedAlignment: ToastAlignment? {
        get { self[ToastPresentedAlignmentEnvironmentKey.self] }
        set { self[ToastPresentedAlignmentEnvironmentKey.self] = newValue }
    }
}
