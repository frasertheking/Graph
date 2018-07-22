//
//  UIImageVIew+Extensions.swift
//  Graph
//
//  Created by Fraser King on 2018-07-22.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}
