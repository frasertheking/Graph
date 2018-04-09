//
//  LevelSelectViewController.swift
//  Graph
//
//  Created by Fraser King on 2017-11-10.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit
import Pastel
import M13Checkbox
import CountdownLabel

class LevelSelectViewController: UIViewController {

    // SCENE VARS
    @IBOutlet var scnView: SCNView!
    var scnScene: SCNScene!
    var edgeNodes: SCNNode!
    var edgeArray: [Edge<Node>]!
    var vertexNodes: SCNNode!
    var lightNodes: SCNNode!
    var colorSelectNodes: SCNNode!

    // GLOBAL VARS
    var activeLevel: Level?
    var currentLevel: Int = 0
    var lightLayerFront: CALayer!
    var straylightViewFront: UIView!
    var lightLayerBack: CALayer!
    var straylightViewBack: UIView!
    var h: Float = 1
    var axisPanGestureRecognizer: UIPanGestureRecognizer!

    // UI
    @IBOutlet var skView: SKView!
    
    // CAMERA VARS
    var cameraOrbit: SCNNode!
    var cameraNode: SCNNode!
    let camera = SCNCamera()
    
    struct GameConstants {
        static let kCameraZ: Float = 25
        static let kScaleShrink: CGFloat = 0.8
        static let kScaleGrow: CGFloat = 1.25
        static let kPanTranslationScaleFactor: CGFloat = 25
        static let kPlanarMaxMagnitude: Float = 7
        
        // Timing Constants
        static let kVeryShortTimeDelay: Double = 0.1
        static let kShortTimeDelay: Double = 0.3
        static let kMediumTimeDelay: Double = 0.55
        static let kLongTimeDelay: Double = 1.05
        static let kVeryLongDelay: Double = 1.5
        
        // CollectionView Constants
        static let kPaintCellReuseIdentifier: String = "cell"
        static let kPaintCellWidthHeight: Int = 60
        static let kPaintCellPadding: Int = 10
        static let kCollectionViewBottomOffsetShowing: CGFloat = -115
        static let kCollectionViewBottomOffsetHidden: CGFloat = 16
        static let kDefaultCellsInSection: Int = 3
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupCamera()
        
        setupLevel()
        setupInteractions()
    }
    
    func setupView() {
        guard let sceneView = scnView else {
            return
        }
        
        axisPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gestureRecognize:)))
        scnView.addGestureRecognizer(axisPanGestureRecognizer)
        
        scnView = sceneView
        scnView.showsStatistics = false
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = .multisampling4X
        scnView.delegate = self
        scnView.isPlaying = true
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnView.backgroundColor = UIColor.clear
        scnScene.background.contents = UIColor.clear
        
        lightLayerFront = CALayer()
        lightLayerFront.frame = skView.frame
        straylightViewFront = UIView()
        straylightViewFront.frame = skView.frame
        straylightViewFront.backgroundColor = .clear
        straylightViewFront.layer.addSublayer(lightLayerFront)
        straylightViewFront.addParallaxToView(amount: 25)
        straylightViewFront.isUserInteractionEnabled = false
        
        lightLayerBack = CALayer()
        lightLayerBack.frame = skView.frame
        straylightViewBack = UIView()
        straylightViewBack.frame = skView.frame
        straylightViewBack.backgroundColor = .clear
        straylightViewBack.layer.addSublayer(lightLayerBack)
        straylightViewBack.addParallaxToView(amount: 10)
        
        skView.addSubview(straylightViewBack)
        scnView.addSubview(straylightViewFront)
        
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = self.view.frame.size
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.clear] //Use diffrent colors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.opacity = 0.5
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: GameConstants.kCameraZ)
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    @objc func setupLevel() {
        scnView.isUserInteractionEnabled = true
        activeLevel = Levels.createLevel(index: currentLevel)
        scnView.pointOfView?.runAction(SCNAction.move(to: SCNVector3(x: 0, y: 0, z: GameConstants.kCameraZ), duration: 0.5))
        scnView.pointOfView?.runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.5))
        
        setupStraylights()
        createObjects()
        GraphAnimation.explodeGraph(vertexNodes: vertexNodes, edgeNodes: edgeNodes)

