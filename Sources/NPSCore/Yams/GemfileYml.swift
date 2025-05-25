//
//  GemfileYml.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/23/25.
//

public struct GemfileYml: Codable, Sendable {
    
    public struct Gem: Codable, Sendable {
        let name: String
        let version: String?
        let source: String?
        let path: String?
    }
    
    public let source: [String]?
    public let gems: [Gem]?
}

extension GemfileYml: CustomStringConvertible {
    
    public var description: String {
        var description: [String] = []
        if let source = source, !source.isEmpty {
            description.append(contentsOf: source.map({ "source '\($0)'" }))
        }
        if let gems = gems, !gems.isEmpty {
            let items = gems.map { gem in
                var string = "gem '\(gem.name)'"
                if let path = gem.path {
                    string = "\(string), :path => '\(path)'"
                } else {
                    if let version = gem.version {
                        string = "\(string), '\(version)'"
                    }
                    if let source = gem.source {
                        string = "\(string), :source => '\(source)'"
                    }
                }
                return string
            }
            description.append(contentsOf: items)
        }
        return description.joined(separator: "\n")
    }
}

extension GemfileYml: Hashable {
    
}

extension GemfileYml.Gem: Hashable {
    
}
