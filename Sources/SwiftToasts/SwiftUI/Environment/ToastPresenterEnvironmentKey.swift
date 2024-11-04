//
//  ToastPresenterEnvironmentKey.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 6/10/24.
//

import SwiftUI

private struct ToastPresenterEnvironmentKey: EnvironmentKey {
    
    public static var defaultValue: ToastPresenterProxy {
        MainActor.assumeIsolated {
            let toastPresenter = _getDefaultToastPresenter()
            toastPresenter?.prepareForToastPresentationIfNeeded()
            
            return ToastPresenterProxy(toastPresenter: toastPresenter)
        }
    }
}

public extension EnvironmentValues {
    
    /// A proxy of the toast presenter in this View hierarchy.
    internal(set) var toastPresenter: ToastPresenterProxy {
        get { self[ToastPresenterEnvironmentKey.self] }
        set { self[ToastPresenterEnvironmentKey.self] = newValue }
    }
}
