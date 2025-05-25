//
//  YAMLEncoder.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/25/25.
//

import struct Foundation.URL
import struct Foundation.Data
import struct TSCBasic.AbsolutePath
import struct TSCBasic.ByteString
import class Yams.YAMLEncoder

extension YAMLEncoder {
    
    public static func encode<T: Swift.Encodable>(_ value: T, userInfo: [CodingUserInfoKey: Any] = [:]) throws -> String {
        try YAMLEncoder().encode(value, userInfo: userInfo)
    }
    
    public static func write<T: Swift.Encodable>(_ value: T, userInfo: [CodingUserInfoKey: Any] = [:], to absolutePath: AbsolutePath) throws {
        let fileSystem = Sandbox.shared.fileSystem
        let dirname = absolutePath.parentDirectory
        try fileSystem.createDirectory(dirname, recursive: true)
        let bytes = ByteString(encodingAsUTF8: try encode(value, userInfo: userInfo))
        try fileSystem.writeFileContents(absolutePath, bytes: bytes, atomically: true)
    }
}
