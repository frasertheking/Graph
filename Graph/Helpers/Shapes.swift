//
//  Shapes.swift
//  Graph
//
//  Created by Fraser King on 2017-11-10.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import Foundation
import SceneKit
import ModelIO
import SceneKit.ModelIO

public enum Shapes:Int {
    
    case Sphere = 0
    case HexagonComplete
    case HexagonLocked
    case HexagonQuestion
    case Hexagon
    case Emitter
    case Custom
    
    struct ShapeConstants {
        static let sphereRadius: CGFloat = 0.5
        static let cylinderRadius: CGFloat = 0.1
        static let cylinderHeight: CGFloat = 3.1
        static let customShapeName = "node.dae"
        static let hexagonName = "hamiltonian.dae"
        static let hexagonCompleteName = "planar_check.dae"
        static let hexagonLockName = "kColor_lock.dae"
        static let hexagonQuestionName = "kColor_question.dae"
        static let primaryMaterialColor = UIColor.defaultVertexColor()
        static let secondaryMaterialColor = UIColor.white
    }
    
    static func spawnShape(type: Shapes, position: SCNVector3, color: UIColor, id: Int, node: SCNNode) {
        var geometry:SCNGeometry
        
        switch type {
        case .Sphere:
            geometry = SCNSphere(radius: ShapeConstants.sphereRadius)
        case .Hexagon:
            let geoScene = SCNScene(named: ShapeConstants.hexagonName)
            guard let geom = geoScene?.rootNode.childNode(withName: "node", recursively: true)?.geometry else {
                return
            }
            geometry = geom
        case .HexagonComplete:
            let geoScene = SCNScene(named: ShapeConstants.hexagonCompleteName)
            guard let geom = geoScene?.rootNode.childNode(withName: "node", recursively: true)?.geometry else {
                return
            }
            geometry = geom
        case .HexagonLocked:
            let geoScene = SCNScene(named: ShapeConstants.hexagonLockName)
            guard let geom = geoScene?.rootNode.childNode(withName: "node", recursively: true)?.geometry else {
                return
            }
            geometry = geom
        case .HexagonQuestion:
            let geoScene = SCNScene(named: ShapeConstants.hexagonQuestionName)
            guard let geom = geoScene?.rootNode.childNode(withName: "node", recursively: true)?.geometry else {
                return
            }
            geometry = geom
        case .Emitter:
            let geoScene = SCNScene(named: ShapeConstants.customShapeName)
            guard let geom = geoScene?.rootNode.childNode(withName: "node", recursively: true)?.geometry else {
                return
            }
            geometry = geom
        default:
            let geoScene = SCNScene(named: ShapeConstants.customShapeName)
            guard let geom = geoScene?.rootNode.childNode(withName: "node", recursively: true)?.geometry else {
                return
            }
            geometry = geom
        }
        
        geometry.materials.first?.diffuse.contents = ShapeConstants.primaryMaterialColor
        geometry.materials[1].diffuse.contents = ShapeConstants.secondaryMaterialColor
        
        if type == .Hexagon || type == .HexagonComplete || type == .HexagonLocked || type == .HexagonQuestion || type == .Emitter {
            geometry.materials.first?.diffuse.contents = UIColor.white
            geometry.materials[1].diffuse.contents = UIColor.red
        }
        
        geometry.name = "\(id)"
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = position
        
        if type == .Hexagon || type == .HexagonComplete || type == .HexagonLocked || type == .HexagonQuestion {
            geometryNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(Double.pi/2))
            geometryNode.position = SCNVector3(x: position.x, y: position.y, z: position.z + 0.1)
        } else if type != .Emitter {
            geometryNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float(Double.pi/2))
            geometryNode.scale = SCNVector3(ShapeConstants.sphereRadius, ShapeConstants.sphereRadius, ShapeConstants.sphereRadius)
        }
        
        node.addChildNode(geometryNode)
    }
    
    static func randomCGFloat() -> Float {
        return Float(arc4random()) /  Float(UInt32.max)
    }
}
