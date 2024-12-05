//
//  ToastPresentationAnimation.swift
//  ToastPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 7/10/24.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(Cocoa)
import Cocoa
import QuartzCore
#endif

/// A transition than can be used to insert and remove a toast presentation.
public struct ToastTransition: Identifiable, Equatable, Sendable {
    
    /// The phase of the toast transition.
    public enum PresentationPhase: Sendable, Hashable {
        case toastInsertion
        case toastRemoval
    }
    
    /// The curve used to animate the transition of a toast.
    public enum AnimationCurve: Sendable, Hashable {
        case `default`
        case linear
        case easeIn
        case easeOut
        case easeInOut
        case spring(mass: Double = 1, stiffness: Double, damping: Double, initialVelocity: CGFloat = 0, allowOverDamping: Bool = false)
    }
    
    /// A type that holds contextual information about the toast, platform, view hierarchy and transition phase.
    ///
    /// When implementing a custom toast transition the values of this type can be used to help decide different
    /// aspects of a transition animation at runtime. For example, if the `isReduceMotionEnabled` is enabled
    /// in the system the animation may conditionally not include motion.
    public struct Context: Sendable, Hashable {
        public let phase: PresentationPhase
        public let geometry: CGRect
        public let windowGeometry: CGRect
        public let platformIdiom: PlatformIdiom
        public let isReduceMotionEnabled: Bool
        public let isReduceTransparencyEnabled: Bool
        public let toastRole: ToastRole
        public let toastDuration: ToastDuration
        public let toastAlignment: ToastAlignment
        
        @inlinable
        public var platformUsesFlippedCoordinateSystem: Bool {
#if os(macOS)
            return true
#else
            return false
#endif
        }
        
        init(
            phase: PresentationPhase,
            geometry: CGRect,
            windowGeometry: CGRect,
            platformIdiom: PlatformIdiom,
            isReduceMotionEnabled: Bool,
            isReduceTransparencyEnabled: Bool,
            presentation: ToastPresentation
        ) {
            self.phase = phase
            self.geometry = geometry
            self.windowGeometry = windowGeometry
            self.platformIdiom = platformIdiom
            self.isReduceMotionEnabled = isReduceMotionEnabled
            self.isReduceTransparencyEnabled = isReduceTransparencyEnabled
            self.toastRole = presentation.toast.configuration.role
            self.toastDuration = presentation.toast.configuration.duration
            self.toastAlignment = presentation.toastAlignment
        }
    }
    
    /// The identity of a toast transition.
    ///
    /// - Invariant: Two transitions that have the same identity must be, and are in fact, considered equal.
    public let id: Int
    internal private(set) var curve: @MainActor (Context) -> AnimationCurve
    internal private(set) var delay: @MainActor (Context) -> TimeInterval
    internal private(set) var duration: @MainActor (Context) -> TimeInterval
    internal private(set) var animationProperties: @MainActor (Context) -> [AnyAnimationProperty]
    
    public init<ID: Hashable>(
        id: ID,
        curve: @escaping @MainActor (Context) -> AnimationCurve,
        delay: @escaping @MainActor (Context) -> TimeInterval,
        duration: @escaping @MainActor (Context) -> TimeInterval,
        @AnimatablePropertiesBuilder animationProperties: @escaping @MainActor (Context) -> [AnyAnimationProperty]
    ) {
        self.id = id.hashValue
        self.curve = curve
        self.delay = delay
        self.duration = duration
        self.animationProperties = animationProperties
    }
    
    public init<ID: Hashable>(
        id: ID,
        curve: AnimationCurve = .default,
        delay: TimeInterval = 0,
        duration: TimeInterval = 0.3,
        @AnimatablePropertiesBuilder animationProperties: @escaping @MainActor (Context) -> [AnyAnimationProperty]
    ) {
        self.id = id.hashValue
        self.curve = { @MainActor _ in curve }
        self.delay = { @MainActor _ in delay }
        self.duration = { @MainActor _ in duration }
        self.animationProperties = animationProperties
    }
    
    /// Modifies the toast transition by applying the given curve.
    /// - Parameter curve: The  curve this transition will use when animating.
    /// - Returns: A modified `ToastTransition`.
    public func curve(
        _ curve: AnimationCurve
    ) -> ToastTransition {
        var mutableCopy = self
        mutableCopy.curve = { @MainActor _ in
            curve
        }
        
        return mutableCopy
    }
    
    /// Modifies the toast transition by applying the given delay.
    /// - Parameter delay: The  delay this transition will use when animating.
    /// - Returns: A modified `ToastTransition`.
    public func delay(
        _ delay: TimeInterval
    ) -> ToastTransition {
        var mutableCopy = self
        mutableCopy.delay = { @MainActor _ in
            delay
        }
        
        return mutableCopy
    }
    
