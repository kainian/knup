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

public final class Sandbox: Sendable {
    
    public let home: AbsolutePath
    
    public let bundle: AbsolutePath
    
    /// The file system which we should interact with.
    public let fileSystem: FileSystem
    
    private init() {
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
    
    public func installed(_ plugin: PluginYml) -> Bool {
        switch plugin.type {
        case .cellar:
            return fileSystem.isDirectory(directory(plugin)) &&
                fileSystem.isFile(release(plugin))
        case .caskroom:
            return fileSystem.isDirectory(directory(plugin)) &&
                fileSystem.isFile(release(plugin))
        case .gems:
            return fileSystem.isDirectory(directory(plugin)) &&
                fileSystem.isFile(gemfile(plugin)) &&
                fileSystem.isFile(gemlock(plugin)) &&
                fileSystem.isFile(release(plugin))
        }
    }
    
    public func clean(_ plugin: PluginYml) throws {
        try fileSystem.removeFileTree(directory(plugin))
        try fileSystem.removeFileTree(release(plugin))
    }
}

extension Sandbox {
    
    public static let shared: Sandbox = .init()
    
    fileprivate func absolutePath(validating pathString: String) -> AbsolutePath? {
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

extension Sandbox {
    
    private func dirname(_ plugin: PluginYml) -> String {
        return "\(plugin.name)@\(plugin.version)"
    }
    
    public func directory(_ plugin: PluginYml) -> AbsolutePath {
        switch plugin.type {
        case .caskroom:
            return home.appending(components: ["Caskroom", dirname(plugin)])
        case .cellar:
            return home.appending(components: ["Cellar", dirname(plugin)])
        case .gems:
            return home.appending(components: ["Gems", dirname(plugin)])
        }
    }
    
    public func release(_ plugin: PluginYml) -> AbsolutePath {
        switch plugin.type {
        case .caskroom:
            return home.appending(components: ["share", "plugins", "Caskroom", "\(dirname(plugin)).yml"])
        case .cellar:
            return home.appending(components: ["share", "plugins", "Cellar", "\(dirname(plugin)).yml"])
        case .gems:
            return home.appending(components: ["share", "plugins", "Gems", "\(dirname(plugin)).yml"])
        }
    }
        
    public func gemfile(_ plugin: PluginYml) -> AbsolutePath {
        return directory(plugin).appending(component: "Gemfile")
    }
    
    public func gemlock(_ plugin: PluginYml) -> AbsolutePath {
        return directory(plugin).appending(component: "Gemfile.lock")
    }
}

extension Sandbox {
    
    public var settingsPath: AbsolutePath? {
        get {
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
            return nil
        }
    }
}
