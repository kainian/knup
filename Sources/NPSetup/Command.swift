//
//  File.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/23/25.
//

import ArgumentParser

struct Command: ParsableCommand {
    
    static let configuration: CommandConfiguration = .init(
        abstract: "The Plugin Manager",
        subcommands: [
            Install.self
        ]
    )
}
