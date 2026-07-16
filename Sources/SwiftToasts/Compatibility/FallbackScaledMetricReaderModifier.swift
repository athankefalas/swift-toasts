//
//  FallbackScaledMetricReaderModifier.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 15/7/26.
//

import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct ScaledMetricReaderModifier: ViewModifier {
    @ScaledMetric
    private var scaledMetric: CGFloat
    
    private let reader: (CGFloat) -> ()
    
    init(
        metric: CGFloat,
        relativeTextStyle: Font.TextStyle,
        reader: @escaping (CGFloat) -> ()
    ) {
        self.reader = reader
        self._scaledMetric = ScaledMetric(wrappedValue: metric, relativeTo: relativeTextStyle)
    }
    
    func body(content: Content) -> some View {
        content.onChange(of: scaledMetric) { newValue in
            reader(newValue)
        }
        .onAppear {
            reader(scaledMetric)
        }
    }
}

struct FallbackScaledMetricReaderModifier: ViewModifier {
    
    struct HeightPreferenceKey: PreferenceKey {
        static let defaultValue: CGFloat? = nil
        
        static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
            value = value ?? nextValue()
        }
    }
    
    private let metric: CGFloat
    private let relativeTextStyle: Font.TextStyle
    private let reader: (CGFloat) -> ()
    
    @State
    private var normalSize: CGFloat?
    
    @State
    private var scaledSize: CGFloat?
    
    init(
        metric: CGFloat,
        relativeTextStyle: Font.TextStyle,
        reader: @escaping (CGFloat) -> ()
    ) {
        self.metric = metric
        self.relativeTextStyle = relativeTextStyle
        self.reader = reader
    }
    
    func body(content: Content) -> some View {
        content.background(textSizeReadingView)
    }
    
    private var textSizeReadingView: some View {
        ZStack {
            Color.clear
            
            Text("[]")
                .font(.system(relativeTextStyle))
                .opacity(0)
                .environment(\.sizeCategory, .large)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(
                                key: HeightPreferenceKey.self,
                                value: round(proxy.size.height)
                            )
                    }
                )
                .onPreferenceChange(HeightPreferenceKey.self) { newValue in
                    guard let newValue else { return }
                    updateNormalSize(to: newValue)
                }
                .layoutPriority(-1)
            
            Text("[]")
                .font(.system(relativeTextStyle))
                .opacity(0)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(
                                key: HeightPreferenceKey.self,
                                value: round(proxy.size.height)
                            )
                    }
                )
                .onPreferenceChange(HeightPreferenceKey.self) { newValue in
                    guard let newValue else { return }
                    updateScaledSize(to: newValue)
                }
                .layoutPriority(-1)

        }
    }
    
    private func updateNormalSize(to newValue: CGFloat) {
        self.normalSize = newValue
        updateMetric()
    }
    
    private func updateScaledSize(to newValue: CGFloat) {
        self.scaledSize = newValue
        updateMetric()
    }
    
    private func updateMetric() {
        let metric = metric
        guard let normalSize,
              let scaledSize,
              normalSize > 0,
              scaledSize > 0
        else {
            reader(metric)
            return
        }
        
        let scaleFactor = scaledSize / normalSize
        reader(metric * scaleFactor)
    }
}

extension View {
    
    @ViewBuilder
    func fallbackScaledMetric(
        _ metric: CGFloat,
        relativeTo textStyle: Font.TextStyle,
        assingedTo binding: Binding<CGFloat>
    ) -> some View {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            modifier(
                ScaledMetricReaderModifier(
                    metric: metric,
                    relativeTextStyle: textStyle,
                    reader: { newValue in
                        guard binding.wrappedValue != newValue else { return }
                        binding.wrappedValue = newValue
                    }
                )
            )
        } else {
            modifier(
                FallbackScaledMetricReaderModifier(
                    metric: metric,
                    relativeTextStyle: textStyle,
                    reader: { newValue in
                        guard binding.wrappedValue != newValue else { return }
                        binding.wrappedValue = newValue
                    }
                )
            )
        }
    }
}
