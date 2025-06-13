//
//  Install.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/23/25.
//

import NPCommon
import ArgumentParser

extension Command {
    
    struct Install: ParsableCommand {
        
        static let configuration: CommandConfiguration = .init(
            abstract: "Install a plugin."
        )
        
        @Argument(help: "plugin name")
        var name: String
        
        @Option(name: .shortAndLong, help: "plugin version")
        var version: String
        
        @Flag(name: .shortAndLong, help: "Install without checking; force overwrite if already installed.")
        var force = false
        
        @Flag(help: "Include extra information in the output.")
        var verbose = false
        
        func run() throws {
            let installer = Installer(sandbox: .shared)
            let information = Model.Dependency(name, version)
            try installer.install(information)
        }
    }
}
