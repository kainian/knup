//
//  Update.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 6/14/25.
//

import NPCommon
import ArgumentParser

extension Command {
    
    struct Update: ParsableCommand {
        
        static let configuration: CommandConfiguration = .init(
            abstract: "Fetch the newest version of NPUP and all formulae from GitHub using git."
        )
        
        func run() throws {
            let installer = Installer(sandbox: .shared)
            try installer.update()
        }
    }
}
