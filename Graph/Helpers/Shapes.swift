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
    case Emitter
    case Hamiltonian
    case HamiltonianComplete
    case HamiltonianRandom
    case HamiltonianLocked
    case HamiltonianTimed
    case Planar
    case PlanarComplete
    case PlanarRandom
    case PlanarLocked
    case PlanarTimed
    case kColor
    case kColorComplete
    case kColorRandom
    case kColorLocked
    case kColorTimed
    case Mix
    case MixComplete
    case MixLocked
    case MixTimed
    case Spiral
    case Title
    case Play
    
    struct ShapeConstants {
        static let sphereRadius: CGFloat = 0.5
        static let cylinderRadius: CGFloat = 0.1
        static let cylinderHeight: CGFloat = 3.1
        static let primaryMaterialColor = UIColor.defaultVertexColor()
        static let secondaryMaterialColor = UIColor.white
    }
    
    static let shapeNames = ["node",
                             "node",
                             "hamiltonian",
                             "hamiltonian_complete",
                             "hamiltonian_random",
                             "hamiltonian_locked",
                             "hamiltonian_timed",
                             "planar",
                             "planar_complete",
                             "planar_random",
                             "planar_locked",
                             "planar_timed",
                             "kColor",
                             "kColor_complete",
                             "kColor_random",
                             "kColor_locked",
                             "kColor_timed",
                             "mix",
                             "mix_complete",
                             "mix_locked",
                             "mix_timed",
                             "spiral",
                             "title",
                             "play"]
    
    static func spawnShape(type: Shape, position: SCNVector3, color: UIColor, id: Int, node: SCNNode) {
        guard let geometry: SCNGeometry = createNodeOfType(type: type) else {
            return
        }
        
        if type.rawValue == 21 { // SPIRAL
            geometry.materials.first?.diffuse.contents = UIColor.white
            geometry.materials[1].diffuse.contents = color
        } else if type.rawValue == 22 { // TITLE
            geometry.materials.first?.diffuse.contents = color
        } else if type.rawValue == 23 { // PLAY
            geometry.materials.first?.diffuse.contents = UIColor.red
            geometry.materials[1].diffuse.contents = color
        } else if type.rawValue > 1  {
            geometry.materials.first?.diffuse.contents = UIColor.white
            geometry.materials[1].diffuse.contents = color
        } else if type.rawValue == 1 {
            geometry.materials.first?.diffuse.contents = UIColor.black
            geometry.materials[1].diffuse.contents = UIColor.white
        } else {
            geometry.materials.first?.diffuse.contents = color
            geometry.materials[1].diffuse.contents = ShapeConstants.secondaryMaterialColor
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
    
    static func getSphereNode() -> SCNNode {
        let sphere = SCNSphere(radius: 0.1)
        sphere.firstMaterial!.diffuse.contents = UIColor.black
        return SCNNode(geometry: sphere)
    }
    
    static func getPlaneNode() -> SCNNode {
        let plane = SCNPlane(width: 50, height: 50)
        plane.firstMaterial!.diffuse.contents = UIColor.white
        plane.cornerRadius = 4
        return SCNNode(geometry: plane)
    }
}
