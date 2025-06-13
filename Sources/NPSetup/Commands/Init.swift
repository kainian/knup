//
//  Init.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/28/25.
//

import NPCommon
import ArgumentParser
import struct TSCBasic.AbsolutePath

extension Command {
    
    struct Init: ParsableCommand {
        
        static let configuration: CommandConfiguration = .init(
            abstract: "Generate a simple .npup/Settings.yml, placed in the current directory."
        )
        
        func run() throws {
            let fileSystem = Sandbox.shared.fileSystem
            let homeDirectory = try fileSystem.homeDirectory
            guard let abs = fileSystem.currentWorkingDirectory else {
                return
            }
            guard homeDirectory.isAncestorOfOrEqual(to: abs) else {
                return
            }
            
            let dirname = abs.appending(component: ".npup")
            try fileSystem.createDirectory(dirname)
            try writeFileContents(dirname.appending(component: ".gitignore"), .gitignore)
            try writeFileContents(dirname.appending(component: "Settings.yml"), .settings)
        }
        
        private func writeFileContents(_ path: AbsolutePath, _ string: String) throws {
            let fileSystem = Sandbox.shared.fileSystem;
            if !fileSystem.isFile(path) {
                try Sandbox.shared.fileSystem.writeFileContents(path, bytes: .init(encodingAsUTF8: string), atomically: true)
                Diagnostics.emit(.remark("Write: \(path.prettyPath())"))
            }
        }
    }
}

extension String {
    
    static let gitignore = """
    # NPUP
    bin/
    share/
    Settings.lock
    """
    
    static let settings = """
    script:
      content: |
        # nothing
      prepare:
        - plugin: cocoapods
          name: init
    plugins: 
      - name: cocoapods
        version: 1.16.2
    """
    
}
