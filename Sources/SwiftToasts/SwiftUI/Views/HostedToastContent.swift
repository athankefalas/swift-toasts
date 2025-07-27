//
//  HostedToastContent.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 7/10/24.
//

import SwiftUI

struct HostedToastContent: View {
    let id: AnyHashable
    let content: () -> AnyView
    
    init() {
        self.id = UUID()
        self.content = { AnyView(erasing: EmptyView()) }
    }
    
    init<Content: View>(
        id: AnyHashable,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.id = id
        self.content = { AnyView(erasing: content()) }
    }
    
    init(
        id: AnyHashable,
        hosting toastPresentation: ToastPresentation,
        dismissAction: @escaping @MainActor () -> Void
    ) {
        self.init(id: id) {
           toastPresentation.toast
               .environment(\.toastPresentedAlignment, toastPresentation.toastAlignment)
               .environment(\.toastDismiss, ToastDismissAction(id: id, action: dismissAction))
               .toastStyle(toastPresentation.toastEnvironmentValues.toastStyle)
               .toastInteractiveDismissDisabled(!toastPresentation.toastEnvironmentValues.toastInteractiveDismissEnabled)
       }
    }
    
    var body: some View {
        content()
    }
}
