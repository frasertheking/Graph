//
//  Graphable.swift
//  Graph
//
//  Created by Fraser King on 2017-11-11.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

protocol Graphable {
    associatedtype Element: Hashable // 1
    var description: CustomStringConvertible { get } // 2
    
    func createVertex(data: Element) -> Vertex<Element> // 3
    func add(_ type: EdgeType, from source: Vertex<Element>, to destination: Vertex<Element>) // 4
    func edges(from source: Vertex<Element>) -> [Edge<Element>]? // 6
}
