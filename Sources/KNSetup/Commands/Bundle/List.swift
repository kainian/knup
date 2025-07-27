//
//  List.swift
//  KainianSetup
//
//  Created by Jonathan Lee on 5/28/25.
//

import KNCommon
import ArgumentParser

extension Command {
    
    struct List: ParsableCommand {
        
        static let configuration: CommandConfiguration = .init(
            abstract: "List all the plugins in the Settings.yml."
        )
        
        func run() throws {
            let sandbox = Sandbox.shared
            let box = try sandbox.pathBox
            let lock = try box.lockfile()
            Diagnostics.emit(.note("Plugins included by the bundle:"))
            lock.plugins
                .sorted {
                    $0.name < $1.name
                }.forEach {
                    Diagnostics.emit(.note("  * \($0.name) (\($0.version))"))
                }
        }
    }
}
