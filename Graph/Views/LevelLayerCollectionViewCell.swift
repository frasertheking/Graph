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
    @IBOutlet var levelStampView: UIView!
    @IBOutlet var levelStampImageView: UIImageView!
    @IBOutlet var lockedOverview: UIView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.addDropShadow()
        
        let maskViewCompleted = UIView(frame: self.titleView.bounds)
        maskViewCompleted.backgroundColor = .clear
        maskViewCompleted.layer.borderColor = UIColor.black.cgColor
        
        let topView: UIView = UIView(frame: self.titleView.bounds)
        topView.backgroundColor = .white
        topView.frame.size.height = 45
        maskViewCompleted.addSubview(topView)
        
        self.titleView.contentView.mask = maskViewCompleted
        UIColor.insertPercentageGradient(for: completionView)
        
        GraphAnimation.delayWithSeconds(0.5) {
            GraphAnimation.animateFloatView(self.markerView)
            GraphAnimation.addPulse(to: self.levelStampView, duration: 1)
        }

    }
    
    func setPercentComplete(percentage: CGFloat, locked: Bool) {
        if locked {
            levelStampImageView.image = UIImage(named: "lock")
            levelStampImageView.setImageColor(color: UIColor.customBlue())
            markerView.isHidden = true
            widthConstraint.constant = 0
            lockedOverview.isHidden = false
            return
        }
        
        let width = (self.frame.size.width * percentage)
        let markerTrailing = (self.frame.size.width - width) - (markerView.frame.size.width / 2)
        widthConstraint.constant = width
        markerViewTrailingConstraint.constant = markerTrailing
        
        if percentage < 0.05 || percentage > 0.95 {
            markerView.isHidden = true
        } else {
            markerView.isHidden = false
        }
        
        if percentage == 1 {
            levelStampView.isHidden = false
            levelStampImageView.image = UIImage(named: "crown")
            levelStampImageView.setImageColor(color: UIColor.goldColor())
        } else {
            levelStampView.isHidden = true
        }
        
        lockedOverview.isHidden = true
    }
    
    func setAppearAnimation() {
        self.gifImageView.layer.removeAllAnimations()

        let gridGif = UIImage.gif(name: "Aleph")
        var values = [CGImage]()
        for image in gridGif!.images! {
            values.append(image.cgImage!)
        }
        
        let animation = CAKeyframeAnimation(keyPath: "contents")
        animation.calculationMode = kCAAnimationDiscrete
        animation.duration = 1
        animation.values = values
        animation.repeatCount = 1
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        GraphAnimation.delayWithSeconds(0.75) {
            self.gifImageView.layer.add(animation, forKey: "animation")
        }
        
        GraphAnimation.delayWithSeconds(1.75) {
            self.setIdleAnimation()
        }
    }
    
    func setIdleAnimation() {
        self.gifImageView.layer.removeAllAnimations()

        let idleGif = UIImage.gif(name: "Aleph_Idle")
        var idleValues = [CGImage]()
        for image in idleGif!.images! {
            idleValues.append(image.cgImage!)
        }
        
        let animation = CAKeyframeAnimation(keyPath: "contents")
        animation.calculationMode = kCAAnimationDiscrete
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.values = idleValues
        animation.duration = 0.5
        animation.repeatCount = Float.infinity
        self.gifImageView.layer.add(animation, forKey: "animation")
        GraphAnimation.addPulse(to: self.gifImageView, duration: 2)
    }
}
