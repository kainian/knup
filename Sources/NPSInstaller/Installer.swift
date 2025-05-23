//
//  Installer.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/16/25.
//

import NPSCore
import class TSCBasic.Process
import class TSCBasic.DiagnosticsEngine

public final class Installer {
    
    public let sandbox: Sandbox
    
    public let directedGraph: DirectedGraph
    
    public init() {
        sandbox = .shared
        directedGraph = .init()
    }
}

extension Installer {

    public func append(_ dependency: PluginYml.Dependency) throws {
        directedGraph.append(try sandbox.plugin(dependency: dependency))
    }
    
    public func install(_ force: Bool = false) throws {
        let result = try directedGraph.resolve()
        try result.forEach { node in
            let plugin = node.plugin
            if plugin.rubygems {
                let file = sandbox.gemfilePath(plugin)
                let lockfile = sandbox.gemfilelockPath(plugin)
                if sandbox.fileSystem.isFile(file) && sandbox.fileSystem.isFile(lockfile) {
                    return
                }
                guard let gemfile = plugin.gemfile else {
                    return
                }
                let path = sandbox.gemsPath(plugin)
                try sandbox.fileSystem.createDirectory(path, recursive: true)
                try gemfile.write(toFile: file.pathString, atomically: true, encoding: .utf8)
            } else {
                if sandbox.installed(plugin) {
                    return
                }
            }
            
            let workingDirectory = sandbox.bundle;
            let scriptRoot = workingDirectory.appending(component: "utils")
            let content = """
                #!/bin/bash
                
                set -eu
                
                NONINTERACTIVE=1
                
                source "\(scriptRoot.appending(component: "setup"))"
                source "\(scriptRoot.appending(component: "package"))"
                
                \(result.provision(plugin))
                """
            
            print(content)
            
            let process = Process (
                arguments: ["/bin/bash", "-c", content],
                workingDirectory: workingDirectory,
                outputRedirection: .none,
                startNewProcessGroup: false
            )
            try process.launch()
            let result = try process.waitUntilExit()
            switch result.exitStatus {
            case let .terminated(code: code):
                if code != 0 {
                    fatalError("nonZeroExit: \(code)")
                }
            case let .signalled(signal: signal):
                fatalError("signalExit: \(signal)")
            }
            print(result)
        }
    }
}

