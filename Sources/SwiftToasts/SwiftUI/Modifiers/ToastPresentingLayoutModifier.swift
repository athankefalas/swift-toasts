//
//  ToastPresentingLayoutModifier.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 2/11/24.
//

import SwiftUI
import Combine

private struct ToastPresentingLayoutModifier: ViewModifier {
    
    @MainActor
    final class ToastPresenter: ObservableObject, ToastPresenting, Sendable {
        
        @Published
        private(set) var toastPresentation: ToastPresentation?
        
        var hasAppeared: Bool = false {
            didSet {
                _presenterPhaseSubject?.send(hasAppeared ? .active : .inactive)
            }
        }
        
        var accessibilityReduceMotion: Bool = false
        var accessibilityReduceTransparency: Bool = false
        
        var toastScheduler: ToastScheduler {
            _toastScheduler!
        }
        
        var presentationSpace: ToastPresentationSpace {
            .explicitLayout
        }
        
        private var _toastScheduler: ToastScheduler?
        private var _presenterPhaseSubject: CurrentValueSubject<PresenterPhaseObserver.PresenterPhase, Never>?
        private var presentationTask: Task<Void, Never>?
        
        init() {
            _presenterPhaseSubject = CurrentValueSubject(.inactive)
            _toastScheduler = ToastScheduler(
                presenterID: ObjectIdentifier(self),
                presenterPhasePublisher: _presenterPhaseSubject?.eraseToAnyPublisher()
            ) { [weak self] toastPresentation in
                self?.handle(toastPresentation: toastPresentation)
            }
        }
        
        final func prepareForToastPresentationIfNeeded() {}
        
        private final func handle(toastPresentation: ToastPresentation) {
            presentationTask?.cancel()
            toastPresentation.onPresent?()
            self.toastPresentation = toastPresentation
            
            let insertionAnimationDuration = approximateAnimationDuration(
                for: .toastInsertion,
                of: toastPresentation
            )
            
            Task { @MainActor in
                try? await Task.sleep(seconds: insertionAnimationDuration)
                self.presentationTask = makePresentationTask(for: toastPresentation)
            }
        }
        
        private final func makePresentationTask(
            for toastPresentation: ToastPresentation
        ) -> Task<Void, Never> {
            return Task {
                defer {
                    presentationTask = nil
                    toastPresentation.presentationCanceller?
                        .removeHandler()
                }
                
                toastPresentation.presentationCanceller?
                    .setHandler { [weak self] in
                        self?.presentationTask?.cancel()
                    }
                
                try? await Task.sleep(
                    duration: toastPresentation.toast.configuration.duration
                )
                
                stopPresentation(of: toastPresentation)
            }
        }
        
        private final func stopPresentation(
            of toastPresentation: ToastPresentation
        ) {
            self.toastPresentation = nil
            let removalAnimationDuration = approximateAnimationDuration(
                for: .toastRemoval,
                of: toastPresentation
            )
            
            Task { @MainActor in
                try? await Task.sleep(seconds: removalAnimationDuration)
                toastPresentation.onDismiss?()
            }
        }
        
        private final func approximateAnimationDuration(
            for phase: ToastTransition.PresentationPhase,
            of presentation: ToastPresentation
        ) -> TimeInterval {
            let context = ToastTransition.Context(
                phase: phase,
                geometry: .zero,
                windowGeometry: .zero,
                platformIdiom: .current,
                isReduceMotionEnabled: accessibilityReduceMotion,
                isReduceTransparencyEnabled: accessibilityReduceTransparency,
                presentation: presentation
            )
            
            return presentation
                .toastTransition
                .duration(context)
        }
        
        final func dismissToast() {
            presentationTask?.cancel()
        }
    }
    
    @Environment(\.toastPresenter)
    private var outterToastPresenter
    
    @Environment(\.accessibilityReduceMotion)
    private var accessibilityReduceMotion
    
    @Environment(\.accessibilityReduceTransparency)
    private var accessibilityReduceTransparency
    
    @State
    private var toastPresentingLayoutGeometry: ToastPresentingLayoutGeometry?
    
    @FallbackStateObject
    private var toastPresenter = ToastPresenter()
    
    let layoutPresentationEnabled: Bool
    
