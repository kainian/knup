//
//  PluginYml.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/16/25.
//

import struct TSCBasic.RelativePath
import class Yams.YAMLDecoder

public struct PluginYml: Codable, Sendable {
    public enum PluginType: String, Codable, Sendable {
        case caskroom, cellar, gems
    }
    public let name: String
    public let version: String
    public let type: PluginType
    public let multiVersionEnabled: Bool?
    public let abstract: String?
    public let rubygems: GemfileYml?
    public let doctors: [ScriptYml]?
    public let bootstraps: [ScriptYml]?
    public let provisions: [ScriptYml]?
    public let dependencies: [DependencyYml]?
}

extension PluginYml {
    
    public var key: String {
        "\(name)@\(version)"
    }
    
    public var children: [PluginYml] {
        get throws {
            let sandbox = Sandbox.shared
            return try dependencies?.map {
                try sandbox.plugin(dependency: $0)
            } ?? []
        }
    }
    
    public var multiVersionDisable: Bool {
        if let multiVersionEnabled = multiVersionEnabled {
            return !multiVersionEnabled
        } else {
            return true
        }
    }
    
}

extension PluginYml: Hashable {
    
    public static func == (lhs: PluginYml, rhs: PluginYml) -> Bool {
        lhs.name == rhs.name && lhs.version == rhs.version
    }
    
    public func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
        version.hash(into: &hasher)
    }
}

extension Sandbox {
    
    private func relativePath(_ dependency: DependencyYml) throws -> RelativePath {
        try RelativePath(validating: "utils/plugins/\(dependency.name)/\(dependency.version)/Plugin.yml")
    }
    
    public func plugin(dependency: DependencyYml) throws -> PluginYml {
        let relativePath = try relativePath(dependency)
        let absolutePath = bundle.appending(relativePath)
        return try YAMLDecoder.decode(PluginYml.self, from: absolutePath)
    }
}
