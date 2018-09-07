//
//  LevelLayerCollectionViewCell.swift
//  Graph
//
//  Created by Fraser King on 2018-08-28.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class LevelLayerCollectionViewCell: UICollectionViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var skView: SKView!
    @IBOutlet var titleView: UIVisualEffectView!
    @IBOutlet var completionView: UIView!
    @IBOutlet var markerView: UIView!
    @IBOutlet var markerViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var markerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var widthConstraint: NSLayoutConstraint!
    @IBOutlet var gifImageView: UIImageView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        let maskPath = UIBezierPath(roundedRect: self.bounds,
//                                    byRoundingCorners: [.topLeft, .topRight],
//                                    cornerRadii: CGSize(width: 20.0, height: 20.0))
//
//        let shape = CAShapeLayer()
//        shape.path = maskPath.cgPath
//        self.contentView.layer.mask = shape
//        self.contentView.layer.masksToBounds = true
       
        let maskViewCompleted = UIView(frame: self.titleView.bounds)
        maskViewCompleted.backgroundColor = .clear
        maskViewCompleted.layer.borderColor = UIColor.black.cgColor
        
        let topView: UIView = UIView(frame: self.titleView.bounds)
        topView.backgroundColor = .white
        topView.frame.size.height = 45
        maskViewCompleted.addSubview(topView)
        
        self.titleView.contentView.mask = maskViewCompleted
        UIColor.insertPercentageGradient(for: completionView)
        
        let gridGif = UIImage.gif(name: "Aleph")
        var values = [CGImage]()
        for image in gridGif!.images! {
            values.append(image.cgImage!)
        }
        
        let idleGif = UIImage.gif(name: "Aleph_Idle")
        var idleValues = [CGImage]()
        for image in idleGif!.images! {
            idleValues.append(image.cgImage!)
        }
        
        let animation = CAKeyframeAnimation(keyPath: "contents")
        animation.calculationMode = kCAAnimationDiscrete
        animation.duration = 1
        animation.values = values
        animation.repeatCount = 1
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        GraphAnimation.delayWithSeconds(0.5) {
            GraphAnimation.animateFloatView(self.markerView)
        }
        
        GraphAnimation.delayWithSeconds(1.5) {
            self.gifImageView.layer.add(animation, forKey: "animation")
        }
        
        GraphAnimation.delayWithSeconds(2.5) {
            self.gifImageView.layer.removeAllAnimations()
            animation.values = idleValues
            animation.duration = 0.5
            animation.repeatCount = Float.infinity
            self.gifImageView.layer.add(animation, forKey: "animation")
            GraphAnimation.addPulse(to: self.gifImageView, duration: 2)
        }
        
        // DROP SHADOW
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        self.layer.shadowRadius = 12.0
        self.layer.shadowOpacity = 0.35
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    func setPercentComplete(percentage: CGFloat) {
        let width = (self.frame.size.width * percentage)
        let markerTrailing = (self.frame.size.width - width) - (markerView.frame.size.width / 2)
        widthConstraint.constant = width
        markerViewTrailingConstraint.constant = markerTrailing
    }
}
