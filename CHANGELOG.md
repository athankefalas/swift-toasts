# Changelog

All notable changes to SwiftToasts are documented here.

## [0.9.9] - 2026-07-27

### Added

- Native `UIToast` (UIKit) and `NSToast` (AppKit) components for scheduling and presenting toasts outside of SwiftUI, sharing the same underlying scheduling and styling infrastructure as the SwiftUI API.
- Updates to the default `Toast` style, and expansion of the available styles to three predefined options (opaque, material, glass).
- Renamed the `plain` toast style to `material`. Transitioned the default `Toast` style from `plain` (now `material`) to `automatic`. A presented toast will now automatically use the style that best fits the platform (either material or glass, based on version).
- Relieved the platform version restrictions on using `Toast` initializers that used `Label` and `LabeledContent` as their underlying content views. Fully transitioned the default toast content to `ToastContentView`.
- Added `toastAccessibilityOptions` and related environment values and modifiers, giving explicit control over the accessibility aspects of a `Toast`, including whether a toast is visible to VoiceOver, whether it takes accessibility focus, and what's announced when it appears or is dismissed.
- Added a modifier to optionally disable interaction with the background of a `Toast` presentation.

### Fixed

- Bug fixes and improvements.
- Fixes for ornament-based presentations on visionOS.
- **iOS 26**: tap-to-dismiss stopped working under certain gesture configurations. Replaced the `ButtonStyle` + `simultaneousGesture` press-handling pattern with `PrimitiveButtonStyle` + `DragGesture`.