    /// Modifies the toast transition by applying the given duration.
    /// - Parameter duration: The  duration this transition will use when animating.
    /// - Returns: A modified `ToastTransition`.
    public func duration(
        _ duration: TimeInterval
    ) -> ToastTransition {
        var mutableCopy = self
        mutableCopy.duration = { @MainActor _ in
            duration
        }
        
        return mutableCopy
    }
    
    public static func == (lhs: ToastTransition, rhs: ToastTransition) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: Toast Transition Combination
    
    /// Returns a new `ToastTransition` by combining this transiton with the given secondary transition.
    /// - Parameter other: The secondary transition to perform alongside this one.
    public func combined(
        with other: ToastTransition
    ) -> ToastTransition {
        return ToastTransition(
            id: _combinedHash(of: id, and: other.id),
            curve: other.curve,
            delay: other.delay,
            duration: other.duration
        ) { context in
            self.animationProperties(context)
            other.animationProperties(context)
        }
    }
    
    /// Returns an asymmetric `ToastTransition` by using the given insertion and removal transitons.
    /// - Parameters:
    ///   - insertion: The insertion `ToastTransition` to use when animating the insertion of a toast.
    ///   - removal: The removal `ToastTransition` to use when animating the removal of a toast.
    public static func asymmetric(
        insertion: ToastTransition,
        removal: ToastTransition
    ) -> ToastTransition {
        return ToastTransition(
            id: _combinedHash(of: insertion.id, and: removal.id)
        ) { context in
            switch context.phase {
                case .toastInsertion:
                    return insertion.curve(context)
                case .toastRemoval:
                    return removal.curve(context)
            }
        } delay: { context in
            switch context.phase {
                case .toastInsertion:
                    return insertion.delay(context)
                case .toastRemoval:
                    return removal.delay(context)
            }
        } duration: { context in
            switch context.phase {
                case .toastInsertion:
                    return insertion.duration(context)
                case .toastRemoval:
                    return removal.duration(context)
            }
        } animationProperties: { context in
            switch context.phase {
                case .toastInsertion:
                    return insertion.animationProperties(context)
                case .toastRemoval:
                    return removal.animationProperties(context)
            }
        }
    }
    
    // MARK: Common Toast Transitions
    
    /// Returns an empty transition that does not animate the toast.
    public static var identity: ToastTransition {
        ToastTransition(
            id: "identity",
            duration: 0,
            animationProperties: {_ in [] }
        )
    }
    
    /// Returns a `ToastTransition` that animates the opacity of a toast.
    public static var opacity: ToastTransition {
        ToastTransition(id: "opacity") { context in
            if !context.isReduceTransparencyEnabled {
                OpacityProperty(
                    fromValue: context.phase == .toastInsertion ? 0 : 1,
                    toValue: context.phase == .toastInsertion ? 1 : 0
                )
            }
        }
    }
    
    /// Returns a `ToastTransition` that animates the position of a toast relative to the given edge.
    /// - Parameter edge: The edge to use when animating the transition of a toast.
    public static func move(
        edge: Edge
    ) -> ToastTransition {
        let makeTranslation: @Sendable (Context) -> TransformProperty.Value = { context in
            var translation = CGSize.zero
            
            switch edge {
                case .top:
                    translation.height = -context.geometry.height
                case .leading:
                    translation.width = -(context.geometry.minX + context.geometry.width)
                case .bottom:
                    translation.height = context.geometry.height
                case .trailing:
                    translation.width = context.geometry.minX + context.geometry.width
            }
            
            if context.platformUsesFlippedCoordinateSystem {
                translation.height *= -1
            }
            
            return [.translate(x: translation.width, y: translation.height, z: 0)]
        }
        
        return ToastTransition(id: "move(edge:\(edge))") { context in
            if !context.isReduceMotionEnabled {
                TransformProperty(
                    fromValue: context.phase == .toastInsertion ? makeTranslation(context) : [],
                    toValue: context.phase == .toastInsertion ? [] : makeTranslation(context)
                )
            }
        }
    }
    
    /// Returns a `ToastTransition` that animates the scale of a toast.
    public static var scale: ToastTransition {
        ToastTransition.scale(scale: 0)
    }
    
    /// Returns a`ToastTransition` that animates the scale of a toast relative to the given scale value.
    /// - Parameter scale: The scale to use when animating the transition of a toast.
    public static func scale(scale: CGFloat) -> ToastTransition {
        ToastTransition(id: "scale(scale:\(scale))") { context in
            TransformProperty(
                fromValue: context.phase == .toastInsertion
                ? [.scale(x: scale, y: scale, z: 1)]
                : [],
                toValue: context.phase == .toastInsertion
                ? []
                : [.scale(x: scale, y: scale, z: 1)]
            )
        }
    }
    
