//
//  Animatable.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 7/10/24.
//

import Foundation

protocol Animatable {
    
    @MainActor
    func animate(
        transition: ToastTransition,
        in context: ToastTransition.Context,
        completion: @escaping @MainActor (Bool) -> Void
    )
}

