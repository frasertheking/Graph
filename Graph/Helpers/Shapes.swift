//
//  Shapes.swift
//  Graph
//
//  Created by Fraser King on 2017-11-10.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

public enum Shapes:Int {
    
    case Box = 0
    case Sphere
    case Pyramid
    case Torus
    case Capsule
    case Cylinder
    case Cone
    case Tube
    
    static func random() -> Shapes {
        let maxValue = Tube.rawValue
        let rand = arc4random_uniform(UInt32(maxValue+1))
        return Shapes(rawValue: Int(rand))!
    }
    
    static func spawnShape(type: Shapes, position: SCNVector3, color: UIColor, id: Int, scnScene: SCNScene) {
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
        geometryNode.position = position
        
        scnScene.rootNode.addChildNode(geometryNode)
    }
}