//
//  ToastPresentationCanceller.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 5/12/24.
//

import Foundation

/// A controller object that can be used to programatically dismiss an already presented `Toast`.
@MainActor
public final class ToastPresentationCanceller {
    private var presentationDismissalHandler: @MainActor () -> Void
    
    public init() {
        self.presentationDismissalHandler = {}
    }
    
    final func removeHandler() {
        self.presentationDismissalHandler = {}
    }
    
    final func setHandler(
        _ presentationDismissalHandler: @escaping @MainActor () -> Void
    ) {
        self.presentationDismissalHandler = presentationDismissalHandler
    }
    
    public final func dismissPresentation() {
        presentationDismissalHandler()
    }
}
