//
//  UIColor+Extensions.swift
//  Graph
//
//  Created by Fraser King on 2017-11-11.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import SceneKit
import SpriteKit
import Pastel

let UIColorList:[UIColor] = [
    UIColor.black,
    UIColor.white,
    UIColor.red,
    UIColor.limeColor(),
    UIColor.blue,
    UIColor.yellow,
    UIColor.cyan,
    UIColor.silverColor(),
    UIColor.gray,
    UIColor.maroonColor(),
    UIColor.oliveColor(),
    UIColor.brown,
    UIColor.green,
    UIColor.lightGray,
    UIColor.magenta,
    UIColor.orange,
    UIColor.purple,
    UIColor.tealColor(),
    UIColor.goldColor(),
    UIColor.glowColor(),
    UIColor.customRed(),
    UIColor.customGreen(),
    UIColor.customBlue(),
    UIColor.customPurple(),
    UIColor.customOrange(),
    UIColor.customWhite(),
    UIColor.defaultVertexColor()
]

let kColors: [UIColor] = [.customRed(), .customGreen(), .customBlue(), .customPurple(), .customOrange(), .cyan]

extension UIColor {
    
    public static func random() -> UIColor {
        let maxValue = UIColorList.count
        let rand = Int(arc4random_uniform(UInt32(maxValue)))
        return UIColorList[rand]
    }
    
    func darker(by percentage:CGFloat=5.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=5.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
    
    public static func limeColor() -> UIColor {
        return UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
    }
    
    public static func silverColor() -> UIColor {
        return UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1.0)
    }
    
    public static func maroonColor() -> UIColor {
        return UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    
    public static func oliveColor() -> UIColor {
        return UIColor(red: 0.5, green: 0.5, blue: 0.0, alpha: 1.0)
    }
    
    public static func tealColor() -> UIColor {
        return UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 1.0)
    }
    
    public static func navyColor() -> UIColor {
        return UIColor(red: 0.0, green: 0.0, blue: 128, alpha: 1.0)
    }
    
    public static func goldColor() -> UIColor {
        return UIColor(red: 1.0, green: 215/255, blue: 0.0, alpha: 1.0)
    }
    
    public static func glowColor() -> UIColor {
        return UIColor(red: 1.0, green: 215/255, blue: 0.0, alpha: 0.75)
    }
    
    public static func customRed() -> UIColor {
        return UIColor(red: 1.0, green: 59/255, blue: 48/255, alpha: 1.0)
    }
    
    public static func customGreen() -> UIColor {
        return UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1.0)
    }
    
    public static func customBlue() -> UIColor {
        return UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1.0)
    }
    
    public static func customPurple() -> UIColor {
        return UIColor(red: 142/255, green: 68/255, blue: 173/255, alpha: 1.0)
    }
    
    public static func customOrange() -> UIColor {
        return UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1.0)
    }
    
    public static func customWhite() -> UIColor {
        return UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    }
    
    public static func defaultVertexColor() -> UIColor {
        return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    
    public static func setupBackgrounds(view: UIView, skView: SKView) {
        let pastelView = PastelView(frame: view.bounds)
        
        // Custom Direction
        pastelView.startPastelPoint = .bottom
        pastelView.endPastelPoint = .top
        
        // Custom Duration
        pastelView.animationDuration = 10.0
        
        // Custom Color
        pastelView.setColors([ UIColor(red: 247/255, green: 109/255, blue: 130/255, alpha: 1.0),
                               UIColor(red: 217/255, green: 68/255, blue: 82/255, alpha: 1.0),
                               UIColor(red: 98/255, green: 221/255, blue: 189/255, alpha: 1.0),
                               UIColor(red: 53/255, green: 187/255, blue: 155/255, alpha: 1.0),
                               UIColor(red: 115/255, green: 177/255, blue: 244/255, alpha: 1.0),
                               UIColor(red: 75/255, green: 137/255, blue: 218/255, alpha: 1.0)])
        
        pastelView.startAnimation()
        
        view.insertSubview(pastelView, at: 0)
        
        // Add background particles
        let skScene = SKScene(size: CGSize(width: view.frame.size.width, height: view.frame.size.height))
        skScene.backgroundColor = UIColor.clear
        let path = Bundle.main.path(forResource: "Background", ofType: "sks")
        let backgroundParticle = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as! SKEmitterNode
        backgroundParticle.position = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
        backgroundParticle.targetNode = skScene.scene
        backgroundParticle.particlePositionRange = CGVector(dx: view.frame.size.width, dy: view.frame.size.height)
        skScene.scene?.addChild(backgroundParticle)
        skView.presentScene(skScene)
        skView.backgroundColor = UIColor.clear
    }
}
