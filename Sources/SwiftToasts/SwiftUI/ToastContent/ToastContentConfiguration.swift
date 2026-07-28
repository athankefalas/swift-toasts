//
//  ToastContentConfiguration.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 15/7/26.
//

import SwiftUI

/// The properties of a `ToastContentView`.
@MainActor
public struct ToastContentConfiguration {
    public let icon: AnyView
    public let title: AnyView
    public let subtitle: AnyView
    
    init<Icon: View, Title: View, Subtitle: View>(
        icon: Icon,
        title: Title,
        subtitle: Subtitle
    ) {
        self.icon = icon.erased()
        self.title = title.erased()
        self.subtitle = subtitle.erased()
    }
}
