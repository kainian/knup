//
//  DirectedGraph.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/17/25.
//

import NPSCore

public final class DirectedGraph {
    
    public final class Node {
        
        public let plugin: PluginYml
        
        public var children: [Node] = []
        
        init(_ plugin: PluginYml) {
            self.plugin = plugin
        }
    }
    
    public struct Result {
        
        public let nodeByKey: [String: Node]
        
        public let dependencies: Set<Node>
        
        public let plugins: Set<PluginYml>
        
        public let bootstraps: [String: [String: ScriptYml]]
        
        init(_ nodeByKey: [String : Node], _ dependencies: Set<Node>) {
            self.nodeByKey = nodeByKey
            self.dependencies = dependencies
            self.plugins = Set(nodeByKey.values.map(\.plugin))
            self.bootstraps = Set(self.plugins).reduce(into: [String: [String: ScriptYml]]()) { partialResult, plugin in
                let key = plugin.key
                let name = plugin.name
                if let bootstraps = plugin.bootstraps {
                    partialResult[key] = bootstraps.reduce(into: [String: ScriptYml]()) { partialResult, script in
                        if let name = script.name {
                            partialResult[name] = script
                        }
                    }
                    partialResult[name] = partialResult[key]
                }
            }
        }
    }
    
    public private(set) var plugins: Set<PluginYml>
    
    public init() {
        plugins = []
    }
}

extension DirectedGraph.Node: Hashable {
    
    public static func == (lhs: DirectedGraph.Node, rhs: DirectedGraph.Node) -> Bool {
        lhs.plugin.key == rhs.plugin.key
    }
    
    public func hash(into hasher: inout Hasher) {
        plugin.key.hash(into: &hasher)
    }
    
    public var hashValue: Int {
        plugin.key.hashValue
    }
}

extension DirectedGraph {
    
    public func append(_ element: PluginYml) {
        plugins.insert(element)
    }
    
    public func resolve() throws -> Result {
        var nodeByKey = [String: Node]()
        let nodes = Set(plugins.map(Node.init))
        for node in nodes {
            try expansion(node, &nodeByKey)
        }
        if let path = hasCycle(nodes) {
            throw Error.dependency(.circular(path))
        }
        if let path = hasConflict(nodes, nodeByKey) {
            throw Error.dependency(.conflict(path))
        }
        return .init(nodeByKey, nodes)
    }
}

extension DirectedGraph {
    
    private func hasCycle(_ nodes: Set<Node>) -> [PluginYml]? {
        
        func dfs(_ node: Node, _ path: [PluginYml] = []) -> [PluginYml]? {
            let newPath = path + [node.plugin]
            guard !Set(path).contains(node.plugin) else {
                return newPath
            }
            let path = path + [node.plugin]
            for child in node.children {
                if let path = dfs(child, path) {
                    return path
                }
            }
            return nil
        }
        
        for node in nodes {
            if let path = dfs(node) {
                return path
            }
        }
        
        return nil
    }
    
    private func hasConflict(_ nodes: Set<Node>, _ nodeByKey: [String: Node]) -> [String: [[PluginYml]]]? {
        
        func find(_ node: Node, name: String, _ path: [PluginYml] = [], handle: ([PluginYml]) -> Void) {
            let path = path + [node.plugin]
            if name == node.plugin.name {
                handle(path)
            } else {
                for child in node.children {
                    find(child, name: name, path, handle: handle)
                }
            }
        }
        
        let names = nodeByKey.values.reduce(into: [String: [Node]]()) { partialResult, node in
            let name = node.plugin.name
            if let items = partialResult[name] {
                partialResult[name] = items + [node]
            } else {
                partialResult[name] = [node]
            }
        }.filter { items in
            items.value.count > 1
        }.map(\.value.first)
            .compactMap(\.?.plugin.name)
        
        var result: [String: [[PluginYml]]] = .init()
        for name in names {
            var paths: [[PluginYml]] = .init()
            for node in nodes {
                find(node, name: name) { path in
                    paths.append(path)
                }
            }
            if !paths.isEmpty, case .some = paths.map(\.last).first(where: \.!.multiVersionDisable) {
                result[name] = paths
            }
        }
        if !result.isEmpty {
            return result
        } else {
            return nil
        }
    }
    
    private func expansion(_ node: Node, _ nodeByKey: inout [String: Node]) throws {
        let key = node.plugin.key
        guard case .none = nodeByKey[key] else {
            return
        }
        nodeByKey[key] = node
        for element in try node.plugin.children {
            let child = nodeByKey[element.key] ?? .init(element)
            node.children.append(child)
            try expansion(child, &nodeByKey)
        }
    }
}

extension DirectedGraph.Result {
    
    public func forEach(_ body: (DirectedGraph.Node) throws -> Void) rethrows {
        var degreeByKey = nodeByKey.reduce(into: [String: Int]()) { partialResult, items in
            partialResult[items.key] = items.value.children.count
        }
        
        let parentByKey = nodeByKey.values.reduce(into: [String: Set<String>]()) { partialResult, items in
            for child in items.children {
                var arr = partialResult[child.plugin.key] ?? []
                arr.insert(items.plugin.key)
                partialResult[child.plugin.key] = arr
            }
        }
        
        while true {
            guard !degreeByKey.isEmpty else {
                break
            }
            try degreeByKey.filter {
                $0.value == 0
            }.forEach { (key, value) in
                degreeByKey[key] = nil
                parentByKey[key]?.forEach { key in
                    degreeByKey[key]! -= 1
                }
                if let node = nodeByKey[key] {
                    try body(node)
                }
            }
        }
    }
    
    public func first(where predicate: (DirectedGraph.Node) throws -> Bool) rethrows -> DirectedGraph.Node? {
        return try Set(nodeByKey.values).first(where: predicate)
    }
    
    public func provision(_ plugin: PluginYml) -> String {
        
        func recursion(key: String, _ script: ScriptYml, _ initialized: inout Set<ScriptYml>, _ contents: inout [String]) {
            
            if initialized.contains(script) {
                return
            } else {
                initialized.insert(script)
            }
            
            script.prepare?.forEach {
                let key: String
                if let version = $0.version {
                    key = "\($0.plugin)@\(version)"
                } else {
                    key = $0.plugin
                }
                if let script = bootstraps[key]?[$0.name] {
                    recursion(key: key, script, &initialized, &contents)
                }
            }
            
            contents.append("# prepare \(key)")
            if let name = script.name {
                contents.append("# \(name)")
            }
            if let script = script.script {
                contents.append(script)
            }
        }
        
        guard let provisions = plugin.provisions else {
            return "# nothing"
        }
        
        var initialized = Set<ScriptYml>()
        var contents: [String] = .init()
        for provision in provisions {
            recursion(key: plugin.name, provision, &initialized, &contents)
        }
        
        return contents.joined(separator: "\n")
    }
}
