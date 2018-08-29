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
    }
    
    func setPercentComplete(percentage: CGFloat) {
        let width = (self.frame.size.width * percentage)
        widthConstraint.constant = width
    }
}
