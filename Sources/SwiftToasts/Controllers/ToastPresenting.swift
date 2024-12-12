//
//  ToastPresenting.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI

protocol ToastPresenting: AnyObject {
    
    @MainActor
    var toastScheduler: ToastScheduler { get }
    
    @MainActor
    var presentationSpace: ToastPresentationSpace { get }
    
    @MainActor
    func prepareForToastPresentationIfNeeded()
}

extension ToastPresenting {
    
    @MainActor
    var presentationSpace: ToastPresentationSpace { .scene }
}
