//
//  SCNGeometry+Extensions.swift
//  Graph
//
//  Created by Fraser King on 2018-02-18.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import Foundation
import SceneKit

extension SCNGeometry {
    
    class func triangleFrom(vector1: SCNVector3, vector2: SCNVector3, vector3: SCNVector3) -> SCNGeometry {
        
        let indices: [Int32] = [0, 1, 2]

        let source = SCNGeometrySource(vertices: [vector1, vector2, vector3])

        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        
        return SCNGeometry(sources: [source], elements: [element])
    }
}