    /// Returns a `ToastTransition` that animates the rotation of a toast by the given angle in the given axis.
    /// - Parameters:
    ///   - angle: The angle of rotation to use when animating the transition of a toast.
    ///   - axes: The axes which will be rotated by the given angle.
    public static func rotate(
        angle: Angle,
        axes: TransformProperty.RotationAxis
    ) -> ToastTransition {
        return ToastTransition(id: "rotate(angle:\(angle),axes:\(axes)") { context in
            if !context.isReduceMotionEnabled {
                TransformProperty(
                    fromValue: context.phase == .toastInsertion
                    ? [.rotate(angle: angle, axes: axes)]
                    : [],
                    toValue: context.phase == .toastInsertion
                    ? []
                    : [.rotate(angle: angle, axes: axes)]
                )
            }
        }
    }
    
    /// Returns the default transition used to animate the insertion and removal of a toast.
    public static var defaultTransition: ToastTransition {
#if os(visionOS)
        _headsetTransition
#else
        _platformAwareTransition
#endif
    }
    
    private static var _platformAwareTransition: ToastTransition {
        ToastTransition(id: "defaultTransition") { context in
            moveTransition(for: context.toastAlignment)?
                .animationProperties(context) ?? []
        }
        .combined(with: .opacity)
#if os(macOS)
        .duration(0.35)
#else
        .duration(0.5)
#endif
    }
    
    private static var _headsetTransition: ToastTransition {
        ToastTransition(id: "defaultTransition") { context in
            ToastTransition.scale.animationProperties(context)
        }
        .combined(with: .opacity)
    }
}

// MARK: Helpers

private func moveTransition(
    for alignment: ToastAlignment
) -> ToastTransition? {
    let stickyEdges = alignment.rawValue
    
    if stickyEdges.isEmpty || stickyEdges == .all {
        return nil
    }
    
    if let significandEdge = stickyEdges.significandEdge {
        return .move(edge: significandEdge)
    }
    
    if let perpendicularIntersectingEdge = stickyEdges.perpendicularInterectingEdge(in: .horizontal) {
        return .move(edge: perpendicularIntersectingEdge)
    }
    
    return nil
}

private extension Edge {
    
    var edgeAxis: Axis {
        switch self {
        case .top, .bottom:
            return .vertical
        case .leading, .trailing:
            return .horizontal
        }
    }
    
    var complimentary: Edge {
        switch self {
        case .leading:
            return .trailing
        case .top:
            return .bottom
        case .trailing:
            return .leading
        case .bottom:
            return .top
        }
    }
    
    var orthogonal: Edge.Set {
        switch self {
        case .top, .bottom:
            return .horizontal
        case .leading, .trailing:
            return .vertical
        }
    }
    
    var orthogonalEdges: Swift.Set<Edge> {
        switch self {
        case .top, .bottom:
            return [.leading, .trailing]
        case .leading, .trailing:
            return [.top, .bottom]
        }
    }
}

private extension Edge.Set {
    
    var significandEdge: Edge? {
        let significandEdges = Edge.allCases
            .filter { // An edge E is significand in a set S, IFF S contains E, not it's complimentary, and both or neither it's orthogonal edges.
                contains($0) && !contains($0.complimentary) && (isDisjoint(with: $0.orthogonal) || contains($0.orthogonal))
            }
        
        if significandEdges.count == 1 {
            return significandEdges[0]
        }
        
        return nil
    }
    
    func perpendicularInterectingEdge(
        in axis: Axis
    ) -> Edge? {
        let perpendicularInterectingEdges = Edge.allCases
            .filter { // !complimentary && only one orthogonal
                !contains($0.complimentary) && containsOnlyOne(of: $0.orthogonalEdges)
            }
            .filter({ $0.edgeAxis == axis })
        
        if perpendicularInterectingEdges.count == 1 {
            return perpendicularInterectingEdges[0]
        }
        
        return nil
    }
    
    func contains(_ member: Edge) -> Bool {
        switch member {
        case .top:
            return contains(Edge.Set.top)
        case .leading:
            return contains(Edge.Set.leading)
        case .bottom:
            return contains(Edge.Set.bottom)
        case .trailing:
            return contains(Edge.Set.trailing)
        }
    }
    
    func containsOnlyOne<S: Sequence>(
        of collection: S
    ) -> Bool
    where S.Element == Edge {
        return collection.filter({ contains($0) }).count == 1
    }
}

private func _combinedHash<One: Hashable, Other: Hashable>(
    of one: One,
    and other: Other
) -> Int {
    var hasher = Hasher()
    hasher.combine(one)
    hasher.combine(other)
    return hasher.finalize()
}
