//
//  LabelContent.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 13/7/26.
//

import SwiftUI

public struct LabelContent: ExpressibleByStringLiteral, Sendable {
    fileprivate let text: Text
    
    public init(_ text: Text) {
        self.text = text
    }
    
    public init(stringLiteral value: String) {
        self.text = Text(LocalizedStringKey(value))
    }
    
    @_disfavoredOverload
    public init<S: StringProtocol>(_ string: S) {
        self.text = Text(string)
    }
    
    public init(verbatim string: String) {
        self.text = Text(verbatim: string)
    }
    
    public init(
        _ localizedStringKey: LocalizedStringKey,
        tableName: String? = nil,
        bundle: Bundle? = nil,
        comment: StaticString? = nil
    ) {
        self.text = Text(localizedStringKey, tableName: tableName, bundle: bundle, comment: comment)
    }
    
    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    public init(_ localizedStringResource: LocalizedStringResource) {
        self.text = Text(localizedStringResource)
    }
}

public extension Text {
    
    init(_ content: LabelContent) {
        self = content.text
    }
}
