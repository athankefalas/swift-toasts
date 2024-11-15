//
//  Toast.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 6/10/24.
//

import SwiftUI

public struct Toast: View, Sendable {
    
    @Environment(\.toastStyle)
    private var toastStyle
    
    let configuration: ToastConfiguration
    
    public init(configuration: ToastConfiguration) {
        self.configuration = configuration
    }
    
    public init<Content: View>(
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            configuration: ToastConfiguration(
                role: role,
                duration: duration,
                content: content()
            )
        )
    }
    
    public var body: some View {
        toastStyle.makeBody(configuration: configuration)
    }
}

// MARK: Title Inits

public extension Toast {
    
    init(
        _ title: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Text(verbatim: title)
                .fallbackAccessibilityIdentifier("ToastTitle")
        }
    }
    
    init(
        _ title: LocalizedStringKey,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Text(title)
                .fallbackAccessibilityIdentifier("ToastTitle")
        }
    }
    
    @available(iOS 16.0, macOS 13, tvOS 16.0, watchOS 9.0, *)
    init(
        _ title: LocalizedStringResource,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Text(title)
                .fallbackAccessibilityIdentifier("ToastTitle")
        }
    }
}

// MARK: Icon + Title Inits

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension Toast {
    
    init(
        _ title: String,
        systemImage: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                Text(verbatim: title)
            } icon: {
                Image(systemName: systemImage)
            }
        }
    }
    
    init(
        _ title: String,
        image: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                Text(verbatim: title)
            } icon: {
                Image(image)
            }
        }
    }
    
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    init(
        _ title: String,
        image: ImageResource,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                Text(verbatim: title)
            } icon: {
                Image(image)
            }
        }
    }
    
    
    init(
        _ title: LocalizedStringKey,
        systemImage: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                Text(title)
            } icon: {
                Image(systemName: systemImage)
            }
        }
    }
    
    
    init(
        _ title: LocalizedStringKey,
        image: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                Text(title)
            } icon: {
                Image(image)
            }
        }
    }
    
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    init(
        _ title: LocalizedStringKey,
        image: ImageResource,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                Text(title)
            } icon: {
                Image(image)
            }
        }
    }
    
    @available(iOS 16.0, macOS 13, tvOS 16.0, watchOS 9.0, *)
    init(
        _ title: LocalizedStringResource,
        systemImage: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                Text(title)
            } icon: {
                Image(systemName: systemImage)
            }
        }
    }
    
    @available(iOS 16.0, macOS 13, tvOS 16.0, watchOS 9.0, *)
    init(
        _ title: LocalizedStringResource,
        image: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                Text(title)
            } icon: {
                Image(image)
            }
        }
    }
    
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    init(
        _ title: LocalizedStringResource,
        image: ImageResource,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                Text(title)
            } icon: {
                Image(image)
            }
        }
    }
}

// MARK: Toast Icon + Title + Subtitle

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension Toast {
    
    init<Value: StringProtocol>(
        _ title: String,
        value: Value,
        systemImage: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                LabeledContent(title, value: value)
            } icon: {
                Image(systemName: systemImage)
            }
        }
    }
    
    init<Value: StringProtocol>(
        _ title: LocalizedStringKey,
        value: Value,
        systemImage: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                LabeledContent(title, value: value)
            } icon: {
                Image(systemName: systemImage)
            }
        }
    }
    
    init<Value: CustomStringConvertible>(
        _ title: String,
        value: Value,
        systemImage: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                LabeledContent(title, value: value.description)
            } icon: {
                Image(systemName: systemImage)
            }
        }
    }
    
    init<Value: CustomStringConvertible>(
        _ title: LocalizedStringKey,
        value: Value,
        systemImage: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                LabeledContent(title, value: value.description)
            } icon: {
                Image(systemName: systemImage)
            }
        }
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension Toast {
    
    init<Value: StringProtocol>(
        _ title: String,
        value: Value,
        image: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                LabeledContent(title, value: value)
            } icon: {
                Image(image)
            }
        }
    }
    
    init<Value: StringProtocol>(
        _ title: LocalizedStringKey,
        value: Value,
        image: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                LabeledContent(title, value: value)
            } icon: {
                Image(image)
            }
        }
    }
    
    init<Value: CustomStringConvertible>(
        _ title: String,
        value: Value,
        image: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                LabeledContent(title, value: value.description)
            } icon: {
                Image(image)
            }
        }
    }
    
    init<Value: CustomStringConvertible>(
        _ title: LocalizedStringKey,
        value: Value,
        image: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                LabeledContent(title, value: value.description)
            } icon: {
                Image(image)
            }
        }
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension Toast {
    
    init<F: FormatStyle>(
        _ title: String,
        value: F.FormatInput,
        format: F,
        systemImage: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) where F.FormatInput: Equatable, F.FormatOutput == String {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                LabeledContent(title, value: value, format: format)
            } icon: {
                Image(systemName: systemImage)
            }
        }
    }
    
    init<F: FormatStyle>(
        _ title: String,
        value: F.FormatInput,
        format: F,
        image: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) where F.FormatInput: Equatable, F.FormatOutput == String {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                LabeledContent(title, value: value, format: format)
            } icon: {
                Image(image)
            }
        }
    }
    
    init<F: FormatStyle>(
        _ title: LocalizedStringKey,
        value: F.FormatInput,
        format: F,
        systemImage: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) where F.FormatInput: Equatable, F.FormatOutput == String {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                LabeledContent(title, value: value, format: format)
            } icon: {
                Image(systemName: systemImage)
            }
        }
    }
    
    init<F: FormatStyle>(
        _ title: LocalizedStringKey,
        value: F.FormatInput,
        format: F,
        image: String,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) where F.FormatInput: Equatable, F.FormatOutput == String {
        self.init(
            role: role,
            duration: duration
        ) {
            Label {
                LabeledContent(title, value: value, format: format)
            } icon: {
                Image(image)
            }
        }
    }
}

// MARK: Previews

#if DEBUG

#Preview {
    PresentedPreview {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                
                if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                    ForEach(ToastRole.allCases, id: \.self) { role in
                        Toast("Title", value: "Subtitle", systemImage: "square.fill", role: role)
                    }
                }
                
                Divider()
                
                if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                    ForEach(ToastRole.allCases, id: \.self) { role in
                        Toast(role: role) {
                            LabeledContent("Title", value: "Subtitle")
                        }
                    }
                }
                
                Divider()
                
                if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                    ForEach(ToastRole.allCases, id: \.self) { role in
                        Toast("Title", systemImage: "square.fill", role: role)
                    }
                }
                
                Divider()
                
                ForEach(ToastRole.allCases, id: \.self) { role in
                    Toast("Title", role: role)
                }
                
                Divider()
                
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#endif
