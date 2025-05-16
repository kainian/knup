//
//  Logger.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/17/25.
//

import class TSCBasic.DiagnosticsEngine
import struct TSCBasic.Diagnostic

import class Dispatch.DispatchQueue
import class TSCBasic.UnknownLocation
import class TSCBasic.ThreadSafeOutputByteStream
import class TSCBasic.LocalFileOutputByteStream
import var TSCLibc.stdout
import var TSCLibc.stderr

public struct Logger {
 
    public static func emit(_ message: Diagnostic.Message) {
        diagnosticEngine.emit(message)
    }
}

extension Logger {
    
    /// Diagnostic engine for emitting warnings, errors, etc.
    public nonisolated(unsafe) static let diagnosticEngine: DiagnosticsEngine = .init(handlers: [stderrDiagnosticsHandler])
    
    /// A global queue for emitting non-interrupted messages into stderr
    public static let stdErrQueue = DispatchQueue(label: "com.NextPangea.driver.emit-to-stderr")
    
    /// Handler for emitting diagnostics to stderr.
    public nonisolated(unsafe) static let stderrDiagnosticsHandler: DiagnosticsEngine.DiagnosticsHandler = { diagnostic in
        /// Public stdout stream instance.
        let stdoutStream = try! ThreadSafeOutputByteStream(
            LocalFileOutputByteStream(filePointer: TSCLibc.stdout, closeOnDeinit: false))
        /// Public stderr stream instance.
        let stderrStream = try! ThreadSafeOutputByteStream(
            LocalFileOutputByteStream(filePointer: TSCLibc.stderr, closeOnDeinit: false))
        
        stdErrQueue.sync {
            let stream = stderrStream
            if !(diagnostic.location is UnknownLocation) {
                stream.send("\(diagnostic.location.description): ")
            }
            
            switch diagnostic.message.behavior {
            case .error:
                stream.send("error: ")
            case .warning:
                stream.send("warning: ")
            case .note:
                stream.send("note: ")
            case .remark:
                stream.send("remark: ")
            case .ignored:
                break
            }
            
            stream.send("\(diagnostic.localizedDescription)\n")
            stream.flush()
        }
    }
    
}
