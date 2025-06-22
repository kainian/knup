//
//  Sandbox.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/16/25.
//

import var TSCBasic.localFileSystem
import protocol TSCBasic.FileSystem
import enum TSCBasic.ProcessEnv
import struct TSCBasic.AbsolutePath
import struct TSCBasic.RelativePath
import class Yams.YAMLDecoder
import struct Foundation.Data

public final class Sandbox: Sendable {
    
    /// The root directory for storing application resources and user data.
    public let home: AbsolutePath
    
    /// The directory containing module installation metadata and bundle manifests.
    public let bundle: AbsolutePath
    
    /// The file system which we should interact with.
    public let fileSystem: FileSystem
    
    /// Stores successfully decoded plugin models ready for runtime use.
    nonisolated(unsafe)
    public var decodedPlugins: [String: Model.Plugin]
    
    private init() {
        decodedPlugins = [:]
        fileSystem = localFileSystem
        if let path = ProcessEnv.block[.init("NEXT_PREFIX")] {
            home = try! .init(validating: path)
        } else {
            home = try! .init(validating: "/opt/np")
        }
        #if DEBUG
        let relativePath = try! RelativePath(validating: "Workspace/nextpangea/npup")
        bundle = try! fileSystem.homeDirectory.appending(relativePath)
        #else
        if let path = ProcessEnv.block[.init("NEXT_REPOSITORY")] {
            bundle = try! .init(validating: path)
        } else {
            bundle = home.appending(component: ".npup")
        }
        #endif
    }
}

extension Sandbox {
    
    public func installed(_ plugin: Model.Plugin) -> Bool {
        switch plugin.type {
        case .cellar:
            return fileSystem.isDirectory(store(plugin)) &&
                fileSystem.isFile(additional(plugin).appending(component: "Plugin.yml"))
        case .caskroom:
            return fileSystem.isDirectory(store(plugin)) &&
                fileSystem.isFile(additional(plugin).appending(component: "Plugin.yml"))
        case .gems:
            return fileSystem.isDirectory(store(plugin)) &&
                fileSystem.isFile(additional(plugin).appending(component: "Plugin.yml")) &&
                fileSystem.isFile(store(plugin).appending(component: "Gemfile")) &&
                fileSystem.isFile(store(plugin).appending(component: "Gemfile.lock"))
        }
    }
    
    public func clean(_ plugin: Model.Plugin) throws {
        try fileSystem.removeFileTree(store(plugin))
        try fileSystem.removeFileTree(additional(plugin))
    }
}

extension Sandbox {
    
    private func dirname(_ plugin: Model.Plugin) -> String {
        return "\(plugin.name)@\(plugin.version)"
    }
    
    public func relative(_ plugin: Model.Plugin) -> RelativePath {
        switch plugin.type {
        case .caskroom:
            return try! RelativePath(validating: "Caskroom/\(dirname(plugin))")
        case .cellar:
            return try! RelativePath(validating: "Cellar/\(dirname(plugin))")
        case .gems:
            return try! RelativePath(validating: "Gems/\(dirname(plugin))")
        }
    }
    
    public func store(_ plugin: Model.Plugin) -> AbsolutePath {
        home.appending(relative(plugin))
    }
    
    public func additional(_ plugin: Model.Plugin?) -> AbsolutePath {
        if let plugin = plugin {
            return home.appending(components: ["share", "plugins"]).appending(relative(plugin))
        } else {
            return home.appending(components: ["share", "plugins"])
        }
    }
}

extension Sandbox {
    
    public var pathBox: SettingsPathBox {
        get throws {
            .init(settingsPath: try findSettingsPath())
        }
    }
    
    private func findSettingsPath() throws -> AbsolutePath {
        if let pathString = ProcessEnv.block[.init("NEXT_SETTINGS_PATH")],
            let file = absolutePath(validating: pathString) {
            if fileSystem.isFile(file) {
                return file
            }
        }
        var absolutePath = fileSystem.currentWorkingDirectory
        let relativePath = try! RelativePath(validating: ".npup/Settings.yml")
        while let path = absolutePath, path != path.parentDirectory {
            let file = path.appending(relativePath)
            if fileSystem.isFile(file) {
                return file
            }
            absolutePath = path.parentDirectory
        }
        
        throw Error.couldNotSettings
    }
    
    public func absolutePath(validating pathString: String, ) -> AbsolutePath? {
        // The path representation does not properly handle paths on all
        // platforms.  On Windows, we often see an empty key which we would
        // like to treat as being the relative path to cwd.
        if let absolute = try? AbsolutePath(validating: pathString) {
            return absolute
        } else if let relative = try? RelativePath(validating: pathString) {
            return fileSystem.currentWorkingDirectory?.appending(relative)
        } else {
            return nil
        }
    }
}

extension Sandbox.SettingsPathBox {
    
    public func settings() throws -> Model.Settings {
        try YAMLDecoder.decode(Model.Settings.self, from: path)
    }
    
    public func lockfile() throws -> Model.Lock {
        try YAMLDecoder.decode(Model.Lock.self, from: lock)
    }
    
    public var sha256: String {
        get throws {
            try Data(contentsOf: .init(fileURLWithPath: path.pathString)).sha256
        }
    }
}


extension Sandbox {
    
    public static let shared = Sandbox()
    
    public struct SettingsPathBox {
        public let path: AbsolutePath
        public let lock: AbsolutePath
        public let dir: AbsolutePath
        public init(settingsPath: AbsolutePath) {
            path = settingsPath
            dir = path.parentDirectory
            lock = dir.appending(component: "Settings.lock")
        }
        public init(lockPath: AbsolutePath) {
            lock = lockPath
            dir = lock.parentDirectory
            path = dir.appending(component: "Settings.yml")
            
        }
        public init(directory: AbsolutePath) {
            dir = directory
            path = directory.appending(component: "Settings.yml")
            lock = directory.appending(component: "Settings.lock")
        }
    }
}

extension Sandbox.SettingsPathBox {
    
    public var share: AbsolutePath {
        dir.appending(component: "share")
    }
    
    public var profile: AbsolutePath {
        share.appending(component: "profile")
    }
}
