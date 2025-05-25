//
//  Bundle.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/23/25.
//

import ArgumentParser
import NPSInstaller
import NPSCore
import class Yams.YAMLDecoder

extension Command {
    
    struct Bundle: ParsableCommand {
        
        static let configuration: CommandConfiguration = .init(
            abstract: "Install and upgrade (by default) all dependencies from the Settings.yml."
        )
        
        @Flag(name: .shortAndLong, help: "Include extra information in the output.")
        var verbose = false
        
        func run() throws {
            let sandbox = Sandbox.shared
            guard let settingsPath = sandbox.settingsPath else {
                return
            }
            let installer = Installer()
            try installer.append(try YAMLDecoder.decode(SettingsYml.self, from: settingsPath))
            try installer.install(verbose: verbose)
        }
    }
}
