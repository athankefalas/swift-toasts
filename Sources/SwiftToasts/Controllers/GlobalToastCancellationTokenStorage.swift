//
//  GlobalToastCancellationTokenStorage.swift
//  SwiftToasts
//
//  Created by Αθανάσιος Κεφαλάς on 20/7/26.
//

import Foundation
import Combine

@MainActor
final class GlobalToastCancellationTokenStorage {
    static let shared = GlobalToastCancellationTokenStorage()
    
    private var storage: [AnyHashable : AnyCancellable]
    
    private init() {
        self.storage = [:]
    }
    
    func storedCancellable(forKey key: AnyHashable) -> AnyCancellable? {
        storage[key]
    }
    
    func store(cancellable: AnyCancellable, forKey key: AnyHashable) {
        storage[key] = cancellable
    }
    
    func remove(forKey key: AnyHashable) {
        storage.removeValue(forKey: key)
    }
}
