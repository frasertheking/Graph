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
    case Custom
    
    struct ShapeConstants {
        static let sphereRadius: CGFloat = 0.5
        static let cylinderRadius: CGFloat = 0.1
        static let cylinderHeight: CGFloat = 3.1
        static let customShapeName = "node.dae"
        static let primaryMaterialColor = UIColor.defaultVertexColor()
        static let secondaryMaterialColor = UIColor.white
    }
    
    static func spawnShape(type: Shapes, position: SCNVector3, color: UIColor, id: Int, node: SCNNode) {
        var geometry:SCNGeometry
        
        switch type {
        case .Sphere:
            geometry = SCNSphere(radius: ShapeConstants.sphereRadius)
        case .Custom:
            let geoScene = SCNScene(named: ShapeConstants.customShapeName)
            guard let geom = geoScene?.rootNode.childNode(withName: "node", recursively: true)?.geometry else {
                return
            }
            
            geometry = geom
        }
        
        geometry.materials.first?.diffuse.contents = ShapeConstants.primaryMaterialColor
        geometry.materials[1].diffuse.contents = ShapeConstants.secondaryMaterialColor
        
        if type == .Custom {
            geometry.name = "\(id)"
        }
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = position
        geometryNode.scale = SCNVector3(ShapeConstants.sphereRadius, ShapeConstants.sphereRadius, ShapeConstants.sphereRadius)
        geometryNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float(Double.pi/2))
        
        node.addChildNode(geometryNode)
    }
    
    static func randomCGFloat() -> Float {
        return Float(arc4random()) /  Float(UInt32.max)
    }
}
