//
//  Vertex.swift
//  Graph
//
//  Created by Fraser King on 2017-11-11.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

public struct Vertex<T: Hashable> {
    var data: T
}

extension Vertex: Hashable {
    public var hashValue: Int {
        return "\(data)".hashValue
    }
    
    static public func ==(lhs: Vertex, rhs: Vertex) -> Bool {
        return lhs.data == rhs.data
    }
}

extension Vertex: CustomStringConvertible {
    public var description: String {
        if data is Node {
            return "\((data as! Node).uid)"
        }
        return "\(data)"
    }
}
