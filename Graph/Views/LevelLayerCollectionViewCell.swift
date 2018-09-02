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
        
        let animation = CAKeyframeAnimation(keyPath: "contents")
        animation.calculationMode = kCAAnimationDiscrete
        animation.duration = 1.5
        animation.values = values
        animation.repeatCount = 1
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        GraphAnimation.delayWithSeconds(1.5) {
            self.gifImageView.layer.add(animation, forKey: "animation")
        }
        
        GraphAnimation.delayWithSeconds(3) {
            GraphAnimation.addPulse(to: self.gifImageView, duration: 2)
        }
    }
    
    func setPercentComplete(percentage: CGFloat) {
        let width = (self.frame.size.width * percentage)
        widthConstraint.constant = width
    }
}
