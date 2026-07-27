# SwiftToasts

<!-- # Badges -->
[![GitHub License](https://img.shields.io/github/license/athankefalas/swift-toasts)](https://github.com/athankefalas/swift-toasts/blob/main/LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/athankefalas/swift-toasts)](https://github.com/athankefalas/swift-toasts/releases)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fathankefalas%2Fswift-toasts%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/athankefalas/swift-toasts)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fathankefalas%2Fswift-toasts%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/athankefalas/swift-toasts)


<!-- Image -->

A toast is a transient, relatively unobtrusive visual component used to display short messages, such as status updates, or surface errors, without blocking user interaction with the main content. 

SwiftToasts is a library for SwiftUI that enables easy, fast, flexible, and configurable integration of toasts on Apple platforms, at the scene level. Built to follow the API conventions of SwiftUI, using the library feels familiar, intuitive, and truly native.

Features:

🎨 Configurable Toast style.

⚙️ Configurable Toast alignment.

🎞️ Configurable Toast transition animations.

⏲️ Deterministic scheduler based Toast presentation.

🍎 Compatible with multiple Apple platforms and all SwiftUI versions.

🛠️ Variety of ways that can be used to present Toasts using SwiftUI inspired APIs.

## Contents

- [SwiftToasts](#swifttoasts)
  - [Contents](#contents)
  - [Compatibility](#compatibility)
    - [Platform Compatibility](#platform-compatibility)
      - [WatchOS](#watchos)
  - [Installation](#installation)
  - [Creating a Toast](#creating-a-toast)
    - [Role](#role)
    - [Duration](#duration)
  - [Presenting a Toast](#presenting-a-toast)
    - [Modifiers](#modifiers)
      - [Toast](#toast)
      - [Tasks](#tasks)
    - [Buttons](#buttons)
    - [Toast Presenter Reader](#toast-presenter-reader)
    - [Native Platform Frameworks](#native-platform-frameworks)
      - [UIKit](#uikit)
      - [AppKit - Cocoa](#appkit---cocoa)
  - [Configuring a Toast Presentation](#configuring-a-toast-presentation)
    - [Style](#style)
      - [Common Styles](#common-styles)
    - [Transition](#transition)
    - [Cancellation](#cancellation)
    - [Presentation Invalidation](#presentation-invalidation)
    - [Interactive Dismissal](#interactive-dismissal)
    - [Background Content Interaction](#background-content-interaction)
    - [Accessibility Options](#accessibility-options)
  - [Toast Styling](#toast-styling)
    - [Toast Environment Values](#toast-environment-values)
      - [Toast Dismiss Action](#toast-dismiss-action)
      - [Toast Presented Role](#toast-presented-role)
      - [Toast Presented Alignment](#toast-presented-alignment)
      - [Toast Interactive Dismiss Enabled](#toast-interactive-dismiss-enabled)
      - [Toast Accessibility Options](#toast-accessibility-options)
  - [Alternative Presentation Contexts](#alternative-presentation-contexts)


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

Because watchOS does not have a platform-native dynamic view hierarchy framework such as UIKit or AppKit, SwiftToasts requires that the `toastPresentingLayout` modifier be placed at the root content view to enable toast presentation on watchOS in a compatibility mode.

## Installation

You can install SwiftToasts as a Swift package dependency by using the following URL:

    https://github.com/athankefalas/swift-toasts.git

## Creating a Toast

A `Toast` is defined as a plain SwiftUI View and requires three properties to configure and create it: the role of the Toast, the duration, and the displayed content view. Similar to common SwiftUI components, such as `Button` or `Label`, a number of initializers exist that allow the initialization of a Toast with commonly used content.

``` Swift
/// Creating a plain Toast with a title.
Toast("Hello Toast!")

/// Creating a failure Toast with a title.
Toast(
    "Something went wrong.",
    role: .failure
)

/// Creating a success Toast with a title and an icon.
Toast(
    "Settings Saved",
    systemImage: "checkmark.circle",
    role: .success
)

/// Creating a warning Toast with an icon, a title and a value subtitle.
Toast(
    "Network Offline",
    value: "Please check your connection.",
    systemImage: "network.slash",
    role: .warning
)

/// Creating a success Toast with SwiftUI views.
Toast(
    icon: Image(uiImage: song.coverArt),
    title: Text("Added to favorites"),
    valueSubtitle: Text("\(song.name) has been added to your favorites."),
    role: .success,
    duration: .short
)

/// Creating an informational Toast with custom Label content and long duration.
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

/// Creating an informational Toast with custom content and a custom duration.
Toast(role: .informational, duration: .seconds(8)) {
    Label {
        Text("Synchronizing data...")
    } icon: {
        ProgressView()
    }
}
```

### Role

The role property of a `Toast` defines the semantic purpose of the displayed content and can be used to conditionally modify the appearance of a Toast based on its role. The role of a Toast is defined using the `ToastRole` enum.

The following roles are supported:

1. Plain
   
   A role that presents a plain message with no specific purpose.

2. Informational
   
   A role that presents an informational message to the user, such as a status update or an external event.

3. Success
   
   A role that presents a success message to the user after a user-initiated operation completed successfully.
   
4. Warning
   
   A role that presents a warning message to the user after a user-initiated operation completed but encountered a recoverable error, or after a system precept has changed.

5. Failure
   
   A role that presents a failure message to the user after a user-initiated operation has failed.

### Duration

The duration of a `Toast` defines how long a Toast presentation will remain active. The duration of a Toast can be defined by using the `ToastDuration` type.

Other than the predefined duration instances that have a specific lifetime, a Toast may also be presented indefinitely by using the `ToastDuration.indefinite` duration. Please note that a Toast presented indefinitely must be explicitly dismissed, either by user interaction or by any other means that control the presentation of a Toast.

## Presenting a Toast

After a `Toast` is created, it can be scheduled for presentation in a __*separate*__, __*modal environment*__. An internal scheduler places scheduled toasts in a FIFO queue and ensures that Toasts are presented one at a time, in the order they were scheduled.

### Modifiers

The modifiers below can be used to present a `Toast` as a reaction to a trigger, an event, or a state change.

#### Toast

The `toast` modifier and its variants can be used to present a `Toast` as a reaction to a trigger, an event, or a state change. Generally, the toast modifier allows for the optional configuration of the presentation alignment, an optional dismissal callback, and a content builder closure that can be used to build the toast to present.

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

// Showing a Toast when some value changes.
content
    .toast(trigger: someValue) {
        Toast("Value changed")
    }

// Showing a Toast when some value changes from the top.
content
    .toast(
        trigger: someValue,
        alignment: .top,
        onDismiss: { print("Toast Dismissed.") }
    ) { newValue in
        Toast("Value changed to \(newValue).")
    }

// Showing a Toast when a publisher sends a new value.
content
    .toast(byReceiving: publisher) { newValue in
        Toast("Publisher sent value \(newValue).")
    }

```

#### Tasks

The toast variants of the `task` modifier can be used to schedule the presentation of a `Toast` when the presentation is a direct result of an asynchronous operation. In order to schedule the toast, the instance of `ScheduleToastAction` that is passed as an argument in the task operation must be used.

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

A `ToastButton` can be used to schedule the presentation of a `Toast` when the presentation is a direct result of a user interaction or user-triggered operation. In order to schedule the toast, the instance of `ScheduleToastAction` that is passed as an argument in the button action must be used.

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

### Toast Presenter Reader

A `Toast` can also be scheduled manually using a `ToastPresenterReader` view and the toast presenter proxy it reads from the environment. The `ToastPresenterProxy` instance can be used to schedule toasts, as well as to cancel all scheduled toasts that are still awaiting presentation.

``` Swift
ToastPresenterReader { toastPresenterProxy in
    VStack {
        Spacer()
        
        Button("Schedule Toast") {
            toastPresenterProxy.schedulePresentation(
                toast: Toast("Hello Toast!"),
                toastAlignment: .top,
                toastEnvironmentValues: ToastEnvironmentValues(
                    toastTransition: .defaultTransition
                )
            )
        }
        
        Button("Cancel Scheduled Toasts") {
            toastPresenterProxy.cancelScheduledPresentations()
        }
        
        Spacer()
    }
}
```

### Native Platform Frameworks

In addition to using SwiftUI to schedule the presentation of a `Toast`, the native platform frameworks may also be used. Please note that the native framework APIs still use the same underlying infrastructure for scheduling and presentation. Depending on the configuration, this may also include the same SwiftUI environment, or even a pure SwiftUI view hierarchy being displayed.

#### UIKit

A toast can be created on UIKit by using the `UIToast` component, which can then be scheduled for presentation by an instance of a `UIViewController`. The backing storage for the configuration of a toast is handled by the `configuration` property, which contains the values for the environment configuration as well as the content configuration of a toast. The content of the toast can also be configured directly on the `UIToast` instance by using computed properties such as `icon`, `title`, or `contentView`.

``` Swift
// Configure the UIToast content configuration
let toast = UIToast(title: "Hello, toast!")
toast.configuration.role = .success
toast.configuration.duration = .long
toast.configuration.style = .glass
toast.configuration.alignment = .bottom
toast.configuration.transition = .opacity
toast.configuration.interactiveDismissEnabled = true
toast.configuration.backgroundInteractionEnabled = false

// Or even create a new custom content configuration
public extension UIToast.Configuration {
    
    static func savedChanges() -> Self {
        var configuration = UIToast.Configuration(
            icon: UIImage.successIcon,
            title: "Saved changes",
            valueSubtitle: nil,
            role: .success,
            duration: .short
        )

        configuration.style = .glass
        return configuration
    }
}

let toast = UIToast(configuration: .savedChanges())
```

A `UIToast` can use either a standard content mode or a custom content mode, depending on which content properties are set. When using the standard content mode, the underlying content of the toast uses the same `ToastContentView` as a SwiftUI toast and maps the icon, title, and value subtitle property values to the appropriate SwiftUI components. In contrast, when using the custom content mode, the presented toast uses the configured custom `UIView`, which is hosted using a `UIViewRepresentable` and the default system layout sizing rules. In both modes, a custom background `UIView` can be set by using the `backgroundView` property. The current content mode a toast is inferred to have can be accessed by using the `inferredContentMode` property.


``` Swift
// Create a toast directly from a content configuration.
let toast = UIToast(configuration: .plain())
toast.configuration.style = .glass

// Create a toast using the standard content mode.
let toast = UIToast(title: "Hello toast!")
toast.role = .informational
toast.icon = UIImage.infoIcon
toast.valueSubtitle = makeRandomMessageOrNil()

// Create a toast using the custom content mode.
let toast = UIToast(contentView: UICustomContentView())
toast.backgroundView = UIBlurredMaterialView()
```

After an instance of `UIToast` has been created and configured, it can then be scheduled for presentation by using the `schedulePresentation` function of any active `UIViewController`. A toast that has been scheduled for presentation can be cancelled by using the `cancelScheduledPresentation` function of a `UIToast`. An actively presented toast may be dismissed by using the `dismiss` function of a `UIToast`.

Please note that cancellation and context invalidation of a `UIToast` is only supported manually, either by using the `cancelScheduledPresentation` function or by tracking the reference lifetime of a `UIToast` instance and enabling the `cancellationTracksLifetime` flag. When the flag is enabled and the instance of a toast that has not yet been presented is deallocated, the scheduled presentation is automatically cancelled.

``` Swift
class SomeViewController: UIViewController {

    func sayHi() {
        // Create a UIToast
        self.toast = UIToast(title: "Hello, Toast.")
        toast.cancellationTracksLifetime = true
        schedulePresentation(of: toast)
    }
    
    func showToast(
        favorited itemName: String,
        subtitle: String? = nil
    ) {
        // Create a UIToast
        let toast = UIToast(
            icon: UIImage(systemName: "star.fill")?
                .withRenderingMode(.alwaysTemplate),
            title: "\(itemName) added to favorites",
            valueSubtitle: subtitle
        )
        
        // Configure the toast
        toast.role = .informational
        toast.duration = .longer

        // Schedule it for presentation
        schedulePresentation(of: toast)
    }
    
    func showSuccessToast(subtitle: String? = nil) {
        // Create a UIToast using a content configuration
        let toast = UIToast(configuration: .success())
        toast.configuration.title = "Success"
        toast.configuration.valueSubtitle = subtitle
        toast.configuration.icon = UIImage(systemName: "checkmark.circle")?
            .withRenderingMode(.alwaysTemplate)
        
        schedulePresentation(of: toast)
    }

    func showBlockingHUDLoader() {
        let hudContent = HUDContentStackView()
        hudContent.axis = .vertical
        hudContent.distribution = .fillProportionally
        hudContent.spacing = 16
        hudContent.alignment = .center
        // Custom UIKit content is bridged to SwiftUI using
        // UIViewRepresentable and therefore uses the default
        // system rules for layout sizing. If a custom layout size
        // is needed, then it must be explicitly set as the 
        // view's intrinsic content size or by some other means.
        hudContent.preferredIntrinsicContentSize = CGSize(
            width: view.frame.width * 0.33,
            height: 120
        )
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        activityIndicator.color = .white
        hudContent.addArrangedSubview(activityIndicator)
        
        let label = UILabel()
        label.text = "Loading"
        label.textColor = .white
        hudContent.addArrangedSubview(label)
        
        let hudBackgroundView = UIVisualEffectView(
            effect: UIBlurEffect(
                style: .systemThinMaterialDark
            )
        )
        
        hudBackgroundView.layer.cornerRadius = 24
        hudBackgroundView.subviews.forEach({ $0.layer.cornerRadius = 24 })

        // Create a toast with custom contentView and (optionally)
        // a custom backgroundView.
        let toast = UIToast(
            contentView: hudContent,
            backgroundView: hudBackgroundView
        )
        
        // Configure the toast
        toast.configuration.role = .plain
        toast.configuration.duration = .indefinite
        toast.configuration.alignment = .center
        toast.configuration.transition = .opacity
        toast.configuration.interactiveDismissEnabled = false
        toast.configuration.backgroundInteractionEnabled = false
        
        // Schedule the toast presentation
        schedulePresentation(of: toast) {
            // When the toast appears start the loading task
            self.loadingTask = Task {
                await self.someLongOperation()
                // After the task has finished,
                // dismiss the toast
                toast.dismiss()
            }
        } onDismiss: {
            // When the toast is dismissed clean up
            self.loadingTask = nil
        }
    }
}

```

Essential information about the presentation state of a toast can be accessed by using the `isPresented` and `isScheduledForPresentation` properties. The `isScheduledForPresentation` property is true while a toast is scheduled for presentation but has not been presented yet. The `isPresented` property is true while the toast is actively being presented.

#### AppKit - Cocoa

A toast can be created on AppKit by using the `NSToast` component, which can then be scheduled for presentation by using the `toast.schedulePresentation` function and passing an instance of an `NSWindow`. The backing storage for the configuration of a toast is handled by the `configuration` property, which contains the values for the environment configuration as well as the content configuration of a toast. The content of the toast can also be configured directly on the `NSToast` instance by using computed properties such as `icon`, `title`, or `contentView`.

``` Swift
// Configure the NSToast content configuration
let toast = NSToast(title: "Hello, toast!")
toast.configuration.role = .success
toast.configuration.duration = .long
toast.configuration.style = .glass
toast.configuration.alignment = .bottom
toast.configuration.transition = .opacity
toast.configuration.interactiveDismissEnabled = true
toast.configuration.backgroundInteractionEnabled = false

// Or even create a new custom content configuration
public extension NSToast.Configuration {
    
    static func savedChanges() -> Self {
        var configuration = NSToast.Configuration(
            icon: NSImage.successIcon,
            title: "Saved changes",
            valueSubtitle: nil,
            role: .success,
            duration: .short
        )

        configuration.style = .glass
        return configuration
    }
}

let toast = NSToast(configuration: .savedChanges())
```

An `NSToast` can use either a standard content mode or a custom content mode, depending on which content properties are set. When using the standard content mode, the underlying content of the toast uses the same `ToastContentView` as a SwiftUI toast and maps the icon, title, and value subtitle property values to the appropriate SwiftUI components. In contrast, when using the custom content mode, the presented toast uses the configured custom `NSView`, which is hosted using an `NSViewRepresentable` and the default system layout sizing rules. In both modes, a custom background `NSView` can be set by using the `backgroundView` property. The current content mode a toast is inferred to have can be accessed by using the `inferredContentMode` property.


``` Swift
// Create a toast directly from a content configuration.
let toast = NSToast(configuration: .plain())
toast.configuration.style = .glass

// Create a toast using the standard content mode.
let toast = NSToast(title: "Hello toast!")
toast.role = .informational
toast.icon = NSImage.infoIcon
toast.valueSubtitle = makeRandomMessageOrNil()

// Create a toast using the custom content mode.
let toast = NSToast(contentView: NSCustomContentView())
toast.backgroundView = NSBlurredMaterialView()
```

After an instance of `NSToast` has been created and configured, it can then be scheduled for presentation by using the `schedulePresentation` function and passing an active `NSWindow` as the presentation target. A toast that has been scheduled for presentation can be cancelled by using the `cancelScheduledPresentation` function of an `NSToast`. An actively presented toast may be dismissed by using the `dismiss` function of an `NSToast`.

Please note that cancellation and context invalidation of an `NSToast` is only supported manually, either by using the `cancelScheduledPresentation` function or by tracking the reference lifetime of an `NSToast` instance and enabling the `cancellationTracksLifetime` flag. When the flag is enabled and the instance of a toast that has not yet been presented is deallocated, the scheduled presentation is automatically cancelled.

``` Swift
class SomeViewController: NSViewController {
    
    func sayHi() {
        // Create an NSToast
        let toast = NSToast(title: "Hello, Toast.")
        toast.cancellationTracksLifetime = true
        toast.schedulePresentation(in: view.window!)
    }
    
    func showToast(
        favorited itemName: String,
        subtitle: String? = nil
    ) {
        // Create an NSToast
        let toast = NSToast(
            icon: NSImage(
                systemSymbolName: "star.fill",
                accessibilityDescription: "Star"
            ),
            title: "\(itemName) added to favorites",
            valueSubtitle: subtitle
        )
        
        // Configure the toast
        toast.role = .informational
        toast.duration = .longer

        // Schedule it for presentation
        toast.schedulePresentation(in: view.window!)
    }
    
    func showSuccessToast(subtitle: String? = nil) {
        // Create an NSToast using a content configuration
        let toast = NSToast(configuration: .success())
        toast.configuration.title = "Success"
        toast.configuration.valueSubtitle = subtitle
        toast.configuration.icon = NSImage(
            systemSymbolName: "checkmark.circle",
            accessibilityDescription: "checkmark"
        )
        
        toast.schedulePresentation(in: view.window!)
    }
    
    func showBlockingHUDLoader() {
        let hudContent = HUDContentStackView()
        hudContent.orientation = .vertical
        hudContent.distribution = .fillProportionally
        hudContent.spacing = 16
        hudContent.alignment = .centerY
        // Custom NSView content is bridged to SwiftUI using
        // NSViewRepresentable and therefore uses the default
        // system rules for layout sizing. If a custom layout size
        // is needed, then it must be explicitly set as the
        // view's intrinsic content size or by some other means.
        hudContent.preferredIntrinsicContentSize = CGSize(
            width: view.frame.width * 0.33,
            height: 120
        )
        
        let activityIndicator = NSProgressIndicator()
        activityIndicator.style = .spinning
        hudContent.addArrangedSubview(activityIndicator)
        
        let label = NSTextField(labelWithString: "Loading")
        label.textColor = .white
        hudContent.addArrangedSubview(label)
        
        let hudBackgroundView = NSVisualEffectView()
        hudBackgroundView.material = .hudWindow
        hudBackgroundView.wantsLayer = true
        hudBackgroundView.layer?.cornerRadius = 24
        hudBackgroundView.subviews.forEach({ $0.layer?.cornerRadius = 24 })

        // Create a toast with custom contentView and (optionally)
        // a custom backgroundView.
        let toast = NSToast(
            contentView: hudContent,
            backgroundView: hudBackgroundView
        )
        
        // Configure the toast
        toast.configuration.role = .plain
        toast.configuration.duration = .indefinite
        toast.configuration.alignment = .center
        toast.configuration.transition = .opacity
        toast.configuration.interactiveDismissEnabled = false
        toast.configuration.backgroundInteractionEnabled = false
        
        // Schedule the toast presentation
        toast.schedulePresentation(in: view.window!) {
            // When the toast appears start the loading task
            self.loadingTask = Task {
                await self.someLongOperation()
                // After the task has finished,
                // dismiss the toast
                toast.dismiss()
            }
        } onDismiss: {
            // When the toast is dismissed clean up
            self.loadingTask = nil
        }
    }
}
```

Essential information about the presentation state of a toast can be accessed by using the `isPresented` and `isScheduledForPresentation` properties. The `isScheduledForPresentation` property is true while a toast is scheduled for presentation but has not been presented yet. The `isPresented` property is true while the toast is actively being presented.

## Configuring a Toast Presentation

Most of the aspects of a Toast or its presentation can be configured using several *environment* based modifiers.

### Style

The style of a Toast can be configured similarly to most system-provided SwiftUI components by using the related `.toastStyle` modifier. The library ships with a few predefined styles that use a rounded-rectangle-shaped toast draped with various system materials and/or glass, but if further customization is required, a custom style can easily be created by conforming to the `ToastStyle` protocol. The default style is `.automatic`.

Please note that, depending on the `Toast` initializer used, the generated content view *inside* may resolve to a `ToastContentView`. Any custom toast styles may have to account for the default layout/styling of this view and customize it as needed to achieve the exact layout required. The layout/styling of the toast content view can be customized by creating a custom `ToastContentStyle` and applying it from a custom `ToastStyle` by using the `.toastContentStyle` modifier. The default toast content style is `.standard`. 

In addition to the toast content view, specialized styles for `Label`, `LabeledContent`, and `Button` views, as well as a predefined tint and font size, are also automatically applied inside toasts.

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
.toastStyle(.automatic)

// Showing a Toast with the material style.
ToastButton("Show Toast") { schedule in
    schedule(
        toast: Toast(
            "Hello!",
            systemImage: "hand.wave.fill",
            role: .informational
        )
    )
}
.toastStyle(.material)

// Showing a Toast with the glass style (supported on iOS 26 / macOS 26 and later).
ToastButton("Show Toast") { schedule in
    schedule(
        toast: Toast(
            "Hello!",
            systemImage: "hand.wave.fill",
            role: .informational
        )
    )
}
.toastStyle(.glass)

// Showing a Toast with the plain style.
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

#### Common Styles

| Style Name           | Short Name        | Description |
|----------------------|-------------------|-------------|
| -                    | `.automatic`      | A symbolic toast style which resolves to either `.material` or `.glass` based on the platform and / or version. |
| `MaterialToastStyle`   | `.material`       | A toast style that uses system materials. The material thickness can be configured by creating a style using the full `MaterialToastStyle.init`. |
| `GlassToastStyle`      | `.glass`          | A toast style that uses LiquidGlass materials. This style is only available on platforms that support LiquidGlass (iOS 26.0 and later, macOS 26.0 and later, tvOS 26.0 and later, watchOS 26.0 and later, visionOS 26.0 and later). The LiquidGlass attributes can be configured by creating a style using the full `GlassToastStyle.init`.  |
| `PlainToastStyle`      | `.plain`          | A toast style that uses solid color. The solid color can be optionally tinted by creating a style using the full `PlainToastStyle.init`. |

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

After a `Toast` is created, it is scheduled for presentation in a queue. A scheduled Toast may be cancelled *before* it is presented, by the source it was scheduled from, depending on context and the active environment configuration. 

By default, a scheduled toast will not be cancelled unless the scene containing its source is dismissed. The cancellation policy in the current environment can be configured by using the `toastCancellation` modifier.

Please note that cancellation only affects Toasts that have not yet been presented and are still waiting for presentation in the scheduler's queue.

For example, when firing a form submission action using a `ToastButton`, it might be desirable to *save* the updated values of the form and immediately dismiss the scene. In order for the scheduled presentation to not be cancelled, the `.never` cancellation policy is required.

``` Swift 
// The button below saves the form, starts the dismissal of the active scene
// and then schedules a Toast. By using the `.never` cancellation policy the
// scheduled Toast will not be cancelled when the active scene is dismissed.
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

Alternatively, when a toast is scheduled by using a state change trigger, it might be desirable to avoid scheduling numerous toasts when a value changes rapidly and frequently. In order to automatically cancel all scheduled toasts from a specific source, the `.always` cancellation policy is required.

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

While toasts are usually a fire-and-forget component, there is a limited capability to dismiss already presented toasts. Specifically, the `toast` modifier and its variants use a trigger value as context to determine when to schedule a `Toast`. By default, whenever the value changes again, an already displayed toast is automatically dismissed, since the *context that triggered it* has changed. This behavior can be easily configured by using the `toastPresentationInvalidation` modifier.

For example, it might be desirable to configure a toast triggered by a value change to automatically dismiss when the value changes *and* when the source's scene is dismissed.

``` Swift
// A change of the volume value triggers a toast.
// By using the `.contextChanged, .presentationDismissed` presentation
// invalidation options, an already presented Toast will be dismissed when
// the slider's value changes and when its container is dismissed.
Slider(value: $volume, in: 0...100) {
    Text("Volume: \(volume)%")
}
.toast(trigger: volume) { newValue in
    Toast("Volume set to \(newValue)%.")
}
.toastCancellation(.always)
.toastPresentationInvalidation([.contextChanged, .presentationDismissed])
```

Alternatively, if it is desired that the active toast presentation never be invalidated, the `.never` presentation invalidation can be used instead.

### Interactive Dismissal

A presented `Toast`, when using one of the standard styles, can be dismissed before its duration has elapsed as a result of a user tapping the content of the toast. This behavior can be controlled by using the `toastInteractiveDismissDisabled` modifier. A common use case for preventing interactive dismissal is when using a toast as a loading indicator.

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
    .toastBackgroundInteractionDisabled(true)

```

### Background Content Interaction

While a `Toast` is presented, interaction with the background content can be turned on or off. The background content interaction mode can be configured by using the `toastBackgroundInteractionDisabled` modifier. In the same loading-indicator HUD example, background interaction can be disabled to avoid any interaction while the view is still loading. 

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
    .toastBackgroundInteractionDisabled(true)

```

### Accessibility Options

A wide variety of accessibility options for a presented `Toast` can be configured by using the `toastAccessibilityOptions` and related environment-based modifiers. These options can affect various aspects of the accessibility of a Toast, including visibility, label, traits, identifiers, automatic focus, and even announcements tied to the lifetime of the toast.

Because toasts are generally presented __*modally*__ and possibly rather __*frequently*__, having them fully visible to the accessibility system may overwhelm users who rely on VoiceOver to navigate your app. For this reason, it is recommended to rely on accessibility announcements instead, and a `Toast` is not accessible by default — it must be explicitly marked as accessible.

``` Swift
// Toasts scheduled by the environment inside content will be hidden.
// This is the default behavior.
content
    .toastAccessibilityOptions(.hidden)

// Toasts scheduled by the environment inside content will be visible,
// and will automatically gain accessibility focus when presented.
content
    .toastAccessibilityOptions(.visible)

// Toasts scheduled by the environment inside content will be visible,
// and will automatically gain accessibility focus when presented. Also,
// an accessibility dismiss action and an announcement will be attached.
content
    .toastAccessibilityOptions(
        .accessible(
            dismissActionName: "Dismiss Toast",
            appearanceAnnouncement: "Toast Appeared. Dismiss to continue."
        )
    )

// Toasts scheduled by the environment inside content will have a custom
// accessibility behavior. They will be visible to the accessibility system,
// but they will not gain focus and instead an announcement will be attached when they appear.
content
    .toastAccessibilityOptions(
        ToastAccessibilityOptions(
            accessibilityHidden: false,
            accessibilityManageFocus: false,
            accessibilityOnAppearAnnouncement: "Toast Appeared."
        )
    )

// Toasts scheduled by the environment inside content will have a custom
// accessibility behavior. They will be visible to the accessibility system,
// but they will not gain focus and instead an announcement will be attached when they appear.
// This is effectively the same configuration as above, but uses modifiers to affect the
// toast accessibility options individually.
content
    .toastAccessibilityHidden(false)
    .toastAccessibilityManagesFocus(false)
    .toastAccessibilityAppearedAnnouncement("Toast Appeared.")

// Toasts scheduled by the environment inside content will have the
// accessibility behavior defined by their parent, but an announcement
// will also be attached when they appear.
content.toastAccessibilityAppearedAnnouncement("Toast Appeared.")

// Sets up accessibility identifiers to Toast and its content.
// This configuration may be useful for testing purposes.
content
    .toastAccessibilityHidden(false)
    .toastAccessibilityIconHidden(true)
    .toastContentAccessibilityIdentifiers(
        ToastAccessibilityOptions.AccessibilityIdentifiers(
            title: "Toast.Title",
            subtitle: "Toast.Subtitle"
        )
    )
```

## Toast Styling

When a `Toast` is presented its appearance is retrieved by the source's environment. A custom style can be implemented by creating a struct that conforms to the `ToastStyle` protocol.

By using the `configuration` parameter and leveraging several environment values, a custom toast style can provide a detailed and adaptive visual representation of a toast's contents.

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

        // An alias of `configuration.role` that is injected via the environment
        @Environment(\.toastPresentedRole)
        private var toastPresentedRole
        
        @Environment(\.toastPresentedAlignment)
        private var toastPresentedAlignment
        
        @Environment(\.toastInteractiveDismissEnabled)
        private var toastInteractiveDismissEnabled

        @Environment(\.toastAccessibilityOptions)
        private var toastAccessibilityOptions
        
        let configuration: Configuration
        
        private var shape: AnyShape {
            if toastPresentedAlignment == .center {
                return AnyShape(RoundedRectangle(cornerRadius: 12))
            } else {
                return AnyShape(Capsule())
            }
        }
        
        private var color: Color {
            switch configuration.role {
            case .failure:
                return .red
            case .warning:
                return .yellow
            default:
                return .accentColor
            }
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
                .labelStyle(.someStyle) // Apply a Label style
                .labeledContentStyle(.someStyle) // Apply a LabeledContent style
                .toastContentStyle(.someStyle) // Apply a ToastContentView style
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

A set of different *environment* values is injected into a presented toast to enable further customization of the visual content of a `Toast`, or to provide a programmatic dismissal action. These values are not available in the environment that scheduled the toast presentation; they are injected by the environment that actively displays the `Toast` when it presents it.

#### Toast Dismiss Action

The toast dismiss action is an environment value injected into the `toastDismiss` KeyPath and contains an action that can be used to programmatically dismiss a toast depending on a specific user interaction.

Please note that the scheduler automatically handles the duration of a toast, so there is no need for a custom toast style to handle automatic dismissal based on the duration of a presented `Toast`.

#### Toast Presented Role
The toast presented role is an *environment* value injected into the `toastPresentedRole` KeyPath and contains the role of the presented toast. This can be used by custom component styles, such as custom `Label`, `LabeledContent`, or `ToastContentView` styles, to adjust their layout, visual properties, and behavior.

#### Toast Presented Alignment

The toast presented alignment is an *environment* value injected into the `toastPresentedAlignment` KeyPath and contains the alignment of a presented toast. This can be used to modify the appearance of a toast for specific alignments. For example, when a `Toast` is presented at the center alignment, it might be preferable to use larger font and icon sizes.

#### Toast Interactive Dismiss Enabled

The toast interactive dismiss enabled flag is an *environment* value injected into the `toastInteractiveDismissEnabled` KeyPath and controls whether a toast should be dismissed as a result of a user interaction. For example, when implementing a custom toast style, this flag could be checked before dismissing a toast when it is tapped.

#### Toast Accessibility Options
The toast accessibility options value is an *environment* value injected into the `toastAccessibilityOptions` KeyPath and contains the accessibility options defined by the presenting environment. These options can be used to read and set specific accessibility identifiers and actions for a `Toast` layout. The value of the `toastAccessibilityOptions` environment key is a copy of the value that existed in the presenting environment at the moment it scheduled the presentation.

## Alternative Presentation Contexts

By default, a Toast is presented in a separate, modal environment at the global scene level. If it is desired for a `Toast` to be presented as an overlay over a specific context, such as showing a toast inside the context of a sheet presented at the `medium` presentation detent, the `toastPresentingLayout` modifier can be used.

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

Furthermore, due to platform-related limitations, this modifier is __*required*__ on *watchOS* to present a toast. In general, it is recommended that the view modified using the `toastPresentingLayout` modifier be as close as possible to the top level of the target view hierarchy.

