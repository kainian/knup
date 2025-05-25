//
//  ScriptYml.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/23/25.
//

public struct ScriptYml: Codable, Sendable {
    public struct Prepare: Codable, Sendable {
        public let plugin: String
        public let name: String
        public let version: String?
    }
    public let name: String?
    public let script: String?
    public let prepare: [Prepare]?
}

extension ScriptYml: Hashable {
    
    public static func == (lhs: ScriptYml, rhs: ScriptYml) -> Bool {
        lhs.name == rhs.name &&
        lhs.script == rhs.script &&
        lhs.prepare == rhs.prepare
    }
}

extension ScriptYml.Prepare: Hashable {
    
    public static func == (lhs: ScriptYml.Prepare, rhs: ScriptYml.Prepare) -> Bool {
        lhs.plugin == rhs.plugin &&
        lhs.name == rhs.name &&
        lhs.version == rhs.version
    }
}

