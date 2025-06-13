//
//  main.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/27/25.
//

import NPCommon
import struct Foundation.Data
import class Yams.YAMLDecoder
import struct TSCBasic.AbsolutePath

func main(_ arguments: [String] = CommandLine.arguments) throws {
    var arguments = arguments
    if let program = try program(&arguments) {
        arguments.insert("/bin/bash", at: 0)
        arguments.insert(program.pathString, at: 1)
        try Subprocess.exec(arguments: arguments)
    } else {
        // help
    }
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
    
    if !fileSystem.isFile(box.lock) {
        let installer = Installer(sandbox: sandbox)
        try installer.install(box: box)
    }
    
    if case .none = try? box.lockfile() {
        let installer = Installer(sandbox: sandbox)
        try installer.install(box: box)
    }
    
    let lock = try box.lockfile()
    let sha256 = try box.sha256
    if lock.sha256 != sha256 {
        let installer = Installer(sandbox: sandbox)
        try installer.install(box: box)
    }
    return box
}

func program(_ arguments: inout [String]) throws -> AbsolutePath? {
    arguments.removeFirst()
    if let program = arguments.first {
        arguments.removeFirst()
        let box = try setup()
        return findExecutable(program, box: box)
    }
    return nil
}

/// Returns the path of the the given program if found in the search paths.
///
/// The program can be executable name, relative path or absolute path.
public func findExecutable(_ program: String, box: Sandbox.SettingsPathBox?) -> AbsolutePath? {
    if let abs = box?.dir.appending(components: ["bin", program]) {
        return abs
    }
    
    return nil
}

do {
    try main()
} catch {
    print(error)
}

