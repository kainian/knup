//
//  main.swift
//  KainianSetup
//
//  Created by Jonathan Lee on 5/27/25.
//

import KNCommon
import struct Foundation.Data
import class Yams.YAMLDecoder
import struct TSCBasic.AbsolutePath

func main(_ arguments: [String] = CommandLine.arguments) throws {
    var arguments = arguments
    arguments.removeFirst()
    guard !arguments.isEmpty else {
        // help
        return
    }
    
    let box = try setup()
    let name = arguments.removeFirst()
    let program = try findExecutable(name, box)
    
    if let path = box?.profile {
        arguments.insert("/usr/bin/env", at: 0)
        arguments.insert("NEXT_SETTINGS_PROFILE_PATH=\(path)", at: 1)
        arguments.insert(program.pathString, at: 2)
    } else {
        arguments.insert("/bin/bash", at: 0)
        arguments.insert(program.pathString, at: 1)
    }
    try Subprocess.exec(arguments: arguments)
}

func setup() throws -> Sandbox.SettingsPathBox? {
    let sandbox = Sandbox.shared
    guard let box = try? sandbox.pathBox else {
        return nil
    }
    
    let fileSystem = sandbox.fileSystem
    guard fileSystem.isFile(box.path) else {
        return nil
    }
    
    let installer = Installer(sandbox: sandbox)
    if !fileSystem.isFile(box.lock) {
        try installer.install(box: box)
    } else if case .none = try? box.lockfile() {
        try installer.install(box: box)
    } else {
        try installer.check(box: box)
    }
    return box
}

func findExecutable(_ program: String, _ box: Sandbox.SettingsPathBox?) throws -> AbsolutePath {
    let sandbox = Sandbox.shared
    let fileSystem = sandbox.fileSystem
    if let abs = box?.dir.appending(components: ["bin", program]),
        fileSystem.isFile(abs) {
        return abs
    }
    
    let additional = sandbox.additional(nil)
    for type in try fileSystem.getDirectoryContents(additional) {
        let dirname = additional.appending(component: type)
        if !fileSystem.isDirectory(dirname) {
            continue
        }
        for name in try fileSystem.getDirectoryContents(dirname) {
            let dirname = dirname.appending(components: [name, "bin"])
            if !fileSystem.isDirectory(dirname) {
                continue
            }
            for name in try fileSystem.getDirectoryContents(dirname) {
                if name == program || name == "-\(program)" {
                    let abs = dirname.appending(component: name)
                    if fileSystem.isExecutableFile(abs) {
                        return abs
                    }
                }
            }
        }
    }
    throw Error.findExecutable(program)
}

do {
    try main()
} catch {
    print(error)
}

