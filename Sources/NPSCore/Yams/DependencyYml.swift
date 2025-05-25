//
//  Dependency.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/23/25.
//

public struct DependencyYml: Codable, Sendable {
    public let name: String
    public let version: String
    public init(_ name: String, _ version: String) {
        self.name = name
        self.version = version
    }
}
