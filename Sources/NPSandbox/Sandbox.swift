//
//  Sandbox.swift
//  npup
//
//  Created by Jonathan Lee on 5/16/25.
//

import struct TSCBasic.AbsolutePath
import struct TSCBasic.RelativePath
import protocol TSCBasic.FileSystem
import var TSCBasic.localFileSystem
import enum TSCBasic.ProcessEnv

public final class Sandbox {
    
    public let home: AbsolutePath
    
    public let bundle: AbsolutePath
    
    public let fileSystem: FileSystem
    
    private init() {
        fileSystem = localFileSystem
        if let path = ProcessEnv.block[.init("NP_PREFIX")] {
            home = try! .init(validating: path)
        } else {
            home = try! .init(validating: "/opt/np")
        }
        #if DEBUG
        let relativePath = try! RelativePath(validating: "Workspace/nextpangea/npup")
        bundle = try! fileSystem.homeDirectory.appending(relativePath)
        #else
        if let path = ProcessEnv.block[.init("NP_REPOSITORY")] {
            bundle = try! .init(validating: path)
        } else {
            bundle = root.appending(component: ".npup")
        }
        #endif
    }
}

extension Sandbox {
    
    nonisolated(unsafe) public static let shared: Sandbox = .init()
    
}

extension Sandbox {
    
    public func installed(_ dependency: PluginYml.Dependency) -> Bool {
        let dirname = "\(dependency.name)@\(dependency.version)"
        if fileSystem.isDirectory(home.appending(components: ["Cellar", dirname])) {
            return true
        } else if fileSystem.isDirectory(home.appending(components: ["Caskroom", dirname])) {
            return true
        } else {
            return false
        }
    }
}

