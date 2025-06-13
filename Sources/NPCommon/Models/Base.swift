//
//  Base.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 6/1/25.
//

extension Model {
    
    public struct Environment: Codable, Sendable {
        public let key: String
        public let value: String?
    }
    
    public struct Prepare: Codable, Sendable {
        public let plugin: String
        public let name: String
        public let version: String?
    }
    
    public struct Command: Codable, Sendable {
        public let name: String
        public let path: String?
        public let description: String?
        public let prepare: [Prepare]?
    }
    
    public struct Script: Codable, Sendable {
        public let name: String?
        public let content: String?
        public let prepare: [Prepare]?
    }
    
    public struct Dependency: Codable, Sendable {
        public let name: String
        public let version: String
        public init(_ name: String, _ version: String) {
            self.name = name
            self.version = version
        }
    }
    
    public struct Gem: Codable, Sendable {
        public let name: String
        public let version: String?
        public let source: String?
        public let path: String?
    }
    
    public struct Gemfile: Codable, Sendable {
        public let source: [String]?
        public let gems: [Gem]?
    }
    
    public struct Plugin: Codable, Sendable {
        public enum PluginType: String, Codable, Sendable {
            case caskroom, cellar, gems
        }
        public let name: String
        public let version: String
        public let type: PluginType
        public let multiVersionEnabled: Bool?
        public let abstract: String?
        public let rubygems: Gemfile?
        public let doctors: [Script]?
        public let bootstraps: [Script]?
        public let provisions: [Script]?
        public let commands: [Command]?
        public let dependencies: [Dependency]?
    }
    
    public struct Settings: Codable, Sendable {
        public let script: Script?
        public let plugins: [Dependency]?
    }
    
    public struct Lock: Codable, Sendable {
        public let plugins: [Dependency]
        public let dependencies: [Dependency]
        public let sha256: String
        public init(plugins: [Dependency], dependencies: [Dependency], sha256: String) {
            self.plugins = plugins
            self.dependencies = dependencies
            self.sha256 = sha256
        }
    }
}

extension Model.Prepare: Hashable {
    
    public static func == (lhs: Model.Prepare, rhs: Model.Prepare) -> Bool {
        lhs.plugin == rhs.plugin &&
        lhs.name == rhs.name &&
        lhs.version == rhs.version
    }
}

extension Model.Script: Hashable {
    
    public static func == (lhs: Model.Script, rhs: Model.Script) -> Bool {
        lhs.name == rhs.name &&
        lhs.content == rhs.content &&
        lhs.prepare == rhs.prepare
    }
}

