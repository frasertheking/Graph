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
        line.opacity = 0.5
        line.lineWidth = width
        
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let gradient = CAGradientLayer()
        gradient.frame = frame

        gradient.colors = [UIColor.white.cgColor,
                           UIColor.clear.cgColor]
        gradient.startPoint = CGPoint(x: 1, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 0)
        gradient.mask = line
        gradient.opacity = 0.5
        self.addSublayer(gradient)
    }
}
