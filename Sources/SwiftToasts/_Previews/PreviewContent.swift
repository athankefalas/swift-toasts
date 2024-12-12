//
//  PreviewContent.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 10/10/24.
//

import SwiftUI

#if DEBUG

struct PreviewContent<Content: View>: View {
    
    @State
    private var appeared = false
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            
            if appeared {
                content
            }
            
            Button {
                appeared.toggle()
            } label: {
                makeLabel()
            }
            .padding(1)
            .background(
                Circle()
                    .foregroundColor(.gray.opacity(0.66))
            )
            .padding(1)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .onAppear {
            appeared.toggle()
        }
    }
    
    private func makeLabel() -> AnyView {
        if #available(macOS 11.0, *) {
            return AnyView(
                Image(systemName: appeared ? "xmark.circle.fill" : "arrow.clockwise.circle.fill")
            )
        } else { // Fallback on earlier versions
            return AnyView(
                Text(appeared ? "X" : "O")
            )
        }
    }
}

#Preview {
    PreviewContent {
        Color.red
    }
}

#endif
