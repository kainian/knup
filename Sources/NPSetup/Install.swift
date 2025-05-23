//
//  File.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/23/25.
//

import ArgumentParser
import NPSInstaller

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
            
    //        import NPSInstaller
    //        import ArgumentParser
    //
    //        do {
    //            let installer = Installer()
    //            try installer.append(.init("cocoapods", "1.16.2"))
    //            try installer.install()
    //        } catch {
    //            print(error)
    //        }

            //do {
            //    let installer = Installer()
            //    try installer.append(.init("ruby", "2.7.8"))
            //    try installer.install()
            //} catch {
            //    print(error)
            //}

        }
    }
}
