//
//  ToastOrnamentPresentationEnvironmentKey.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 4/12/24.
//

import SwiftUI

struct ToastOrnamentPresentationEnvironmentKey: EnvironmentKey {
    static let defaultValue = false
}

public extension EnvironmentValues {
    
    /// A value that indicates whether the toast is presented in an ornament.
    internal(set) var toastOrnamentPresentationEnabled: Bool {
        get { self[ToastOrnamentPresentationEnvironmentKey.self] }
        set { self[ToastOrnamentPresentationEnvironmentKey.self] = newValue }
    }
}
