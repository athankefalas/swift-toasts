//
//  ToastPresenting.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 6/10/24.
//

import SwiftUI

protocol ToastPresenting: AnyObject {
    
    @MainActor
    var toastScheduler: ToastScheduler { get }
    
    @MainActor
    func prepareForToastPresentationIfNeeded()
}
