//
//  Error.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/17/25.
//

import struct TSCBasic.AbsolutePath

public enum Error: Swift.Error {
    
    case yaml(Yaml)
    
    case dependency(Dependency)
    
    case process(Process)
}

extension Error {
    
    public enum Yaml: Sendable {
        case decode(String, Swift.Error)
    }
    
    public enum Dependency: Sendable {
        case circular([PluginYml])
        case conflict([String: [[PluginYml]]])
    }
    
    public enum Process: Sendable {
        case terminated(Int32)
        case signalled(Int32)
    }
}

extension Error: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .dependency(let dependency):
            return dependency.description
        case .yaml(let yaml):
            return yaml.description
        case .process(let process):
            return process.description
        }
    }
}

extension Error.Dependency: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .circular(let path):
            return """
                
                🛑 circular dependency detected, dependency chain: 
                \(path.map(\.key).joined(separator: " -> "))                  
                └─ 🌀 cycle origin: \(path.last?.key ?? "")
                """
        case .conflict(let paths):
            return paths.map { path in
                let head = "🛑 conflicting versions: \(path.value.map(\.last!.key).joined(separator: " vs "))"
                var index = 0
                let body = path.value.map {
                    defer {
                        index += 1
                    }
                    return """
                    ⚠️ requirement chain #\(index):
                       \($0.map(\.key).joined(separator: " -> "))
                       └── 🧩 required version: \($0.last!.key)
                    """
                }.joined(separator: "\n")
                return """
                \(head)
                \(body)
                """
            }.joined(separator: "\n")
        }
    }
}

extension Error.Yaml: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .decode(let string, let error):
            return """
                \(string)
                \(error)
                """
        }
    }
}

extension Error.Process: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .terminated(let code):
            return "terminated(\(code))"
        case .signalled(let signal):
            return "signalled(\(signal))"
        }
    }
}
