//
//  Animatable.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 7/10/24.
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

