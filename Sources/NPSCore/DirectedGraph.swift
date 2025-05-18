//
//  DirectedGraph.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/17/25.
//

public protocol NodeHashable: Hashable, Sendable {
    
    var key: String { get }
    
    var name: String { get }
    
    var multiVersionEnabled: Bool? { get }
    
    var children: [Self] { get throws }
}

extension NodeHashable {
    
    var multiVersionDisable: Bool {
        if let multiVersionEnabled = multiVersionEnabled {
            return !multiVersionEnabled
        } else {
            return true
        }
    }
}

public final class DirectedGraph<Element: NodeHashable> {
    
    public final class Node {
        
        public let element: Element
        
        public var children: [Node] = []
        
        init(_ element: Element) {
            self.element = element
        }
    }
    
    public struct Result {
        
        public let dependencies: [Node]
        
    }
    
    public private(set) var elements: Set<Element>
    
    public init() {
        elements = []
    }
}

extension DirectedGraph.Node: Hashable {
    
    public static func == (lhs: DirectedGraph<Element>.Node, rhs: DirectedGraph<Element>.Node) -> Bool {
        lhs.element.key == rhs.element.key
    }
    
    public func hash(into hasher: inout Hasher) {
        element.key.hash(into: &hasher)
    }
    
    public var hashValue: Int {
        element.key.hashValue
    }
}

extension DirectedGraph {
    
    public func append(_ element: Element) {
        elements.insert(element)
    }
    
    public func resolve() throws -> Result {
        let nodes = elements.map(Node.init)
        var nodeByKey = [String: Node]()
        for node in nodes {
            try expansion(node, &nodeByKey)
        }
        
        if let path = hasCycle(nodes) {
            throw Error.dependency(.circular(path))
        }
        
        if let path = hasConflict(nodes, nodeByKey) {
            throw Error.dependency(.conflict(path))
        }
        
        return .init(dependencies: nodes)
    }
}

extension DirectedGraph {
    
    private func hasCycle(_ nodes: [Node]) -> [Element]? {
        
        func dfs(_ node: Node, _ path: [Element] = []) -> [Element]? {
            let newPath = path + [node.element]
            guard !Set(path).contains(node.element) else {
                return newPath
            }
            let path = path + [node.element]
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
    
    private func hasConflict(_ nodes: [Node], _ nodeByKey: [String: Node]) -> [String: [[Element]]]? {
        
        func find(_ node: Node, name: String, _ path: [Element] = [], handle: ([Element]) -> Void) {
            let path = path + [node.element]
            if name == node.element.name {
                handle(path)
            } else {
                for child in node.children {
                    find(child, name: name, path, handle: handle)
                }
            }
        }
        
        let names = nodeByKey.values.reduce(into: [String: [Node]]()) { partialResult, node in
            let name = node.element.name
            if let items = partialResult[name] {
                partialResult[name] = items + [node]
            } else {
                partialResult[name] = [node]
            }
        }.filter { items in
            items.value.count > 1
        }.map(\.value.first)
            .compactMap(\.?.element.name)
        
        var result: [String: [[Element]]] = .init()
        for name in names {
            var paths: [[Element]] = .init()
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
        let key = node.element.key
        guard case .none = nodeByKey[key] else {
            return
        }
        nodeByKey[key] = node
        for element in try node.element.children {
            let child = nodeByKey[element.key] ?? .init(element)
            node.children.append(child)
            try expansion(child, &nodeByKey)
        }
    }
}