//        GraphAnimation.delayWithSeconds(GameConstants.kMediumTimeDelay) {
//            GraphAnimation.rotateGraphObject(vertexNodes: self.vertexNodes, edgeNodes: self.edgeNodes)
//            guard let graphType = self.activeLevel?.graphType else {
//                return
//            }
//        
//            if graphType != .planar {
//                GraphAnimation.swellGraphObject(vertexNodes: self.vertexNodes, edgeNodes: self.edgeNodes)
//            }
//        }
    }
    
    func setupInteractions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        UIColor.setupBackgrounds(view: view, skView: skView)
    }
    
    func setupStraylights() {
        UIView.animate(withDuration: 0.5, animations: {
            self.straylightViewFront.alpha = 0
            self.straylightViewBack.alpha = 0
        }) { (finished) in
            self.lightLayerFront.sublayers = nil
            self.lightLayerBack.sublayers = nil
            GraphAnimation.delayWithSeconds(0.2) {
                self.straylightViewFront.alpha = 1
                self.straylightViewBack.alpha = 1
            }
            
            let numberOfLines = Int.random(min: 3, max: 5)
            let slope = Float.random(min: 1.35, max: 1.5)

            for _ in 0...numberOfLines {
                let frontOrBack = Int.random(min: 0, max: 1)
                let randomYStart = Int.random(min: 50, max: 450)
                let randomYEnd = Float(self.view.frame.size.width) * slope + Float(randomYStart)
                let randomWidth = Int.random(min: 8, max: 18)

                if frontOrBack == 1 {
                    self.lightLayerFront.drawLine(fromPoint: CGPoint(x: Int(self.view.frame.size.width)+50, y: randomYStart), toPoint: CGPoint(x: -50, y: Int(randomYEnd)), width: CGFloat(randomWidth))
                } else {
                    self.lightLayerBack.drawLine(fromPoint: CGPoint(x: Int(self.view.frame.size.width)+50, y: randomYStart), toPoint: CGPoint(x: -50, y: Int(randomYEnd)), width: CGFloat(randomWidth))
                }
            }
            
            if let frontLayers = self.lightLayerFront.sublayers {
                for layer in frontLayers {
                    GraphAnimation.delayWithSeconds(Double.random(min: 0.5, max: 2)) {
                        let animation : CABasicAnimation = CABasicAnimation(keyPath: "opacity")
                        animation.fromValue = 0
                        animation.toValue = Float.random(min: 0.02, max: 0.06)
                        animation.duration = Double.random(min: 1, max: 1.5)
                        animation.isRemovedOnCompletion = false
                        animation.fillMode = kCAFillModeForwards
                        layer.add(animation, forKey: nil)
                        GraphAnimation.delayWithSeconds(Double.random(min: 3, max: 6)) {
                            GraphAnimation.addOpacityPulse(to: layer)
                        }
                    }
                }
            }
                        
            if let backLayers = self.lightLayerBack.sublayers {
                for layer in backLayers {
                    GraphAnimation.delayWithSeconds(Double.random(min: 0.5, max: 2)) {
                        let animation : CABasicAnimation = CABasicAnimation(keyPath: "opacity")
                        animation.fromValue = 0
                        animation.toValue = Float.random(min: 0.1, max: 0.15)
                        animation.duration = Double.random(min: 1, max: 1.5)
                        animation.isRemovedOnCompletion = false
                        animation.fillMode = kCAFillModeForwards
                        layer.add(animation, forKey: nil)
                        GraphAnimation.delayWithSeconds(Double.random(min: 3, max: 6)) {
                            GraphAnimation.addOpacityPulse(to: layer)
                        }
                    }
                }
            }
        }
    }
    
    func createObjects() {
        edgeNodes = SCNNode()
        vertexNodes = SCNNode()
        let edgeColor = UIColor.defaultVertexColor()
        
        guard let adjacencyDict = activeLevel?.adjacencyList?.adjacencyDict else {
            return
        }

        edgeArray = []
        
        for (key, value) in adjacencyDict {
            // Create nodes
            Shapes.spawnShape(type: .Hexagon, position: key.data.position, color: key.data.color, id: key.data.uid, node: vertexNodes)
            
            // Create edges
            for edge in value {
                if edgeArray.filter({ el in (el.destination.data.position.equal(b: edge.source.data.position) && el.source.data.position.equal(b: edge.destination.data.position)) }).count == 0 {
                    let node = SCNNode()
                    edgeNodes.addChildNode(node.buildLineInTwoPointsWithRotation(from: edge.source.data.position, to: edge.destination.data.position, radius: Shapes.ShapeConstants.cylinderRadius, color: edgeColor))
                    
                    edgeArray.append(edge)
                }
            }
        }
        
        scnScene.rootNode.addChildNode(vertexNodes)
        scnScene.rootNode.addChildNode(edgeNodes)
    }
    
    func handleTouchFor(node: SCNNode) {
        
        guard let geometry = node.geometry else {
            return
        }
//
//        guard let geoName = geometry.name else {
//            return
//        }
//
//        guard let graphType: GraphType = activeLevel?.graphType else {
//            return
//        }
//
//        guard let isMirror: Bool = activeLevel?.isMirror else {
//            return
//        }
        
        // First check for legal moves - return early if illegal
        if geometry.name != "edge" {
           print("Node selected")
        }
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let location = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        
        if hitResults.count > 0 {
            if let result = hitResults.first {
                handleTouchFor(node: result.node)
            }
        }
    }
    
    @objc func cleanScene() {
        vertexNodes.removeFromParentNode()
        edgeNodes.removeFromParentNode()
        simPath.removeAll()
        
        currentLevel += 1
        setupLevel()
    }
    
    @objc func panGesture(gestureRecognize: UIPanGestureRecognizer){
        if gestureRecognize.state == .changed {
            guard let recognizerView = gestureRecognize.view else {
                return
            }
            
            let translation = gestureRecognize.translation(in: recognizerView)
            
            vertexNodes.position = SCNVector3(x: vertexNodes.position.x + Float(translation.x / GameConstants.kPanTranslationScaleFactor),
                                                    y: vertexNodes.position.y - Float(translation.y / GameConstants.kPanTranslationScaleFactor),
                                                    z: vertexNodes.position.z)
        
            edgeNodes.position = SCNVector3(x: edgeNodes.position.x + Float(translation.x / GameConstants.kPanTranslationScaleFactor),
                                              y: edgeNodes.position.y - Float(translation.y / GameConstants.kPanTranslationScaleFactor),
                                              z: edgeNodes.position.z)
            
            gestureRecognize.setTranslation(CGPoint.zero, in: recognizerView)
        }
    }
}

// Draw Loop
extension LevelSelectViewController: SCNSceneRendererDelegate {
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//
//    }
}
