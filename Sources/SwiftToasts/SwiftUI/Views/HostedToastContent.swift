//
//  HostedToastContent.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 7/10/24.
//

import SwiftUI

struct HostedToastContent: View {
    let content: () -> AnyView
    
    init() {
        self.content = { AnyView(erasing: EmptyView()) }
    }
    
    init<Content: View>(@ViewBuilder content: @escaping () -> Content) {
        self.content = { AnyView(erasing: content()) }
    }
    
    init(
        hosting toastPresentation: ToastPresentation,
        dismissAction: @escaping @MainActor () -> Void
    ) {
        self.init {
           toastPresentation.toast
               .environment(\.toastPresentedAlignment, toastPresentation.toastAlignment)
               .environment(\.toastDismiss, ToastDismissAction(action: dismissAction))
               .toastStyle(toastPresentation.toastStyle)
       }
    }
    
    var body: some View {
        content()
    }
}
