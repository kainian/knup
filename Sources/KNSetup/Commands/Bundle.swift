//
//  Bundle.swift
//  KainianSetup
//
//  Created by Jonathan Lee on 5/23/25.
//

import KNCommon
import ArgumentParser
import class Yams.YAMLDecoder
import class Yams.YAMLEncoder

extension Command {
    
    struct Bundle: ParsableCommand {
        
        static let configuration: CommandConfiguration = .init(
            abstract: "Install and upgrade (by default) all dependencies from the Settings.yml.",
            subcommands: [
                Info.self,
                List.self,
            ]
        )
        
        @Flag(name: .shortAndLong, help: "Include extra information in the output.")
        var verbose = false
        
        @Flag(help: "Reinstall direct dependencies declared in Settings.yml.")
        var reinstallDirect = false
        
        @Flag(help: "Reinstall all dependencies (including transitive dependencies).")
        var reinstallAll = false
        
        func run() throws {
            let sandbox = Sandbox.shared
            let box = try sandbox.pathBox
            let mode = Installer.ReinstallMode(reinstallDirect, reinstallAll)
            let installer = Installer(sandbox: .shared, mode: mode)
            try installer.install(box: box)
        }
    }
}
