//
//  GraphGenerator.swift
//  Graph
//
//  Created by Fraser King on 2017-11-11.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

class Node: Hashable {
    
    var position: SCNVector3
    var uid: Int
    var color: UIColor
    
    public var hashValue: Int {
        return uid
    }
    
    static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    public init(position: SCNVector3, uid: Int, color: UIColor) {
        self.position = position
        self.uid = uid
        self.color = color
    }
}


class GraphGenerator {
    
    static func createGraph(index: Int, scnScene: SCNScene, random: Bool) -> Level {
        
        let levels = Levels.sharedInstance
        
        var level = levels.playable[index]
        
        if random {
            level = levels.getRandomLevel()
        }
        
        // Solve checker @safety fix unwraps here
        GraphGenerator.checkIfSolved(graph: level.adjacencyList!)
        
        for (key, value) in (level.adjacencyList?.adjacencyDict)! {
            spawnShape(type: .Sphere, position: key.data.position, color: key.data.color, id: key.data.uid, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0), scnScene: scnScene)
            
            for edge in value {
                let node = SCNNode()
                scnScene.rootNode.addChildNode(node.buildLineInTwoPointsWithRotation(from: edge.source.data.position, to: edge.destination.data.position, radius: 0.1, color: .white))
            }
        }
        
        return level
    }
    
    static func spawnShape(type: ShapeType, position: SCNVector3, color: UIColor, id: Int, rotation: SCNVector4, scnScene: SCNScene) {
        var geometry:SCNGeometry
        
        switch type {
        case .Box:
            geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        case .Sphere:
            geometry = SCNSphere(radius: 0.5)
        case .Pyramid:
            geometry = SCNPyramid(width: 1.0, height: 1.0, length: 1.0)
        case .Torus:
            geometry = SCNTorus(ringRadius: 0.5, pipeRadius: 0.25)
        case .Capsule:
            geometry = SCNCapsule(capRadius: 0.3, height: 2.5)
        case .Cylinder:
            geometry = SCNCylinder(radius: 0.1, height: 3.1)
        case .Cone:
            geometry = SCNCone(topRadius: 0.25, bottomRadius: 0.5, height: 1.0)
        case .Tube:
            geometry = SCNTube(innerRadius: 0.25, outerRadius: 0.5, height: 1.0)
        }
        
        geometry.materials.first?.diffuse.contents = color
        
        if type == .Sphere {
            geometry.name = "\(id)"
        } 
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.rotation = rotation
        geometryNode.position = position
        scnScene.rootNode.addChildNode(geometryNode)
    }
    
    static func checkIfSolved(graph: AdjacencyList<Node>) -> Bool {
        var solved:Bool = true
        for (_, value) in (graph.adjacencyDict) {
            for edge in value {
                if edge.source.data.color == edge.destination.data.color {
                    solved = false
                }
            }
        }
        return solved
    }
    
    static func updateGraph(graph: AdjacencyList<Node>, id: String?, color: UIColor) -> AdjacencyList<Node> {
        for (key, _) in (graph.adjacencyDict) {
            if "\(key.data.uid)" == id {
                key.data.color = color
            }
        }
        return graph
    }
    
    
}


