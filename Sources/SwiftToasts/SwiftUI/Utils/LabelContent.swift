//
//  LabelContent.swift
//  SwiftToasts
//
//  Created by Sakis Kefalas on 13/7/26.
//

import SwiftUI

public struct LabelContent: ExpressibleByStringLiteral, Sendable {
    internal let text: Text
    internal let string: String
    
    public init(_ text: Text) {
        self.text = text
        self.string = ""
    }
    
    public init(stringLiteral value: String) {
        self.text = Text(LocalizedStringKey(value))
        self.string = value
    }
    
    @_disfavoredOverload
    public init<S: StringProtocol>(_ string: S) {
        self.text = Text(string)
        self.string = String(string)
    }
    
    public init(verbatim string: String) {
        self.text = Text(verbatim: string)
        self.string = string
    }
    
    public init(
        _ localizedStringKey: LocalizedStringKey,
        tableName: String? = nil,
        bundle: Bundle? = nil,
        comment: StaticString? = nil
    ) {
        self.text = Text(localizedStringKey, tableName: tableName, bundle: bundle, comment: comment)
        self.string = localizedStringKey.opened.evaluate(
            tableName: tableName,
            bundle: bundle,
            comment: comment
        )
    }
    
    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    public init(_ localizedStringResource: LocalizedStringResource) {
        self.text = Text(localizedStringResource)
        self.string = NSLocalizedString(
            localizedStringResource.key,
            tableName: localizedStringResource.table,
            bundle: localizedStringResource.bundle.describedBundle ?? .main,
            comment: ""
        )
    }
}

public extension Text {
    
    init(_ content: LabelContent) {
        self = content.text
    }
}

private extension LocalizedStringKey {
    struct OpenLocalizedStringKey {
        enum FormatArgument {
            case value(CVarArg, Formatter?)
            
            var asCVarArg: CVarArg {
                switch self {
                case .value(let value, let formatter):
                    guard let formatter else {
                        return value
                    }
                    
                    return formatter.string(for: value) ?? ""
                }
            }
        }
        
        let key: String
        let hasFormatting: Bool
        let arguments: [FormatArgument]
        
        init(inspecting key: LocalizedStringKey) {
            let mirror = Mirror(reflecting: key)
            self.key = mirror.child(named: "key") { value in
                value as? String
            } ?? ""
            
            self.hasFormatting = mirror.child(named: "hasFormatting") { value in
                value as? Bool
            } ?? false
            
            self.arguments = mirror.childArray(named: "arguments") { (element) -> FormatArgument? in
                let mirror = Mirror(reflecting: element)
                guard let erasedValue = mirror.children.first?.value else {
                    return nil
                }
                
                let valueCaseMirror = Mirror(reflecting: erasedValue)
                guard let erasedCaseValue = valueCaseMirror.children.first?.value else {
                    return nil
                }
                
                if let unboxedCaseValue = erasedCaseValue as? (CVarArg, Formatter?) {
                    return .value(unboxedCaseValue.0, unboxedCaseValue.1)
                } else {
                    let valueCaseValueMirror = Mirror(reflecting: erasedCaseValue)
                    var index: Int = 0
                    var tupleFirst: CVarArg?
                    var tupleSecond: Formatter?
                    for child in valueCaseValueMirror.children {
                        if index == 0 {
                            tupleFirst = child.value as? CVarArg
                        } else if index == 1 {
                            tupleSecond = child.value as? Formatter
                        } else {
                            break
                        }
                        
                        index += 1
                    }
                    
                    guard let tupleFirst else {
                        return nil
                    }
                    
                    return .value(tupleFirst, tupleSecond)
                }
            }
        }
        
        func evaluate(
            tableName: String? = nil,
            bundle: Bundle? = nil,
            comment: StaticString? = nil
        ) -> String {
            let localizedString = NSLocalizedString(
                key,
                tableName: tableName,
                bundle: bundle ?? .main,
                comment: comment.flatMap({ "\($0)" }) ?? ""
            )
            
            guard hasFormatting, !arguments.isEmpty else {
                return localizedString
            }
            
            let formattedString =  String(
                format: localizedString,
                arguments: arguments.map({ $0.asCVarArg })
            )
            
            return formattedString
        }
    }
    
    var opened: OpenLocalizedStringKey {
        OpenLocalizedStringKey(inspecting: self)
    }
}

private extension Mirror {
    
    func child<Value>(
        named name: String,
        transform: (Any) -> Value?
    ) -> Value? {
        let matchingValue = children
            .filter({ $0.label == name || $0.label == "_\(name)" })
            .first?
            .value
        
        guard let matchingValue else { return nil }
        return transform(matchingValue)
    }
    
    func childArray<Value>(
        named name: String,
        transform: (Any) -> Value?
    ) -> [Value] {
        let matchingValue = children
            .filter({ $0.label == name || $0.label == "_\(name)" })
            .first?
            .value
        
        guard let matchingValue = matchingValue as? [Any] else { return [] }
        return matchingValue.compactMap(transform)
    }
}

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
private extension LocalizedStringResource.BundleDescription {
    
    var describedBundle: Bundle? {
        switch self {
        case .main:
            return .main
        case .forClass(let anyClass):
            return .init(for: anyClass)
        case .atURL(let url):
            return .init(url: url)
        @unknown default:
            return nil
        }
    }
}
