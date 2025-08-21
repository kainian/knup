//
//  Plugin+Addintional.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 6/1/25.
//

import class Yams.YAMLDecoder
import struct TSCBasic.RelativePath
import struct TSCBasic.AbsolutePath

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
    
    @discardableResult
    public func localPlugin(dependency: Model.Dependency, pathBox: SettingsPathBox) throws -> Model.Plugin? {
        func resolvingPath(validating pathString: String) throws -> AbsolutePath {
            if let abs = try? AbsolutePath(validating: pathString) {
                return abs
            } else {
                let rela = try RelativePath(validating: pathString)
                return pathBox.dir.appending(rela)
            }
        }
        guard let path = dependency.path else {
            return nil
        }
        let absolutePath = try resolvingPath(validating: path)
        let plugin = try YAMLDecoder.decode(Model.Plugin.self, from: absolutePath)
        
        let key = "\(plugin.name)@\(plugin.version)"
        decodedPlugins[key] = plugin
        return plugin
    }
    
    public func plugin(dependency: Model.Dependency) throws -> Model.Plugin {
        func relativePath(_ dependency: Model.Dependency) throws -> RelativePath {
            try RelativePath(validating: "utils/plugins/\(dependency.name)/\(dependency.version)/Plugin.yml")
        }
        let key = "\(dependency.name)@\(dependency.version)"
        if let plugin = decodedPlugins[key] {
            return plugin
        } else {
            let relativePath = try relativePath(dependency)
            let absolutePath = bundle.appending(relativePath)
            let plugin =  try YAMLDecoder.decode(Model.Plugin.self, from: absolutePath)
            decodedPlugins[key] = plugin
            return plugin
        }
    }
}
