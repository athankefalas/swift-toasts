//
//  SomeObservableOject.swift
//  SwiftToasts
//
//  Created by Αθανάσιος Κεφαλάς on 1/11/24.
//

import SwiftUI

#if DEBUG

class SomeObservableOject: ObservableObject {
        
    @Published
    var count = 0
    
    init() {
        print("## SomeObservableOject - INIT")
    }
    
    deinit {
        print("## SomeObservableOject - DEINIT")
    }
}

#endif
