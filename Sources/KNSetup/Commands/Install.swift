//
//  Install.swift
//  KainianSetup
//
//  Created by Jonathan Lee on 5/23/25.
//

import KNCommon
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
        
        @Flag(help: "Reinstall direct dependencies declared in Settings.yml.")
        var reinstallDirect = false
        
        @Flag(help: "Reinstall all dependencies (including transitive dependencies).")
        var reinstallAll = false
        
        @Flag(help: "Include extra information in the output.")
        var verbose = false
        
        func run() throws {
            let mode = Installer.ReinstallMode(reinstallDirect, reinstallAll)
            let installer = Installer(sandbox: .shared, mode: mode)
            let information = Model.Dependency(name, version)
            try installer.install(information)
        }
    }
}
