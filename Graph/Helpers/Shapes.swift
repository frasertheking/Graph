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
    
    case Box = 0
    case Sphere
    case Pyramid
    case Torus
    case Capsule
    case Cylinder
    case Cone
    case Tube
    case Custom
    
    static func random() -> Shapes {
        let maxValue = Tube.rawValue
        let rand = arc4random_uniform(UInt32(maxValue + 1))
        return Shapes(rawValue: Int(rand))!
    }
    
    static func spawnShape(type: Shapes, position: SCNVector3, color: UIColor, id: Int, node: SCNNode) {
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
        case .Custom:
            
            let geoScene = SCNScene(named: "node.dae")
            geometry = (geoScene?.rootNode.childNode(withName: "node", recursively: true)?.geometry!)!
            
            
            // Load custom object from OBJ geom
//            let bundle = Bundle.main
//            let path = bundle.path(forResource: "test", ofType: "obj")
//
//            guard let objPath = path else {
//                return
//            }
//
//            let url = NSURL(fileURLWithPath: objPath)
//            let asset = MDLAsset(url: url as URL)
//            let object = asset.object(at: 0)
//            let node = SCNNode(mdlObject: object)
//
//            guard let nodeGeom = node.geometry else {
//                return
//            }
//            geometry = nodeGeom
        }
        
        geometry.materials.first?.diffuse.contents = UIColor.black
        geometry.materials[1].diffuse.contents = UIColor.white

        if type == .Custom {
            geometry.name = "\(id)"
        }
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = position
        geometryNode.scale = SCNVector3(0.6, 0.6, 0.6)
        
        node.addChildNode(geometryNode)
    }
}
