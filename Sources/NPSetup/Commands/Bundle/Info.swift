//
//  Info.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 6/13/25.
//

import NPCommon
import ArgumentParser

extension Command {
    
    struct Info: ParsableCommand {
        
        static let configuration: CommandConfiguration = .init(
            abstract: "Print more detailed information about a gem."
        )
        
        @Argument(help: "plugin name")
        var name: String
        
        func run() throws {
            let sandbox = Sandbox.shared
            let box = try sandbox.pathBox
            let lock = try box.lockfile()
            guard let dependency = lock.plugins.first(where: { $0.name == name }) else {
                throw ValidationError("Could not find plugin '\(name)'")
            }
            
            let plugin = try sandbox.plugin(dependency: dependency)
            Diagnostics.emit(.note("* \(plugin.name) (\(plugin.version)):"))
            if let abstract = plugin.abstract {
                Diagnostics.emit(.note(abstract))
            }
        }
    }
}
