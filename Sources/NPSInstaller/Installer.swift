//
//  Installer.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/16/25.
//

import NPSCore

import protocol TSCBasic.FileSystem
import class Yams.YAMLEncoder
import struct TSCBasic.ByteString
import struct TSCBasic.AbsolutePath
import class TSCBasic.DiagnosticsEngine
import class TSCBasic.Process
import enum TSCBasic.ProcessEnv
import struct TSCBasic.ProcessEnvironmentKey
import struct Foundation.Data

public final class Installer {
    
    public enum ReinstallMode {
        case normal, direct, all
    }
    
    public let sandbox: Sandbox
    
    /// The file system which we should interact with.
    public let fileSystem: FileSystem
    
    /// Reinstall mode
    public let mode: ReinstallMode
    
    public init(sandbox: Sandbox, mode: ReinstallMode = .normal) {
        self.mode = mode
        self.sandbox = sandbox
        self.fileSystem = sandbox.fileSystem
    }
}

extension Installer {
    
    @discardableResult
    public func install(box: Sandbox.SettingsPathBox) throws -> DirectedGraph.Result {
        let directedGraph = DirectedGraph()
        let settings = try box.settings()
        try settings.plugins?.forEach {
            directedGraph.append(try sandbox.plugin(dependency: $0))
        }
        
        let result = try install(directedGraph, to: box.dir)
        let share = box.dir.appending(component: "share")
        try fileSystem.createDirectory(share, recursive: true)
        if let script = settings.script {
            var sources = """
            #!/bin/bash

            # Strict mode: Exit immediately on errors or undefined variables
            set -eu
            
            \(result.sources(script))
            """
            if let content = script.content {
                sources += "\n\(content)"
            }
            let bytes = ByteString(encodingAsUTF8: sources)
            let profile = share.appending(component: "profile")
            try fileSystem.writeFileContents(profile, bytes: bytes, atomically: true)
            try fileSystem.chmod(.executable, path: profile)
        }
        
        try YAMLEncoder.write(result.lock(settings, try box.sha256), to: box.lock)
        
        return result
    }
    
    @discardableResult
    public func install(_ dependency: Model.Dependency, to dirname: AbsolutePath? = nil) throws -> DirectedGraph.Result {
        let directedGraph = DirectedGraph()
        directedGraph.append(try sandbox.plugin(dependency: dependency))
        return try install(directedGraph, to: dirname)
    }
    
    private func install(_ directedGraph: DirectedGraph, to dirname: AbsolutePath? = nil) throws -> DirectedGraph.Result {
        let result = try directedGraph.resolve()
        try result.forEach { node in
            let plugin = node.plugin
            let installed = sandbox.installed(plugin)
            if installed {
                switch mode {
                case .normal:
                    Diagnostics.emit(.remark("Using \(plugin.key)"))
                    return
                case .direct:
                    if directedGraph.plugins.contains(plugin) {
                        break
                    } else {
                        Diagnostics.emit(.remark("Using \(plugin.key)"))
                        return
                    }
                case .all:
                    break
                }
            }
            
            Diagnostics.emit(.remark("Installing \(plugin.key)"))
            
            try sandbox.clean(plugin)
            if let rubygems = plugin.rubygems {
                let directory = sandbox.store(plugin)
                try sandbox.fileSystem.createDirectory(directory, recursive: true)
                let gemfile = directory.appending(component: "Gemfile")
                let bytes = ByteString(encodingAsUTF8: rubygems.description)
                try sandbox.fileSystem.writeFileContents(gemfile, bytes: bytes, atomically: true)
            }
            
            try run(script: result.provision(plugin))
        }
        
        try result.forEach { node in
            let plugin = node.plugin
            let additional = sandbox.additional(plugin)
            let bin = additional.appending(component: "bin")
            try sandbox.fileSystem.removeFileTree(bin)
            
            try plugin.commands?.forEach { command in
                try run(command: command, plugin: plugin, result: result, bin: bin)
                if let bin = dirname?.appending(component: "bin") {
                    try run(command: command, plugin: plugin, result: result, bin: bin)
                }
            }
            
            try YAMLEncoder.write(plugin, to: additional.appending(component: "Plugin.yml"))
        }
        return result
    }
}

extension Installer {
    
    private func run(command: Model.Command, plugin: Model.Plugin, result: DirectedGraph.Result, bin: AbsolutePath) throws {
        let commandLine: String
        if let path = command.path {
            commandLine = """
            exec "${NEXT_PREFIX}/\(sandbox.relative(plugin))/\(path)" "$@"
            """
        } else {
            commandLine = """
            exec \(command.name) "$@"
            """
        }
        
        let content = """
        #!/bin/bash
        
        # Strict mode: Exit immediately on errors or undefined variables
        set -eu
        
        NEXT_PATH="${NEXT_PATH:-\(sandbox.bundle)}"
        if [[ "${NEXT_INITIALIZED_MODULES:-}" != *":NEXT"* ]]; then
            export NEXT_INITIALIZED_MODULES="${NEXT_INITIALIZED_MODULES:-}:NEXT"
            source "${NEXT_PATH}/utils/setup"
            source "${NEXT_PATH}/utils/package"
        fi
        
        \(result.commands(command))
        \("# Execute Main Command".uppercased())
        \(commandLine)
        """
        
        try fileSystem.createDirectory(bin, recursive: true)
        let file = bin.appending(component: command.name)
        let bytes = ByteString(encodingAsUTF8: content)
        try fileSystem.writeFileContents(file, bytes: bytes, atomically: true)
        try fileSystem.chmod(.executable, path: file)
    }
    
    private func run(script: String, environmentBlock: [ProcessEnvironmentKey: String] = ProcessEnv.block) throws {
        var environmentBlock = environmentBlock
        environmentBlock["NEXT_PATH"] = sandbox.bundle.pathString
        let content = """
            #!/bin/bash
            
            # Strict mode: Exit immediately on errors or undefined variables
            set -eu
            
            NONINTERACTIVE=1
            
            if [[ "${NEXT_INITIALIZED_MODULES:-}" != *":NEXT"* ]]; then
                export NEXT_INITIALIZED_MODULES="${NEXT_INITIALIZED_MODULES:-}:NEXT"
                source "${NEXT_PATH}/utils/setup"
                source "${NEXT_PATH}/utils/package"
            fi
            
            \(script)
            """
        
        try Subprocess.run(
            arguments: ["/bin/bash", "-c", content],
            environmentBlock: environmentBlock,
            startNewProcessGroup: false)
    }
}

extension Installer.ReinstallMode {
    
    public init(_ reinstallDirect: Bool = false, _ reinstallAll: Bool = false) {
        if reinstallAll {
            self = .all
        } else if reinstallDirect {
            self = .direct
        } else {
            self = .normal
        }
    }
}
