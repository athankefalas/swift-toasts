//
//  ToastPresentationLayoutExample.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 29/7/25.
//

import SwiftUI

#if DEBUG

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
struct ToastPresentationLayoutExample: View {
    @State
    var showSheet: Bool = false
    
    @State
    var showToast: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Button("Show Sheet") {
                showSheet = true
            }
            
            Spacer()
        }
        .sheet(isPresented: $showSheet) {
            VStack(spacing: 16) {
                Spacer()
                
                Text("Sheet Content")
                
                Spacer()
                
                Button("Show Toast") {
                    showToast = true
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.borderedProminent)
#if !os(tvOS)
                .controlSize(.large)
#endif
            }
            .padding(.vertical, 32)
            .toast(isPresented: $showToast) {
                Toast(
                    "Hello!",
                    systemImage: "hand.wave.fill",
                    role: .informational
                )
            }
            .toastPresentingLayout()
            .presentationDetents([.medium])
        }
        .onAppear {
            showSheet = true
        }
    }
}

#Preview {
    ZStack {
        if #available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *) {
            ToastPresentationLayoutExample()
        }
    }
}

#endif
