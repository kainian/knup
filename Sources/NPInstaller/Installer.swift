//
//  Installer.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/16/25.
//

import NPSandbox
import class TSCBasic.Process
import class TSCBasic.DiagnosticsEngine

public final class Installer {
    
    public let sandbox: Sandbox
    
    public var dependencies: [PluginYml.Dependency]
    
    public var plugins: [String: PluginYml]
    
    public init() {
        sandbox = .shared
        dependencies = []
        plugins = [:]
    }
}

extension Installer {

    public func install(name: String, version: String) throws {
        let dependency = PluginYml.Dependency(name, version)
        dependencies.append(dependency)
        try install(dependency: dependency)
    }
    
    private func install(dependency: PluginYml.Dependency) throws {
        let plugin = try sandbox.plugin(dependency: dependency)
        if case .some(let value) = plugins[plugin.name] {
            if value.version != plugin.version {
                fatalError("conflict")
            } else {
                return
            }
        }
        
        if let dependencies = plugin.dependencies {
            for dependency in dependencies {
                try install(dependency: dependency)
            }
        }
        
//        diagnosticEngine.emit(.note("plugin: \(plugin.name) (\(plugin.version))"))
        
        if let abstract = plugin.abstract {
            print(abstract)
        }
        
        guard !sandbox.installed(dependency) else {
            print("Installed \(plugin.name) (\(plugin.version))")
            return
        }
        
        if let install = plugin.install {
            if let script = install.script {
                let workingDirectory = sandbox.bundle;
                let scriptRoot = workingDirectory.appending(component: "utils")
                let content = """
                    #!/bin/bash
                    NONINTERACTIVE=1
                    source "\(scriptRoot.appending(component: "setup"))"
                    source "\(scriptRoot.appending(component: "package"))"
                    \(script)
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
}
