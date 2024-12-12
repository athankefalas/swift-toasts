//
//  AssignToastPresenterModifier.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 7/10/24.
//

import SwiftUI

extension View {
    
    func assignToastPresenter(
        to binding: Binding<ToastPresenterProxy>
    ) -> some View {
#if canImport(UIKit) && !os(watchOS)
        self.assignUIWindowToastPresenter(to: binding)
#elseif canImport(Cocoa)
        self.assignNSWindowToastPresenter(to: binding)
#else
        self
#endif
    }
}

@MainActor
func _getDefaultToastPresenter() -> ToastPresenting? {
#if canImport(UIKit) && !os(watchOS)
    return _getDefaultUIWindowToastPresenter()
#elseif canImport(Cocoa)
    return _getDefaultNSWindowToastPresenter()
#else
    return nil
#endif
}
