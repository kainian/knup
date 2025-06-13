//
//  File.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/23/25.
//

import ArgumentParser

@main
struct Command: ParsableCommand {
    
    static let configuration: CommandConfiguration = .init(
        commandName: "np",
        abstract: "The Plugin Manager",
        subcommands: [
            Init.self,
            Install.self,
            Bundle.self,
        ]
    )
}

