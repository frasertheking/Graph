//
//  CALayer+Extensions.swift
//  Graph
//
//  Created by Fraser King on 2018-02-16.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import UIKit

extension CALayer {
    func drawLine(fromPoint start: CGPoint, toPoint end:CGPoint, width: CGFloat) {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.fillColor = UIColor.white.cgColor
        line.strokeColor = UIColor.white.cgColor
        line.opacity = 0
        line.lineWidth = width
        self.addSublayer(line)
    }
}
