//
//  SCNNode+Extensions.swift
//  Graph
//
//  Created by Fraser King on 2017-11-12.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    
    // Function which automatically creates "edges" between nodes defined in the level    
    func buildLineInTwoPointsWithRotation(from startPoint: SCNVector3,
                                          to endPoint: SCNVector3,
                                          radius: CGFloat,
                                          color: UIColor) -> SCNNode {
        let w = SCNVector3(x: endPoint.x-startPoint.x,
                           y: endPoint.y-startPoint.y,
                           z: endPoint.z-startPoint.z)
        let l = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))
        
        if l == 0.0 {
            let sphere = SCNSphere(radius: radius)
            sphere.firstMaterial?.diffuse.contents = color
            self.geometry = sphere
            self.position = startPoint
            return self
        }
        
        let cyl = SCNCylinder(radius: radius, height: l)
        cyl.name = "edge"
        cyl.firstMaterial?.diffuse.contents = color
        
        self.geometry = cyl
        
        let ov = SCNVector3(0, l/2.0, 0)
        let nv = SCNVector3((endPoint.x - startPoint.x)/2.0, (endPoint.y - startPoint.y)/2.0,
                            (endPoint.z-startPoint.z)/2.0)
        
        let av = SCNVector3( (ov.x + nv.x)/2.0, (ov.y+nv.y)/2.0, (ov.z+nv.z)/2.0)
        
        let av_normalized: SCNVector3 = av.normalizeVector()
        let q0 = Float(0.0)
        let q1 = Float(av_normalized.x)
        let q2 = Float(av_normalized.y)
        let q3 = Float(av_normalized.z)
        
        let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
        let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
        let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
        let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
        let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
        let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
        let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
        let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
        let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3
        
        self.transform.m11 = r_m11
        self.transform.m12 = r_m12
        self.transform.m13 = r_m13
        self.transform.m14 = 0.0
        
        self.transform.m21 = r_m21
        self.transform.m22 = r_m22
        self.transform.m23 = r_m23
        self.transform.m24 = 0.0
        
        self.transform.m31 = r_m31
        self.transform.m32 = r_m32
        self.transform.m33 = r_m33
        self.transform.m34 = 0.0
        
        self.transform.m41 = (startPoint.x + endPoint.x) / 2.0
        self.transform.m42 = (startPoint.y + endPoint.y) / 2.0
        self.transform.m43 = (startPoint.z + endPoint.z) / 2.0
        self.transform.m44 = 1.0
        
        if self.rotation.x.isNaN && self.rotation.y.isNaN && self.rotation.z.isNaN && self.rotation.w.isNaN {
            self.rotation = SCNVector4(0, 1, 0, 3.141593)
            self.scale = SCNVector3(1, 1, 1)
        }
        
        return self
    }
    
    func triangleFrom(vector1: SCNVector3, vector2: SCNVector3, vector3: SCNVector3) -> SCNNode {
        let indices: [Int32] = [0, 1, 2]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2, vector3])
        
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        
        return SCNNode(geometry: SCNGeometry(sources: [source], elements: [element]))
    }
    
    func setupGrid(gridSize: Int, z: Float) {
        let gridLines = SCNNode()
        let gridNodes = SCNNode()
        
        for y in -gridSize...gridSize {
            if abs(y) % 2 == 1 {
                let node = SCNNode()
                if y != -gridSize && y != gridSize {
                    node.opacity = 0.05
                } else {
                    node.opacity = 0.5
                }
                gridLines.addChildNode(node.buildLineInTwoPointsWithRotation(from: SCNVector3(x: Float(-gridSize), y: Float(y), z: z), to: SCNVector3(x: Float(gridSize), y: Float(y), z: z), radius: 0.01, color: .black))
            }
        }
        
        for x in -gridSize...gridSize {
            if abs(x) % 2 == 1 {
                let node = SCNNode()
                if x != -gridSize && x != gridSize {
                    node.opacity = 0.05
                } else {
                    node.opacity = 0.5
                }
                gridLines.addChildNode(node.buildLineInTwoPointsWithRotation(from: SCNVector3(x: Float(x), y: Float(-gridSize), z: z), to: SCNVector3(x: Float(x), y: Float(gridSize), z: z), radius: 0.01, color: .black))
            }
        }
        
        for x in -gridSize...gridSize {
            for y in -gridSize...gridSize {
                if abs(x) % 2 == 1 && abs(y) % 2 == 1 {
                    let node = Shape.getSphereNode()
                    node.opacity = 0.1
                    node.position = SCNVector3(x: Float(x), y: Float(y), z: z)
                    gridNodes.addChildNode(node)
                }
            }
        }
        
        self.addChildNode(gridLines)
        self.addChildNode(gridNodes)
        gridLines.opacity = 0
        gridNodes.opacity = 0
    }
    
    func setupPlane() {
        self.addChildNode(Shape.getPlaneNode())
    }
    
    func findNodeInChildren(node: SCNNode) -> SCNNode? {
        for child in self.childNodes {
            if child.geometry?.name == node.geometry?.name {
                return child
            }
        }
        return nil
    }
    
    func findEmitterNodeInChildren() -> SCNNode? {
        for child in self.childNodes {
            if child.geometry?.name == "\(1)" {
                return child
            }
        }
        return nil
    }
    
    func isNodeAnEmitter() -> Bool {
        if self.geometry?.name == "\(1)" {
            return true
        }
        return false
    }
}

