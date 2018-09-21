//
//  Layer.swift
//  Graph
//
//  Created by Fraser King on 2018-09-11.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class Layer: NSObject {
    var name: String!
    var active: Bool!
    var colors: [UIColor]!
    var levelPath: String!
    var animatedImagePath: String!
    var idleImagePath: String!
    var gameLevels: [Level]!
    
    init(name: String, active: Bool, colors: [String], levelPath: String, animatedImagePath: String, idleImagePath: String, gameLevels: [Level]) {
        self.name = name
        self.active = active
        
        var colorList: [UIColor] = []
        for color in colors {
            colorList.append(UIColor.hexStringToUIColor(hex: color))
        }
        self.colors = colorList
        
        self.levelPath = levelPath
        self.animatedImagePath = animatedImagePath
        self.idleImagePath = idleImagePath
        self.gameLevels = gameLevels
    }
    
    func createLevel(index: Int) -> Level? {
        guard let levels = self.gameLevels else {
            return nil
        }

        if index >= 0 && index < levels.count {
            return levels[index]
        }
        return nil
    }
    
    func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
        let length = Int64(range.upperBound - range.lowerBound + 1)
        let value = Int64(arc4random()) % length + Int64(range.lowerBound)
        return T(value)
    }

    // TODO: Improve this generation and abstract to other graph types
    func getRandomLevel() -> Level {
        let adjacencyList = AdjacencyList<Node>()
        let numberOfVertices = randomNumber(inRange: 4...8)
        let numberOfEdges = randomNumber(inRange: (numberOfVertices + 1)...(numberOfVertices + 5))
        var vertices: [Vertex<Node>] = []

        var count = 0
        for _ in 0...numberOfVertices {
            let randomX = Float(randomNumber(inRange: -5...5))
            let randomY = Float(randomNumber(inRange: -7...7))
            let randomZ = Float(randomNumber(inRange: -5...5))

            let vertex = adjacencyList.createVertex(data: Node(position: SCNVector3(x: randomX, y: randomY, z: randomZ), uid: count, color: .white, mirrorUID: nil))
            vertices.append(vertex)
            count += 1
        }

        for index in 0...numberOfEdges {
            let edgeStart = index % (numberOfVertices + 1)
            var edgeEnd = randomNumber(inRange: 0...vertices.count-1)
            while (edgeStart == edgeEnd) {
                edgeEnd = randomNumber(inRange: 0...vertices.count-1)
            }
            adjacencyList.add(.undirected, from: vertices[edgeStart], to: vertices[edgeEnd])
        }

        return Level(name: "random", numberOfColorsProvided: 3, graphType: GraphType.kColor, timed: false, isMirror: false, targetColor: nil, adjacencyList: adjacencyList)
    }
}
