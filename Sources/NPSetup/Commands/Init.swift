//
//  Init.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/28/25.
//

import ArgumentParser

extension Command {
    
    struct Init: ParsableCommand {
        
        static let configuration: CommandConfiguration = .init(
            abstract: "Generate a simple .npup/Settings.yml, placed in the current directory."
        )
        
        func run() throws {
            
        }
    }
}
