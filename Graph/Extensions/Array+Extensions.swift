//
//  Array+Extensions.swift
//  Graph
//
//  Created by Fraser King on 2018-02-11.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import Foundation

extension Array {
    var shuffle:[Element] {
        var elements = self
        for index in 0..<elements.count {
            let anotherIndex = Int(arc4random_uniform(UInt32(elements.count-index)))+index
            if anotherIndex != index {
                elements.swapAt(index, anotherIndex)
            }
        }
        return elements
    }
}
