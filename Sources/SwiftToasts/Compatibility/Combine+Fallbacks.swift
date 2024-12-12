//
//  Combine+Fallbacks.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 31/10/24.
//

@preconcurrency import Combine

extension AnyPublisher: @unchecked @retroactive Sendable {}

extension Publisher where Output: Sendable, Failure == Never {
    
    func makeFallbackAsyncPublisherStream() -> (subscription: AnyCancellable, stream: AsyncStream<Output>) {
        let streamContinuationPair = AsyncStream.makeStream(of: Output.self)
        let subscription = self.sink { output in
            streamContinuationPair.continuation.yield(output)
        }
        
        return (subscription, streamContinuationPair.stream)
    }
}
