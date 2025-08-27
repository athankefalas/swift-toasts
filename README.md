#  SwiftToasts

<!-- # Badges -->
[![License](https://img.shields.io/github/license/athankefalas/swift-toasts)](https://github.com/athankefalas/swift-toasts/blob/main/LICENSE)
![GitHub Release](https://img.shields.io/github/v/release/athankefalas/swift-toasts)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fathankefalas%2Fswift-toasts%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/athankefalas/swift-toasts)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fathankefalas%2Fswift-toasts%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/athankefalas/swift-toasts)


A toast is a transient, relatively unobtrusive visual component that can be used to display short messages such as status updates or surface errors without blocking user interaction with the main content. 

SwiftToasts is a library for SwiftUI that enables easy, fast, flexible and configurable integration of toasts in Apple platforms, at the scene level. Built to follow the API conventions of SwiftUI, using the library feels familiar, intuitive and truly native.

Features:

🎨 Configurable Toast style.

⚙️ Configurable Toast alignment.

🎞️ Configurable Toast transition animations.

⏲️ Deterministic scheduler based Toast presentation.

🍎 Compatible with multiple Apple platforms and all SwiftUI versions.

🛠️ Variety of ways that can be used to present Toasts using SwiftUI inspired APIs.

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

Because watchOS does not have a platform-native dynamic view hierarchy framework such as UIKit or AppKit, SwiftToasts requires that the `toastPresentingLayout` modifier be placed at the root content view to enable Toast Presentation on watchOS in a compatibility mode.

## Installation

You can install SwiftToasts as a Swift package dependency, by using the following url:

    https://github.com/athankefalas/swift-toasts.git

## Creating a Toast

A `Toast` is defined a plain SwiftUI View and requires three properties to configure and create it, the role of the Toast, the duration and the displayed content view. Similar to common SwiftUI components, such as `Button` or `Label`, a number of initializers exist that allow the initialization of a Toast with commonly used content.

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
    Label {
        Text("Synchronizing data...")
    } icon: {
        ProgressView()
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
   
   A role that presents a warning message to the user after a user initiated operation was completed but encountered a recoverable error or a system precept has changed.

5. Failure
   
   A role that presents a failure message to the user after a user initiated operation has failed.

### Duration

The duration of a `Toast` defines how long a Toast presentation will remain active. The duration of a Toast can be defined by using the `ToastDuration` type.

Other than predefined defined duration instances that have a specific lifetime, a Toast may also be presented indefinitely, by using the `ToastDuration.indefinite` duration. Please note, that a Toast that is presented indefinitely must be explicitly dismissed either by user interaction or by any other means that control the presentation of a Toast.

## Presenting a Toast

After a `Toast` is created it can be scheduled for presentation on a __*separate*__, __*modal environment*__. An internal scheduler places scheduled toasts in a FIFO queue and ensures that Toasts will be presented one at a time in the order they were scheduled.

### Modifiers

The modifiers below can be used to present a `Toast` as a reaction to a trigger, an occurred event or a state change.

#### Toast

The `toast` modifier and it's variants can be used to present a `Toast` as a reaction to a trigger, an occurred event or a state change. Generally, the toast modifier allows for the optional configuration of the presentation alignment, an optional dismissal callback and a content builder closure that can be used to build the toast to present.

The content builder closure supports conditional and optional `Toast` building following the API style of the SwiftUI ViewBuilder.

``` Swift
// Showing a Toast based on a boolean binding.
content
    .toast(
        isPresented: $showToast,
        alignment: .top,
        onDismiss: { print("Toast Dismissed.") }
    ) {
        if error != nil {
            Toast("Done.", role: .success)
        }
    }

// Showing a Toast based on an item binding.
content
    .toast(
        item: $toastItem,
        alignment: .top,
        onDismiss: { print("Toast Dismissed.") }
    ) { item in
        switch item {
            case .completed:
                Toast("Completed.", role: .success)
            case .failed:
                Toast("Failed.", role: .failure)
        }
    }

// Showing a Toast when some value changes
content
    .toast(trigger: someValue) {
        Toast("Value changed")
    }

// Showing a Toast when some value changes
content
    .toast(
        trigger: someValue,
        alignment: .top,
        onDismiss: { print("Toast Dismissed.") }
    ) { newValue
        Toast("Value changed to \(newValue).")
    }

// Showing a Toast when a publisher sends a new value.
content
    .toast(byReceiving: publisher) { newValue in
        Toast("Publisher sent value \(newValue).")
    }

```

#### Tasks

The toast variants of the `task` modifier can be used to schedule the presentation of a `Toast` when the presentation is a direct result of an asynchronous operation.

``` swift
// Showing a Toast as a result of a task.
content
    .task { schedule in
        let didSucceed = await operation()

        guard !didSucceed else {
            return
        }

        schedule(
            toast: Toast(
                "Operation failed.",
                role: .failure
            )
        )
    }

// Showing a Toast as a result of an identified task.
content
    .task(id: identity) { schedule in
        let didSucceed = await operation()

        guard !didSucceed else {
            return
        }

        schedule(
            toast: Toast(
                "Operation failed.",
                role: .failure
            )
        )
    }

```

### Buttons

A `ToastButton` can be used to schedule the presentation of a `Toast` when the presentation is a direct result of a user interaction or user triggered operation.

``` Swift
// Showing a Toast after a user presses a Button.
ToastButton("Submit") { schedule in
    operation()
    schedule(
        toast: Toast(
            "Completed.",
            systemImage: "checkmark.circle.fill",
            role: .success
        )
    )
}

```

## Configuring a Toast Presentation

Most of the aspects of a Toast or it's presentation can be configured using several *environment* based modifiers.

### Style

The style of a Toast can be configured in the same way as some of the system provided components. The library ships with a basic style called `PlainToastStyle`, but if further customization is required a custom style can easily be created by conforming to the `ToastStyle` protocol.

``` Swift
// Showing a Toast with the default style.
ToastButton("Show Toast") { schedule in
    schedule(
        toast: Toast(
            "Hello!",
            systemImage: "hand.wave.fill",
            role: .informational
        )
    )
}
.toastStyle(.plain)

// Showing a Toast with a custom style.
ToastButton("Show Toast") { schedule in
    schedule(
        toast: Toast(
            "Hello!",
            systemImage: "hand.wave.fill",
            role: .informational
        )
    )
}
.toastStyle(SomeToastStyle())

```

### Transition

The transition animation when presenting a Toast is also configurable with a selection of predefined transitions. A transition can be combined with another to create a variety of different effects.

``` Swift
// Showing a Toast by fading it in and out.
ToastButton("Show Toast") { schedule in
    schedule(
        toast: Toast(
            "Hello!",
            systemImage: "hand.wave.fill",
            role: .informational
        )
    )
}
.toastTransition(.opacity)

// Showing a Toast by scaling it in and out.
ToastButton("Show Toast") { schedule in
    schedule(
        toast: Toast(
            "Hello!",
            systemImage: "hand.wave.fill",
            role: .informational
        )
    )
}
.toastTransition(.scale)

// Showing a Toast by scaling it in and fading it out.
ToastButton("Show Toast") { schedule in
    schedule(
        toast: Toast(
            "Hello!",
            systemImage: "hand.wave.fill",
            role: .informational
        )
    )
}
.toastTransition(
    .asymmetric(
        insertion: .scale,
        removal: .opacity
    )
)

// Showing a Toast by combining two or more transitions.
ToastButton("Show Toast") { schedule in
    schedule(
        toast: Toast(
            "Hello!",
            systemImage: "hand.wave.fill",
            role: .informational
        )
    )
}
.toastTransition(
    .move(edge: .top)
    .combined(
        with: .opacity.combined(
            with: .scale
        )
    )
)

```

### Cancellation

After a `Toast` is created, it is scheduled for presentation in a queue. A scheduled Toast may be cancelled *before* it is presented by the source it was scheduled from, depending on context and the active environment configuration. 

By default, a scheduled toast will not be cancelled unless the scene containing it's source is dismissed. The cancellation policy in the current environment can be configured by using the `toastCancellation` modifier.

Please note, that cancellation only affects Toasts that have not yet been presented and are still waiting for presentation in the schedulers queue.

For example, when firing a form submission action using a `ToastButton` it might be desirable to *save* the updated values of the form and immediately dismiss the scene. In order for the scheduled presentation to not be cancelled, the `.never` cancellation policy will be required.

``` Swift 
// The button below saves the form, starts the dismissal of the active scene
// and then schedules a Toast. By using the `.never` cancellation policy the
// scheduled Tost will not be cancelled when the active scene is dismissed.
ToastButton("Submit") { schedule in
    saveForm()
    dismiss()
    schedule(
        toast: Toast(
            "Hello!",
            systemImage: "hand.wave.fill",
            role: .informational
        )
    )
}
.toastCancellation(.never)

```

Alternatively, when a toast is scheduled by using a state change trigger it might be desirable to avoid scheduling a large number of toasts when a value changes rapidly and frequently. In order to automatically cancel all scheduled toasts by a specific source, the `.always` cancellation policy is required.

``` Swift
// A change of the volume value triggers a toast.
// By using the `.always` cancellation policy, each time a new Toast 
// is scheduled all previous Toasts already in the scheduler queue, 
// will be cancelled.
Slider(value: $volume, in: 0...100) {
    Text("Volume: \(volume)%")
}
.toast(trigger: volume) { newValue in
    Toast("Volume set to \(newValue)%.")
}
.toastCancellation(.always)
```

### Presentation Invalidation

While toasts are usually a fire and forget component, there is a limited capability to dismiss already presented toasts. The `toast` modifier and it's variants specifically, use a trigger value as context to determine when to schedule a `Toast`. By default, whenever the value changes again an already displayed toast is automatically dismissed as the *context that triggered it* has changed. This behavior, can be easily configured by using the `toastPresentationInvalidation` modifier.

For example, it might be desirable to configure a toast triggered by a value change to automatically dismiss when the value changes *and* when the source's scene is dismissed.

``` Swift
// A change of the volume value triggers a toast.
// By using the `.contextChanged, .presentationDismissed` presentation
// invalidation options, an already presented Toast will be dismissed when
// the slider's value changes and when it's container is dismissed.
Slider(value: $volume, in: 0...100) {
    Text("Volume: \(volume)%")
}
.toast(trigger: volume) { newValue in
    Toast("Volume set to \(newValue)%.")
}
.toastCancellation(.always)
.toastPresentationInvalidation([.contextChanged, .presentationDismissed])
```

Alternatively, if it is desired that the active toast presentation is never invalidated the `.never` presentation invalidation can be used instead.

### Interactive Dismissal

A presented `Toast` may be dismissed before it's duration has elapsed as a result of a user tapping the content of the toast. This behavior can be controlled by using the `toastInteractiveDismissEnabled` modifier. A common use case to prevent interactive dismissal, is for using a toast as a loading indicator.

``` Swift
// Showing a Toast as a loading indicator HUD.
content
    .toast(
        isPresented: $isLoading,
        alignment: .center
    ) {
        Toast(role: .informational, duration: .indefinite) {
            Label {
                Text("Loading...")
            } icon: {
                ProgressView()
                    .scaleEffect(2)
            }
        }
    }
    .toastInteractiveDismissDisabled(true)

```

## Toast Styling

When a `Toast` is presented it's appearance is retrieved by the source's environment. A custom style can be implemented by creating a struct that conforms to the `ToastStyle` protocol.

By using the `configuration` parameter and leveraging several environment values, a custom toast style can provide a pretty detailed and adaptive visual representation of the contents of a toast.

``` Swift
import SwiftUI
import SwiftToasts

// A simple example of a custom Toast style
struct CustomToastStyle: ToastStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        StyledToastBody(configuration: configuration)
    }
    
    struct StyledToastBody: View {
        @Environment(\.toastDismiss)
        private var toastDismiss
        
        @Environment(\.toastPresentedAlignment)
        private var toastPresentedAlignment
        
        @Environment(\.toastInteractiveDismissEnabled)
        private var toastInteractiveDismissEnabled
        
        let configuration: Configuration
        
        private var shape: AnyShape {
            if toastPresentedAlignment == .center {
                return AnyShape(RoundedRectangle(cornerRadius: 12))
            } else {
                return AnyShape(Capsule())
            }
        }
        
        private var color: Color {
            configuration.role == .failure ? .red : .accentColor
        }
        
        var body: some View {
            configuration.content
                .padding(12)
                .foregroundStyle(color)
                .background(.ultraThinMaterial, in: shape)
                .overlay {
                    shape.stroke(
                        color.opacity(0.25),
                        lineWidth: 1
                    )
                }
                .onTapGesture {
                    guard toastInteractiveDismissEnabled else { return }
                    toastDismiss?()
                }
        }
    }
}

// Showing a Toast with the custom style.
ToastButton("Show Toast") { schedule in
    schedule(
        toast: Toast(
            "Hello!",
            systemImage: "hand.wave.fill",
            role: .informational
        )
    )
}
.toastStyle(CustomToastStyle())

```

### Toast Environment Values

A set of different *environment* values are injected into a presented toast for the purpose of enabling further customization of the visual content of a `Toast` or providing a programmatic dismissal action.

#### Toast Dismiss Action

The toast dismiss action is an environment value injected in the `toastDismiss` KeyPath and contains an action that can be used to programmatically dismiss a toast depending on a specific user interaction.

Please note, that the scheduler automatically handles the duration of a toast so there is no need for a custom toast style to handle automatic dismissal based on the duration of a presented `Toast`.

#### Toast Presented Alignment

The toast presented alignment is an *environment* value injected in the `toastPresentedAlignment` KeyPath and contains the alignment of a presented toast. This can be used to modify the appearance of a toast in specific alignments. For example, when a `Toast` is presented at the center alignment it might be preferable to use larger font and icon sizes.

#### Toast Interactive Dismiss Enabled

The toast interactive dismiss enabled flag is an *environment* value injected in the `toastInteractiveDismissEnabled` KeyPath and controls whether a toast should be dismissed as a result of a user interaction. For example, when implementing a custom toast style this flag could be checked before dismissing a toast when it is tapped.

## Alternative Presentation Contexts

By default, a Toast is presented in a separate, modal environment on the global scene context. If it is desired for a `Toast` to be presented as an overlay over a specific context such as showing a toast inside the context of a sheet presented at the `medium` presentation detent, the `toastPresentingLayout` modifier can be used.

```Swift
// Present a sheet at the medium detent and show a Toast inside
content
    .sheet(isPresented: $showSheet) {
        VStack {
            Spacer()
        
            Text("Sheet Content")

            Spacer()

            Button("Show Toast") {
                showToast = true
            }
        }
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

```

Furthermore, due to platform related limitations, on *watchOS* this modifier is __*required*__ to present a toast. In general, it is recommended that the view modified using the `toastPresentingLayout` modifier be as close as possible to the top level of the target view hierarchy.