    private var innerToastPresenter: ToastPresenterProxy {
        
        guard layoutPresentationEnabled else {
            return outterToastPresenter
        }
        
        guard outterToastPresenter.presentationSpace != .explicitLayout else {
            return outterToastPresenter
        }
        
        return ToastPresenterProxy(toastPresenter: toastPresenter)
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .environment(\.toastPresenter, innerToastPresenter)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: ToastPresentingLayoutGeometryPreferenceKey.self,
                                value: ToastPresentingLayoutGeometry(geometry)
                            )
                    }
                )
                .onPreferenceChange(ToastPresentingLayoutGeometryPreferenceKey.self) { newValue in
                    toastPresentingLayoutGeometry = newValue
                }
            
            ZStack(
                alignment: makeAlignment(
                    from: toastPresenter.toastPresentation?.toastAlignment ?? .center
                )
            ) {
                Color.clear
                
                if let toastPresentation = toastPresenter.toastPresentation {
                    HostedToastContent(hosting: toastPresentation) {
                        toastPresenter.dismissToast()
                    }
                    .transition(
                        .bridgedToastTransition(toastPresentation)
                    )
                }
            }
            .environment(\.toastPresentingLayoutGeometry, toastPresentingLayoutGeometry)
            .layoutPriority(-1)
        }
        .fallbackOnChange(of: accessibilityReduceMotion) { newValue in
            toastPresenter.accessibilityReduceMotion = newValue
        }
        .fallbackOnChange(of: accessibilityReduceTransparency) { newValue in
            toastPresenter.accessibilityReduceTransparency = newValue
        }
        .onAppear {
            toastPresenter.hasAppeared = true
            toastPresenter.accessibilityReduceMotion = accessibilityReduceMotion
            toastPresenter.accessibilityReduceTransparency = accessibilityReduceTransparency
        }
        .onDisappear {
            toastPresenter.hasAppeared = false
        }
    }
    
    private func makeAlignment(
        from toastAlignment: ToastAlignment
    ) -> Alignment {
        var verticalAlignment = VerticalAlignment.center
        var horizontalAlignment = HorizontalAlignment.center
        
        if toastAlignment.rawValue.contains(.vertical) {
            verticalAlignment = .center
        } else if toastAlignment.rawValue.contains(.top) {
            verticalAlignment = .top
        } else if toastAlignment.rawValue.contains(.bottom) {
            verticalAlignment = .bottom
        }
        
        if toastAlignment.rawValue.contains(.horizontal) {
            horizontalAlignment = .center
        } else if toastAlignment.rawValue.contains(.leading) {
            horizontalAlignment = .leading
        } else if toastAlignment.rawValue.contains(.trailing) {
            horizontalAlignment = .trailing
        }
        
        return Alignment(
            horizontal: horizontalAlignment,
            vertical: verticalAlignment
        )
    }
}

public extension View {
    
    /// Presents toasts in this view layout instead of being presented at the scene level.
    /// - Parameter enabled: Controls whether layout level toast presentation is enabled.
    /// - Returns: A modified view.
    ///
    /// The presented toasts are directly added as SwiftUI overlays of the modified view. As a result,
    /// some of the animation properties during transition may be *slightly* different than toasts presented
    /// at the scene level, which are presented using the platform native UI framework. Furthermore,
    /// the safe area insets of the toast **must be explicitly handled** as using the `ignoresSafeArea`
    /// modifier would also affect any parent layout.
    ///
    /// - Note: In platforms that do not allow for dynamic layouts, such as watchOS, using
    /// this modifier is *required* to present toasts.
    func toastPresentingLayout(_ enabled: Bool = true) -> some View {
        self.modifier(
            ToastPresentingLayoutModifier(
                layoutPresentationEnabled: enabled
            )
        )
    }
}

// MARK: Previews

#if DEBUG

#Preview {
    PresentedPreview {
        VStack {
            Spacer()
            
            ToastButton { proxy in
                proxy.schedule(
                    toast: Toast("Hello Toast!"),
                    alignment: .top
                )
            } label: {
                Text("Show Toast")
            }
            .toastTransition(
                ToastTransition.opacity
                    .curve(.easeInOut)
                    .duration(1)
            )
            
            NavigationLink("Details") {
                Text("Details")
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .toastPresentingLayout()
    }
}

#endif
