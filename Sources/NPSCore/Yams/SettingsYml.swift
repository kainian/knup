//
//  SettingsYml.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/23/25.
//

import Foundation

public struct SettingsYml: Codable, Sendable {
    public struct Environment: Codable, Sendable {
        public let key: String
        public let value: String?
    }
    public let env: [Environment]?
    public let script: ScriptYml?
    public let plugins: [DependencyYml]?
}
