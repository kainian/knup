//
//  Subprocess.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 6/1/25.
//

import NPSCore
import func TSCBasic.exec
import class TSCBasic.Process
import enum TSCBasic.ProcessEnv
import struct TSCBasic.ProcessEnvironmentKey
public typealias ProcessEnvironmentBlock = [ProcessEnvironmentKey:String]

public enum Subprocess {
    
    public static func run(arguments: [String], environmentBlock: ProcessEnvironmentBlock = ProcessEnv.block, startNewProcessGroup: Bool = true) throws {
        let process = Process (
            arguments: arguments,
            environmentBlock: environmentBlock,
            outputRedirection: .none,
            startNewProcessGroup: false)
        try process.launch()
        let result = try process.waitUntilExit()
        switch result.exitStatus {
        case let .terminated(code: code):
            if code != 0 {
                throw Error.process(.terminated(code))
            }
        case let .signalled(signal: signal):
            throw Error.process(.signalled(signal))
        }
    }
    
    public static func exec(arguments: [String]) throws -> Never {
        try TSCBasic.exec(path: arguments[0], args: arguments)
    }
}
