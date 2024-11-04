//
//  PresentedPreview.swift
//  SwiftToasts
//
//  Created by Αθανάσιος Κεφαλάς on 1/11/24.
//

import SwiftUI

#if DEBUG

struct PresentedPreview<Content: View>: View {
    
    @State
    private var loaded = false
    
    @State
    private var showContent = false
    
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
//        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
//            NavigationStack {
//                NavigationLink("Preview", isActive: $showContent) {
//                    content()
//                }
//            }
//            .onAppear {
//                guard !loaded else {
//                    return
//                }
//                
//                loaded = true
//                showContent = true
//            }
//        } else if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, visionOS 1.0, *) { // Fallback on earlier versions
            NavigationView {
                NavigationLink("Preview", isActive: $showContent) {
                    content()
                }
            }
            .onAppear {
                guard !loaded else {
                    return
                }
                
                loaded = true
                showContent = true
            }
//        } else {
//            PreviewContent {
//                content()
//            }
//        }
    }
}

#endif
