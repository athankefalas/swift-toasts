//
//  SwiftUIView.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 15/7/26.
//

import SwiftUI

public struct ToastContentView: View {
    @Environment(\.toastContentStyle)
    private var toastContentStyle
    
    private let configuration: ToastContentConfiguration
    
    public init<Icon: View, Title: View, Subtitle: View>(
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder title: () -> Title,
        @ViewBuilder subtitle: () -> Subtitle
    ) {
        self.configuration = ToastContentConfiguration(
            icon: icon(),
            title: title(),
            subtitle: subtitle()
        )
    }
    
    public var body: some View {
        toastContentStyle.makeBody(configuration: configuration)
    }
}
