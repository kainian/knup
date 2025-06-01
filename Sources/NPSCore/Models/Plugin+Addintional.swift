//
//  Plugin+Addintional.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 6/1/25.
//

import class Yams.YAMLDecoder
import struct TSCBasic.RelativePath

extension Model.Plugin {
    
    public var key: String {
        "\(name)@\(version)"
    }
    
    public var children: [Model.Plugin] {
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

extension Model.Plugin: Hashable {
    
    public static func == (lhs: Model.Plugin, rhs: Model.Plugin) -> Bool {
        lhs.name == rhs.name && lhs.version == rhs.version
    }
    
    public func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
        version.hash(into: &hasher)
    }
}

extension Sandbox {
    
    private func relativePath(_ dependency: Model.Dependency) throws -> RelativePath {
        try RelativePath(validating: "utils/plugins/\(dependency.name)/\(dependency.version)/Plugin.yml")
    }
    
    public func plugin(dependency: Model.Dependency) throws -> Model.Plugin {
        let relativePath = try relativePath(dependency)
        let absolutePath = bundle.appending(relativePath)
        return try YAMLDecoder.decode(Model.Plugin.self, from: absolutePath)
    }
}
