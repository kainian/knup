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
        return installed(.init(plugin.name, plugin.version), plugin.rubygems)
    }
    
    public func installed(_ dependency: PluginYml.Dependency, _ rubygems: Bool = false) -> Bool {
        if rubygems {
            return fileSystem.isFile(gemfilelockPath(dependency))
        } else {
            if fileSystem.isDirectory(cellarPath(dependency)) {
                return true
            } else if fileSystem.isDirectory(caskroomPath(dependency)) {
                return true
            } else {
                return false
            }
        }
    }
}

extension Sandbox {
    
    public static let shared: Sandbox = .init()
    
    public func dirname(_ plugin: PluginYml) -> String {
        return dirname(.init(plugin.name, plugin.version))
    }
    
    public func dirname(_ dependency: PluginYml.Dependency) -> String {
        return "\(dependency.name)@\(dependency.version)"
    }
    
    public func cellarPath(_ plugin: PluginYml) -> AbsolutePath {
        return cellarPath(.init(plugin.name, plugin.version))
    }
    
    public func cellarPath(_ dependency: PluginYml.Dependency) -> AbsolutePath {
        return home.appending(components: ["Cellar", dirname(dependency)])
    }
    
    public func caskroomPath(_ plugin: PluginYml) -> AbsolutePath {
        return cellarPath(.init(plugin.name, plugin.version))
    }
    
    public func caskroomPath(_ dependency: PluginYml.Dependency) -> AbsolutePath {
        return home.appending(components: ["Caskroom", dirname(dependency)])
    }
    
    public func gemsPath(_ plugin: PluginYml) -> AbsolutePath {
        return gemsPath(.init(plugin.name, plugin.version))
    }
    
    public func gemsPath(_ dependency: PluginYml.Dependency) -> AbsolutePath {
        return home.appending(components: ["Gems", dirname(dependency)])
    }
    
    public func gemfilePath(_ plugin: PluginYml) -> AbsolutePath {
        gemfilePath(.init(plugin.name, plugin.version))
    }
    
    public func gemfilePath(_ dependency: PluginYml.Dependency) -> AbsolutePath {
        return gemsPath(dependency).appending(component: "Gemfile")
    }
    
    public func gemfilelockPath(_ plugin: PluginYml) -> AbsolutePath {
        gemfilelockPath(.init(plugin.name, plugin.version))
    }
    
    public func gemfilelockPath(_ dependency: PluginYml.Dependency) -> AbsolutePath {
        return gemsPath(dependency).appending(component: "Gemfile.lock")
    }
}
