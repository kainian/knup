//
//  Installer.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/16/25.
//

import NPSCore
import enum TSCBasic.ProcessEnv
import class TSCBasic.Process
import struct TSCBasic.ByteString
import class TSCBasic.DiagnosticsEngine
import struct TSCBasic.ProcessEnvironmentKey
import Yams

public final class Installer {
    
    public let sandbox: Sandbox
    
    public let directedGraph: DirectedGraph
    
    public init() {
        sandbox = .shared
        directedGraph = .init()
    }
}

extension Installer {

    public func append(_ settings: SettingsYml) throws {
        try settings.plugins?.forEach {
            try append($0)
        }
    }
    
    public func append(_ dependency: DependencyYml) throws {
        directedGraph.append(try sandbox.plugin(dependency: dependency))
    }
    
    @discardableResult
    public func install(verbose: Bool = false) throws -> DirectedGraph.Result {
        let result = try directedGraph.resolve()
        try result.forEach { node in
            let plugin = node.plugin
            guard !sandbox.installed(plugin) else {
                if verbose {
                    print("Using", plugin.key)
                }
                return
            }
            print("Installing", plugin.key)
            
            try sandbox.clean(plugin)
            if let rubygems = plugin.rubygems {
                let directory = sandbox.directory(plugin)
                try sandbox.fileSystem.createDirectory(directory, recursive: true)
                let gemfile = sandbox.gemfile(plugin)
                let bytes = ByteString(encodingAsUTF8: rubygems.description)
                try sandbox.fileSystem.writeFileContents(gemfile, bytes: bytes, atomically: true)
            }
            try run(script: result.provision(plugin))
            try YAMLEncoder.write(plugin, to: sandbox.release(plugin))
        }
        return result
    }
}

extension Installer {
    
    private func run(script: String, environmentBlock: [ProcessEnvironmentKey: String] = ProcessEnv.block) throws {
        var environmentBlock = environmentBlock
        environmentBlock["NEXT_BUNDLE_PATH"] = sandbox.bundle.pathString
        let content = """
            #!/bin/bash
            
            set -eu
            
            NONINTERACTIVE=1
            
            source "${NEXT_BUNDLE_PATH}/utils/setup"
            source "${NEXT_BUNDLE_PATH}/utils/package"
            
            \(script)
            """
        
        print(content)
        
        let process = Process (
            arguments: ["/bin/bash", "-c", content],
            environmentBlock: environmentBlock,
            outputRedirection: .none,
            startNewProcessGroup: false
        )
        try process.launch()
        let result = try process.waitUntilExit()
        switch result.exitStatus {
        case let .terminated(code: code):
            if code != 0 {
                throw Error.process(.terminated(code))
            }
        case let .signalled(signal: signal):
            throw Error.process(.signalled(signal))
        }
    }
}
