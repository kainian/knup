//
//  PluginYml.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/16/25.
//

import struct TSCBasic.RelativePath
import class Yams.YAMLDecoder

public struct PluginYml: Codable {
    public struct Dependency: Codable {
        public let name: String
        public let version: String
        public init(_ name: String, _ version: String) {
            self.name = name
            self.version = version
        }
    }
    public struct Script: Codable {
        public let script: String?
    }
    public let name: String
    public let version: String
    public let abstract: String?
    public let dependencies: [Dependency]?
    public let install: Script?
    public let `init`: Script?
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
