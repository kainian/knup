//
//  PluginYml.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/16/25.
//

import struct TSCBasic.RelativePath
import class Yams.YAMLDecoder

public struct PluginYml: Codable, Sendable {
    
    public struct Gem: Codable, Sendable {
        let name: String
        let version: String?
        let source: String?
        let path: String?
    }
    
    public struct Dependency: Codable, Sendable {
        public let name: String
        public let version: String
        public init(_ name: String, _ version: String) {
            self.name = name
            self.version = version
        }
    }
    
    public struct Prepare: Codable, Sendable {
        public let plugin: String
        public let name: String
        public let version: String?
    }
    
    public struct Script: Codable, Sendable {
        public let name: String?
        public let script: String?
        public let prepare: [Prepare]?
    }
    
    public let name: String
    public let version: String
    public let multiVersionEnabled: Bool?
    public let abstract: String?
    public let doctors: [Script]?
    public let bootstraps: [Script]?
    public let provisions: [Script]?
    public let gems: [Gem]?
    public let dependencies: [Dependency]?
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
    public var rubygems: Bool {
        if let gems = gems, !gems.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    public var gemfile: String? {
        guard let gems = gems, !gems.isEmpty else {
            return nil
        }
        return gems.map { gem in
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
        }.joined(separator: "\n")
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

extension PluginYml.Prepare: Hashable {
    
    public static func == (lhs: PluginYml.Prepare, rhs: PluginYml.Prepare) -> Bool {
        lhs.plugin == rhs.plugin &&
        lhs.name == rhs.name &&
        lhs.version == rhs.version
    }
}

extension PluginYml.Script: Hashable {
    
    public static func == (lhs: PluginYml.Script, rhs: PluginYml.Script) -> Bool {
        lhs.name == rhs.name &&
        lhs.script == rhs.script &&
        lhs.prepare == rhs.prepare
    }
}

extension Sandbox {
    
    private func relativePath(_ dependency: PluginYml.Dependency) throws -> RelativePath {
        try RelativePath(validating: "utils/plugins/\(dependency.name)/\(dependency.version)/Plugin.yml")
    }
    
    public func plugin(dependency: PluginYml.Dependency) throws -> PluginYml {
        let relativePath = try relativePath(dependency)
        let absolutePath = bundle.appending(relativePath)
        return try YAMLDecoder.decode(PluginYml.self, from: absolutePath)
    }
}
