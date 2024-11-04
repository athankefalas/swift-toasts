//
//  ToastPresentingLayoutGeometryKey.swift
//  SwiftToasts
//
//  Created by Αθανάσιος Κεφαλάς on 4/11/24.
//

import SwiftUI

struct ToastPresentingLayoutGeometry: Hashable {
    let frame: CGRect
    let windowFrame: CGRect
    
    init(_ geometry: GeometryProxy) {
        let frame = geometry.frame(in: .global)
        let insets = geometry.safeAreaInsets
        self.frame = frame
        self.windowFrame = CGRect(
            origin: .zero,
            size: CGSize(
                width: frame.width + insets.leading + insets.trailing,
                height: frame.height + insets.top + insets.bottom
            )
        )
    }
}

struct ToastPresentingLayoutGeometryPreferenceKey: PreferenceKey {
    static let defaultValue: ToastPresentingLayoutGeometry? = nil
    
    static func reduce(
        value: inout ToastPresentingLayoutGeometry?,
        nextValue: () -> ToastPresentingLayoutGeometry?
    ) {
        value = value ?? nextValue()
    }
}

struct ToastPresentingLayoutGeometryEnvironmentKey: EnvironmentKey {
    static let defaultValue: ToastPresentingLayoutGeometry? = nil
}

extension EnvironmentValues {
    
    var toastPresentingLayoutGeometry: ToastPresentingLayoutGeometry? {
        get { self[ToastPresentingLayoutGeometryEnvironmentKey.self] }
        set { self[ToastPresentingLayoutGeometryEnvironmentKey.self] = newValue }
    }
}
