//
//  ToastPresentationContextSelector.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 23/10/24.
//

import SwiftUI

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
    
    /// A presentation that selects the scene as the presentation context for presenting a toast.
    ///
    /// - Note: In watchOS scene level presentation is not available due to the nature of how native
    /// view hierarchies are created. Instead use the `toastPresentingLayout` modifier at the top
    /// level of a view to show toasts at the layout level.
    public static var scenePresentation: ToastPresentationContextSelector {
        ToastPresentationContextSelector { _, context in
            return context.findRoot()
        }
    }
    
#if os(visionOS)
    /// A presentation that selects the scene ornaments as the presentation context for presenting a toast.
    public static var ornamentPresentation: ToastPresentationContextSelector {
        ToastPresentationContextSelector { _, _ in
            PresentationContext(ornament: ToastOrnament(contentAlignment: .center))
        }
    }
    
    /// A presentation that selects the scene ornaments with the given content alignment as the presentation context for presenting a toast.
    /// - Parameter contentAlignment: The alignment of the ornament's content.
    public static func ornamentPresentation(contentAlignment: Alignment) -> ToastPresentationContextSelector {
        ToastPresentationContextSelector { _, _ in
            PresentationContext(ornament: ToastOrnament(contentAlignment: contentAlignment))
        }
    }
#endif
    
}
