//
//  PresenterPhaseObserver.swift
//  SwiftToasts
//
//  Created by Αθανάσιος Κεφαλάς on 5/11/24.
//

import SwiftUI
import Combine

@MainActor
final class PresenterPhaseObserver {
    
    enum PresenterPhase: Hashable, Comparable, Sendable {
        case active
        case inactive
    }
    
    private let presenterPhaseValueSubject: CurrentValueSubject<PresenterPhase, Never>
    private var subscriptions: Set<AnyCancellable> = []
    
    var presenterPhase: PresenterPhase {
        presenterPhaseValueSubject.value
    }
    
    init(
        presenterPhasePublisher: AnyPublisher<PresenterPhase, Never>?
    ) {
        self.presenterPhaseValueSubject = CurrentValueSubject(.active)
        beginObservingPresenterPhase(by: presenterPhasePublisher)
    }
    
    private final func beginObservingPresenterPhase(
        by publisher: AnyPublisher<PresenterPhase, Never>?
    ) {
        
        guard let publisher else {
            return
        }
        
        publisher
            .removeDuplicates()
            .sink { [weak self] phase in
                self?.transitionPresenterPhase(to: phase)
            }
            .store(in: &subscriptions)
    }
    
    private final func transitionPresenterPhase(
        to newValue: PresenterPhase
    ) {
        
        guard newValue != presenterPhaseValueSubject.value else {
            return
        }
        
        presenterPhaseValueSubject.value = newValue
    }
    
    final func presenterIsActive() async {
        guard presenterPhase != .active else {
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
        for await newValue in presenterPhaseValueSubject.values where newValue == .active {
            break
        }
    }
    
    private final func _waitSubjectUntilAppIsActive() async {
        let subscriptionStreamPair = presenterPhaseValueSubject.makeFallbackAsyncPublisherStream()
        
        for await newValue in subscriptionStreamPair.stream where newValue == .active {
            break
        }
        
        subscriptionStreamPair.subscription.cancel()
    }
}
