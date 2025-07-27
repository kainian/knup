//
//  Gemfile+Additional.swift
//  KainianSetup
//
//  Created by Jonathan Lee on 6/1/25.
//

extension Model.Gemfile: CustomStringConvertible {
    
    public var description: String {
        var description: [String] = []
        if let source = source, !source.isEmpty {
            description.append(contentsOf: source.map({ "source '\($0)'" }))
        }
        if let gems = gems, !gems.isEmpty {
            let items = gems.map { gem in
                var string = "gem '\(gem.name)'"
                if let path = gem.path {
                    string = "\(string), :path => '\(path)'"
                } else {
                    if let version = gem.version {
                        string = "\(string), '\(version)'"
                    }
                    if let source = gem.source {
                        string = "\(string), :source => '\(source)'"
                    }
                }
                return string
            }
            description.append(contentsOf: items)
        }
        return description.joined(separator: "\n")
    }
}
