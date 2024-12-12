//
//  ScenePhaseObserver.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 6/10/24.
//

import SwiftUI
import Combine

#if canImport(UIKit)
import UIKit
#endif

#if canImport(Cocoa)
import Cocoa
#endif

@MainActor
final class ScenePhaseObserver {
    
    enum ScenePhase: Hashable, Comparable, Sendable {
        case background
        case inactive
        case active
    }
    
    private let sceneID: ObjectIdentifier
    private let scenePhaseValueSubject: CurrentValueSubject<ScenePhase, Never>
    private var subscriptions: Set<AnyCancellable> = []
    
    var scenePhase: ScenePhase {
        scenePhaseValueSubject.value
    }
    
    init(
        sceneID: ObjectIdentifier
    ) {
        self.sceneID = sceneID
        self.scenePhaseValueSubject = CurrentValueSubject(.active)
        beginObservingScenePhase()
    }
    
    private final func beginObservingScenePhase() {
#if canImport(UIKit) && !os(watchOS)
        beginObservingUIKitScenePhase()
#elseif canImport(Cocoa)
        beginObservingCocoaScenePhase()
#endif
    }
    
#if canImport(UIKit) && !os(watchOS)
    private final func beginObservingUIKitScenePhase() {
        NotificationCenter.default
            .publisher(for: UIApplication.willResignActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.transitionScenePhase(to: .inactive)
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.transitionScenePhase(to: .active)
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: UIApplication.didEnterBackgroundNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.transitionScenePhase(to: .background)
            }
            .store(in: &subscriptions)
    }
#endif
    
#if canImport(Cocoa)
    private final func beginObservingCocoaScenePhase() {
        NotificationCenter.default
            .publisher(for: NSApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.transitionScenePhase(to: .background)
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: NSApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.transitionScenePhase(to: .active)
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: NSWindow.willCloseNotification)
            .compactMap({ $0.object as? NSWindow })
            .sink { [weak self] window in
                guard self?.sceneID == ObjectIdentifier(window) else {
                    return
                }
                
                self?.transitionScenePhase(to: .background)
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: NSWindow.didMiniaturizeNotification)
            .compactMap({ $0.object as? NSWindow })
            .sink { [weak self] window in
                guard self?.sceneID == ObjectIdentifier(window) else {
                    return
                }
                
                self?.transitionScenePhase(to: .background)
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(for: NSWindow.didBecomeMainNotification)
            .compactMap({ $0.object as? NSWindow })
            .sink { [weak self] window in
                guard self?.sceneID == ObjectIdentifier(window) else {
                    return
                }
                
                self?.transitionScenePhase(to: .active)
            }
            .store(in: &subscriptions)
    }
#endif
    
    private final func transitionScenePhase(
        to newValue: ScenePhase
    ) {
        guard newValue != scenePhaseValueSubject.value else {
            return
        }
        
        scenePhaseValueSubject.value = newValue
    }
    
    final func appIsActive() async {
        guard scenePhase != .active else {
            return
        }
        
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            await _waitSequenceUntilAppIsActive()
        } else {
            await _waitSubjectUntilAppIsActive()
        }
    }
    
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    private final func _waitSequenceUntilAppIsActive() async {
        for await newValue in scenePhaseValueSubject.values where newValue == .active {
            break
        }
    }
    
    private final func _waitSubjectUntilAppIsActive() async {
        let subscriptionStreamPair = scenePhaseValueSubject.makeFallbackAsyncPublisherStream()
        
        for await newValue in subscriptionStreamPair.stream where newValue == .active {
            break
        }
        
        subscriptionStreamPair.subscription.cancel()
    }
}
