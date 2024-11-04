//
//  ToastPresentationContextSelector.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 23/10/24.
//

import Foundation

/// A type that can be used to select the appropriate context to present a toast in.
@MainActor
public struct ToastPresentationContextSelector {
    private let selector: @MainActor (PlatformIdiom, PresentationContext) async -> PresentationContext?
    
    public init(selector: @escaping @MainActor (PlatformIdiom, PresentationContext) async -> PresentationContext?) {
        self.selector = selector
    }
    
    func selectPresentationContext(in context: PresentationContext) async -> PresentationContext? {
        await selector(.current, context)
    }
    
    public static var scenePresentation: ToastPresentationContextSelector {
        ToastPresentationContextSelector { idiom, context in
            return context.findRoot()
        }
    }
}
