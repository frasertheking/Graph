//
//  Shape.swift
//  Graph
//
//  Created by Fraser King on 2017-11-10.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import Foundation
import SceneKit
import ModelIO
import SceneKit.ModelIO

public enum Shape: Int {
    
    case Node = 0
    case Hamiltonian
    case HamiltonianComplete
    case HamiltonianRandom
    case HamiltonianLocked
    case Planar
    case PlanarComplete
    case PlanarRandom
    case PlanarLocked
    case kColor
    case kColorComplete
    case kColorRandom
    case kColorLocked
    case Emitter
    
    struct ShapeConstants {
        static let sphereRadius: CGFloat = 0.5
        static let cylinderRadius: CGFloat = 0.1
        static let cylinderHeight: CGFloat = 3.1
        static let primaryMaterialColor = UIColor.defaultVertexColor()
        static let secondaryMaterialColor = UIColor.white
    }
    
    static let shapeNames = ["node",
                             "hamiltonian",
                             "hamiltonian_complete",
                             "hamiltonian_random",
                             "hamiltonian_locked",
                             "planar",
                             "planar_complete",
                             "planar_random",
                             "planar_locked",
                             "kColor",
                             "kColor_complete",
                             "kColor_random",
                             "kColor_locked",
                             "node"]
    
    static func spawnShape(type: Shape, position: SCNVector3, color: UIColor, id: Int, node: SCNNode) {
        guard let geometry: SCNGeometry = createNodeOfType(type: type) else {
            return
        }
        
        geometry.materials.first?.diffuse.contents = ShapeConstants.primaryMaterialColor
        geometry.materials[1].diffuse.contents = ShapeConstants.secondaryMaterialColor
        
        if type.rawValue > 0  {
            geometry.materials.first?.diffuse.contents = UIColor.white
            geometry.materials[1].diffuse.contents = UIColor.red
        }
        
        geometry.name = "\(id)"
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = position
        
        if type != .Node && type != .Emitter {
            geometryNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(Double.pi/2))
            geometryNode.position = SCNVector3(x: position.x, y: position.y, z: position.z + 0.1)
        } else if type == .Node {
            geometryNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float(Double.pi/2))
            geometryNode.scale = SCNVector3(ShapeConstants.sphereRadius, ShapeConstants.sphereRadius, ShapeConstants.sphereRadius)
        }
        
        node.addChildNode(geometryNode)
    }
    
    private static func createNodeOfType(type: Shape) -> SCNGeometry? {
        let geoScene = SCNScene(named: shapeNames[type.rawValue])
        guard let geom = geoScene?.rootNode.childNode(withName: "node", recursively: true)?.geometry else {
            return nil
        }
        return geom
    }
    
//    static func randomCGFloat() -> Float {
//        return Float(arc4random()) /  Float(UInt32.max)
//    }
}
