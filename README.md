#  SwiftToasts

Lib description

## Compatibility

The SwiftToasts library is compatible with all versions of SwiftUI.

### Platform Compatibility

| Platform | Compatibility | Tested             |
| -------- | ------------- | ------------------ |
| iOS      | ✅            | Device / Simulator |
| macOS    | ✅            | Device / Simulator |
| tvOS     | ✅            | Simulator          |
| watchOS  | ⚠️            | Device / Simulator |
| visionOS | ✅            | Simulator          |

#### WatchOS

On watchOS SwiftToasts requires an additional modifier to enable Toast Presentation in a compatibility mode.

## Installation

You can install SwiftToasts as a package dependency.

## Creating a Toast

A `Toast` is a plain SwiftUI View and requires three properties to configure and create it, the role of the Toast, the duration and the displayed content view. Similar to common SwiftUI components, such as `Button` or `Label`, a number of initializers exist that allow the initialization of a Toast with commonly used content.

``` Swift

/// Creating a plain Toast with Text content.
Toast("Hello Toast!")

/// Creating a failure Toast with Text content.
Toast(
    "Something went wrong.",
    role: .failure
)

/// Creating a success Toast with Label content.
Toast(
    "Settings Saved",
    systemImage: "checkmark.circle",
    role: .success
)

/// Creating a warning Toast with Label and subtitle content.
Toast(
    "Network Offline",
    value: "Please check your connection.",
    systemImage: "network.slash",
    role: .warning
)

/// Creating an informational Toast with custom content and long duration.
Toast(role: .informational, duration: .long) {
    Label {
        Text("User **@\(userName)** sent you a message.")
    } icon: {
        AsyncImage(
            url: URL(string: avatarRawURL)
        ) { phase in
            switch phase {
                case .empty, .failure:
                    EmptyView()
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                @unknown default:
                    EmptyView()
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(Circle())
    }
}

/// Creating an informational Toast with custom content and an custom duration.
Toast(role: .informational, duration: .seconds(8)) {
    HStack {
        ProgressView()
            .tint(.accentColor)
        
        Text("Synchronizing data...")
    }
}
```

### Role

The role property of a `Toast` defines the semantic purpose for the displayed content and can be used to conditionally modify the appearance of a Toast based on it's role. The role of a Toast is defined using the `ToastRole` enum.

The following roles are supported:

1. Plain
   
   A role that presents a plain message with no specific purpose.

2. Informational
   
   A role that presents an informational message to the user, such as a status update or an external event.

3. Success
   
   A role that presents an success message to the user after a user initiated operation was completed.
4. Warning
   
   A role that presents a warning message to the user after a user initiated operation was completed but encountered a recoverable error or a system precondition has changed.

5. Failure
   
   A role that presents a failure message to the user after a user initiated operation has failed.

### Duration

The duration of a `Toast` defines how long a Toast presentation will remain active. The duration of a Toast can be defined by using the `ToastDuration` type.



## Presenting a Toast

### Modifiers

### Tasks

### Buttons

## Configuring a Toast Presentation

### Toast Transitions

### Toast Cancellation

## Toast Styling

Components inside toast Text / Label / LabelledContent

Available Environment Keys

