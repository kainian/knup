//
//  YAMLDecoder.swift
//  npup
//
//  Created by Jonathan Lee on 5/16/25.
//

import struct Foundation.URL
import struct Foundation.Data
import struct TSCBasic.AbsolutePath
import class Yams.YAMLDecoder

extension YAMLDecoder {
    
    public static func decode<T>(_ type: T.Type, from path: AbsolutePath) throws -> T where T: Decodable {
//        guard localFileSystem.exists(path) else {
//            throw Error.yaml(.notExists(path))
//        }
//        guard localFileSystem.isFile(path) else {
//            throw Error.yaml(.noSuchFile(path))
//        }
        let path = path.pathString
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        return try YAMLDecoder().decode(type, from: data)
    }
}
