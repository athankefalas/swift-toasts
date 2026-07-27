# Changelog

All notable changes to SwiftToasts are documented here.

## [0.9.9] - 2026-07-27

### Added

- Native `UIToast` (UIKit) and `NSToast` (AppKit) components for scheduling and presenting toasts outside of SwiftUI, sharing the same underlying scheduling and styling infrastructure as the SwiftUI API.
- Updates to default `Toast` style and addition of three predefined styles (plain, material, glass). A presented toast will now use the style that best fits the platform (either material or glass, based on version).
- Renamed `plain` toast style to `material`. Transitioned default `Toast` style from `plain` (now renamed to material) to `automatic`.
- Relieved the platform version restrictions of using `Toast` initializers that used `Label` and `LabeledContent` as their underlying content views. Fully transitioned default toast content to `ToastContentView`.
- Added `toastAccessibilityOptions` and related environment values and modifiers, giving explicit direct control over the accessibility aspects of a `Toast`, including whether a toast is visible to VoiceOver, whether it takes accessibility focus, and what's announced when it appears or is dismissed.
- Added an optional modifier to conditionally disable interaction with the backgrounds of a `Toast` presentation.

### Fixed

- General bug fixes and improvements.
- Fixes for ornament-based presentations on visionOS.
- **iOS 26**: tap-to-dismiss stopped working under certain gesture configurations. Replaced the `ButtonStyle` + `simultaneousGesture` press-handling pattern with `PrimitiveButtonStyle` + `DragGesture`.

