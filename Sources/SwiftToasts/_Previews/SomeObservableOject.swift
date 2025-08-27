//
//  SomeObservableOject.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 1/11/24.
//

import SwiftUI

#if ENABLE_PREVIEWS

class SomeObservableOject: ObservableObject {
        
    @Published
    var count = 0
    
    init() {}
    
    deinit {}
}

#endif
