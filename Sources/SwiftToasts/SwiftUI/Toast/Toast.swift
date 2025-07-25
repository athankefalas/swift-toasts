//
//  Toast.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI

/// A Toast component used to present transient messages to the user.
public struct Toast: View, Sendable {
    
    @Environment(\.toastStyle)
    private var toastStyle
    
    let configuration: ToastConfiguration
    
    public init(configuration: ToastConfiguration) {
        self.configuration = configuration
    }
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
    ///   - content: The content view of the Toast.
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
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - systemImage: The icon of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - image: The icon of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - image: The icon of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - systemImage: The icon of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - image: The icon of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - image: The icon of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast
    ///   - systemImage: The icon of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast
    ///   - image: The icon of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast
    ///   - image: The icon of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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

// MARK: Toast Title + Subtitle

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension Toast {
    
    /// Creates a new Toast
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - value: The value subtitle of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
    init<Value: StringProtocol>(
        _ title: String,
        value: Value,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            LabeledContent(title, value: value)
        }
    }
    
    /// Creates a new Toast
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - value: The value subtitle of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
    init<Value: StringProtocol>(
        _ title: LocalizedStringKey,
        value: Value,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            LabeledContent(title, value: value)
        }
    }
    
    /// Creates a new Toast
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - value: The value subtitle of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
    init<Value: CustomStringConvertible>(
        _ title: String,
        value: Value,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            LabeledContent(title, value: value.description)
        }
    }
    
    /// Creates a new Toast
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - value: The value subtitle of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
    init<Value: CustomStringConvertible>(
        _ title: LocalizedStringKey,
        value: Value,
        role: ToastRole = .defaultRole,
        duration: ToastDuration = .defaultDuration
    ) {
        self.init(
            role: role,
            duration: duration
        ) {
            LabeledContent(title, value: value.description)
        }
    }
}

// MARK: Toast Icon + Title + Subtitle

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension Toast {
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - value: The value subtitle of the Toast.
    ///   - systemImage: The icon of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - value: The value subtitle of the Toast.
    ///   - systemImage: The icon of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - value: The value subtitle of the Toast.
    ///   - systemImage: The icon of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - value: The value subtitle of the Toast.
    ///   - systemImage: The icon of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - value: The value subtitle of the Toast.
    ///   - image: The icon of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - value: The value subtitle of the Toast.
    ///   - image: The icon of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - value: The value subtitle of the Toast.
    ///   - image: The icon of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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
    
    /// Creates a new Toast.
    /// - Parameters:
    ///   - title: The title of the Toast.
    ///   - value: The value subtitle of the Toast.
    ///   - image: The icon of the Toast.
    ///   - role: The semantic role of the Toast.
    ///   - duration: The duration of the Toast.
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

// MARK: Previews

#if DEBUG

#Preview {
    PresentedPreview {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                
                if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                    ForEach(ToastRole.allCases, id: \.self) { role in
                        Toast(
                            "Title",
                            value: "Subtitle",
                            systemImage: "square.fill",
                            role: role
                        )
                    }
                }
                
                Divider()
                
                if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                    ForEach(ToastRole.allCases, id: \.self) { role in
                        
                        Toast(
                            "Title",
                            value: "Subtitle \(role)",
                            role: role
                        )
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
                
                ForEach(ToastRole.allCases, id: \.self) { role in
                    Toast(role: role) {
                        if #available(iOS 15.0, *) {
                            Label {
                                HStack(spacing: 64) {
                                    Text("Title")
                                    Button("A") {}
                                }
                            } icon: {
                                Image(systemName: "square.fill")
                            }
                        }
                    }
                }
                
            }
        }
    }
}

#endif
