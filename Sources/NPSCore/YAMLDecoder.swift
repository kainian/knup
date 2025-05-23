//
//  YAMLDecoder.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/16/25.
//

import struct Foundation.URL
import struct Foundation.Data
import struct TSCBasic.AbsolutePath
import class Yams.YAMLDecoder

extension YAMLDecoder {
    
    public static func decode<T>(_ type: T.Type, from absolutePath: AbsolutePath) throws -> T where T: Decodable {
//        guard localFileSystem.exists(path) else {
//            throw Error.yaml(.notExists(path))
//        }
//        guard localFileSystem.isFile(path) else {
//            throw Error.yaml(.noSuchFile(path))
//        }
        let pathString = absolutePath.pathString
        let url = URL(fileURLWithPath: pathString)
        let data = try Data(contentsOf: url)
        do {
            return try YAMLDecoder().decode(type, from: data)
        } catch {
            throw Error.yaml(.decode(absolutePath, error))
        }
    }
}
