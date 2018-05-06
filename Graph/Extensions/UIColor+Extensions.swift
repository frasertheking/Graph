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
import ChameleonFramework

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
    
    func lighter(by percentage:CGFloat=20.0) -> UIColor? {
        return self.adjust(by: 1 * abs(percentage) )
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
        insertGradient(for: view)
        
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
    
    public static func insertGradient(for view: UIView) {
        let pastelView = PastelView(frame: view.bounds)
        
        // Custom Direction
        pastelView.startPastelPoint = .bottom
        pastelView.endPastelPoint = .top
        
        // Custom Duration
        pastelView.animationDuration = 10.0
        
        // Custom Color
        pastelView.setColors([RandomFlatColorWithShade(.light),
                              RandomFlatColorWithShade(.light),
                              RandomFlatColorWithShade(.light),
                              RandomFlatColorWithShade(.light),
                              RandomFlatColorWithShade(.light),
                              RandomFlatColorWithShade(.light),
                              RandomFlatColorWithShade(.light),
                              RandomFlatColorWithShade(.light),
                              RandomFlatColorWithShade(.light),
                              RandomFlatColorWithShade(.light)])
        
        pastelView.startAnimation()
        
        view.insertSubview(pastelView, at: 0)
    }
    
    public static func insertButtonGradient(for view: UIView) {
        let pastelView = PastelView(frame: view.bounds)
        
        pastelView.startPastelPoint = .topLeft
        pastelView.endPastelPoint = .bottomRight
        pastelView.animationDuration = 2.0
        
        pastelView.setColors([UIColor(red: 27/255, green: 94/255, blue: 32/255, alpha: 1.0),
                              UIColor(red: 230/255, green: 80/255, blue: 0/255, alpha: 1.0),
                              UIColor(red: 49/255, green: 27/255, blue: 146/255, alpha: 1.0),
                              UIColor(red: 13/255, green: 71/255, blue: 161/255, alpha: 1.0),
                              UIColor(red: 183/255, green: 28/255, blue: 28/255, alpha: 1.0)])
        
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
    }
    
    public static func aniColor(from: UIColor, to: UIColor, percentage: CGFloat) -> UIColor {
        let fromComponents = UIColor.rgb(from)
        let toComponents = UIColor.rgb(to)
        
        let color = UIColor(red: (fromComponents()!.red + (toComponents()!.red - fromComponents()!.red) * percentage) / 255,
                            green: (fromComponents()!.green + (toComponents()!.green - fromComponents()!.green) * percentage) / 255,
                            blue: (fromComponents()!.blue + (toComponents()!.blue - fromComponents()!.blue) * percentage) / 255,
                            alpha: 1)
        return color
    }
    
    public func rgb() -> (red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = CGFloat(fRed * 255.0)
            let iGreen = CGFloat(fGreen * 255.0)
            let iBlue = CGFloat(fBlue * 255.0)
            let iAlpha = CGFloat(fAlpha * 255.0)
            
            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}
