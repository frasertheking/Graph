//
//  UIView+Extensions.swift
//  Graph
//
//  Created by Fraser King on 2018-02-17.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addParallaxToView(amount: Int) {
        
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        self.addMotionEffect(group)
    }
    
    func applyGradient(withColours colours: [UIColor]) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        self.layer.sublayers = nil
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func removeSubviews() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func addDropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 12
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
    
    func addBorderHighlight() {
        self.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        self.layer.borderWidth = 2
    }
    
    func addBorder() {
        self.layer.borderColor = UIColor.black.withAlphaComponent(0.35).cgColor
        self.layer.borderWidth = 2
    }
    
    func addCustomMaskToViews(border: UIView, borderMaskName: String, backMaskName: String) {
        let maskView = UIView(frame: self.bounds)
        maskView.backgroundColor = .clear
        let backMask = UIImageView(image: UIImage(named: backMaskName))
        backMask.frame = self.bounds
        maskView.addSubview(backMask)
        self.backgroundColor = .clear
        self.mask = maskView
        
        let borderMask = UIView(frame: border.bounds)
        borderMask.backgroundColor = .clear
        let backBorderMask = UIImageView(image: UIImage(named: borderMaskName))
        backBorderMask.frame = border.bounds        
        borderMask.addSubview(backBorderMask)
        border.backgroundColor = .clear
        border.mask = borderMask
    }
}
