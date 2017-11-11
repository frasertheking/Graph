//
//  GameViewController.swift
//  Graph
//
//  Created by Fraser King on 2017-11-10.
//  Copyright © 2017 Fraser King. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

class GameViewController: UIViewController {

    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var game = GameHelper.sharedInstance
    let asd = SKSpriteNode(imageNamed:"storm-small")
    let base = SKLabelNode(text: "Hello world")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupCamera()
        
        // @cleanup: formalize shape setup
//        spawnShape(type: .Cylinder, position: SCNVector3(x: -2.0, y: 0.0, z: 2.0), color: UIColor.white, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
//        spawnShape(type: .Sphere, position: SCNVector3(x: -2.0, y: 2.0, z: 2.0), color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
//        spawnShape(type: .Sphere, position: SCNVector3(x: -2.0, y: -2.0, z: 2.0), color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
//
//        spawnShape(type: .Cylinder, position: SCNVector3(x: 2.0, y: 0.0, z: 2.0), color: UIColor.white, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
//        spawnShape(type: .Sphere, position: SCNVector3(x: 2.0, y: 2.0, z: 2.0), color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
//        spawnShape(type: .Sphere, position: SCNVector3(x: 2.0, y: -2.0, z: 2.0), color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
//
//        spawnShape(type: .Cylinder, position: SCNVector3(x: 0.0, y: -2.0, z: 2.0), color: UIColor.white, rotation: SCNVector4(x: 0, y: 0, z: 1, w: Float(Double.pi/2)))
//        spawnShape(type: .Cylinder, position: SCNVector3(x: 0.0, y: 2.0, z: 2.0), color: UIColor.white, rotation: SCNVector4(x: 0, y: 0, z: 1, w: Float(Double.pi/2)))
//
//        spawnShape(type: .Cylinder, position: SCNVector3(x: -2.0, y: 0.0, z: -2.0), color: UIColor.white, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
//        spawnShape(type: .Sphere, position: SCNVector3(x: -2.0, y: 2.0, z: -2.0), color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
//        spawnShape(type: .Sphere, position: SCNVector3(x: -2.0, y: -2.0, z: -2.0), color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
//
//        spawnShape(type: .Cylinder, position: SCNVector3(x: 2.0, y: 0.0, z: -2.0), color: UIColor.white, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
//        spawnShape(type: .Sphere, position: SCNVector3(x: 2.0, y: 2.0, z: -2.0), color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
//        spawnShape(type: .Sphere, position: SCNVector3(x: 2.0, y: -2.0, z: -2.0), color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
//
//        spawnShape(type: .Cylinder, position: SCNVector3(x: 0.0, y: -2.0, z: -2.0), color: UIColor.white, rotation: SCNVector4(x: 0, y: 0, z: 1, w: Float(Double.pi/2)))
//        spawnShape(type: .Cylinder, position: SCNVector3(x: 0.0, y: 2.0, z: -2.0), color: UIColor.white, rotation: SCNVector4(x: 0, y: 0, z: 1, w: Float(Double.pi/2)))
//
//        spawnShape(type: .Cylinder, position: SCNVector3(x: 2.0, y: 2.0, z: 0.0), color: UIColor.white, rotation: SCNVector4(x: 1, y: 0, z: 0, w: Float(Double.pi/2)))
//        spawnShape(type: .Cylinder, position: SCNVector3(x: 2.0, y: -2.0, z: 0.0), color: UIColor.white, rotation: SCNVector4(x: 1, y: 0, z: 0, w: Float(Double.pi/2)))
//        spawnShape(type: .Cylinder, position: SCNVector3(x: -2.0, y: 2.0, z: 0.0), color: UIColor.white, rotation: SCNVector4(x: 1, y: 0, z: 0, w: Float(Double.pi/2)))
//        spawnShape(type: .Cylinder, position: SCNVector3(x: -2.0, y: -2.0, z: 0.0), color: UIColor.white, rotation: SCNVector4(x: 1, y: 0, z: 0, w: Float(Double.pi/2)))

        
        let v1: SCNVector3 = SCNVector3(x: -2.0, y: 2.0, z: 2.0)
        let v2: SCNVector3 = SCNVector3(x: -2.0, y: 2.0, z: -2.0)

        
        let twoPointsNode1 = SCNNode()
        scnScene.rootNode.addChildNode(twoPointsNode1.buildLineInTwoPointsWithRotation(
            from: v1, to: v2, radius: 0.2, color: .white))
        
        
        
        
        
        
        
        
//        let z: SCNVector3 = SCNVector3(x: 0, y: 1, z: 0)
//        let p: SCNVector3 = SCNVector3.subtract(a: a, b: b)
//        let t: SCNVector3 = SCNVector3.cross(a: z, b: p)
//        let angle: Double = 180 / Double.pi * acos(SCNVector3.dot(a: z, b: p) / p.length())
//        let rotation = SCNVector4(x: t.x, y: t.y, z: t.z, w: Float(angle))
        
        spawnShape(type: .Sphere, position: v1, color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
        spawnShape(type: .Sphere, position: v2, color: UIColor.blue, rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0))
//        spawnShape(type: .Cylinder, position: b, color: UIColor.white, rotation: SCNVector4(x: 0.0, y: 4.0, z: 4.0, w: 90.0))
//
//        print(rotation)
        
        setupHUD()
        setupSounds()
        
        let overlayScene = SKScene(size: CGSize(width: scnView.frame.size.width, height: scnView.frame.size.height))
        base.position = CGPoint(x: scnView.frame.size.width/2, y: 50)
        //base.size = CGSize(width: 25, height: 25)
        overlayScene.addChild(base)
        scnView.overlaySKScene?.isUserInteractionEnabled = true
        scnView.overlaySKScene = overlayScene
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    func setupView() {
        scnView = self.view as! SCNView
        //scnView.showsStatistics = true
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        
        scnView.delegate = self
        scnView.isPlaying = true
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        
        scnScene.background.contents = "Graph.scnassets/Textures/Background_Diffuse.png"
    }
    
    func setupHUD() {
        game.hudNode.position = SCNVector3(x: 0.0, y: 4.0, z: 0.0)
        scnScene.rootNode.addChildNode(game.hudNode)
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 25)
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    func cleanScene() {
        for node in scnScene.rootNode.childNodes {
            if node.presentation.position.y < -2 {
                node.removeFromParentNode()
            }
        }
    }
    
    func spawnShape(type: ShapeType, position: SCNVector3, color: UIColor, rotation: SCNVector4) {
        var geometry:SCNGeometry

        switch type {
        case .Box:
            geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        case .Sphere:
            geometry = SCNSphere(radius: 0.5)
        case .Pyramid:
            geometry = SCNPyramid(width: 1.0, height: 1.0, length: 1.0)
        case .Torus:
            geometry = SCNTorus(ringRadius: 0.5, pipeRadius: 0.25)
        case .Capsule:
            geometry = SCNCapsule(capRadius: 0.3, height: 2.5)
        case .Cylinder:
            geometry = SCNCylinder(radius: 0.2, height: 3.1)
        case .Cone:
            geometry = SCNCone(topRadius: 0.25, bottomRadius: 0.5, height: 1.0)
        case .Tube:
            geometry = SCNTube(innerRadius: 0.25, outerRadius: 0.5, height: 1.0)
        }
        
        geometry.materials.first?.diffuse.contents = color
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.rotation = rotation
        geometryNode.position = position
        scnScene.rootNode.addChildNode(geometryNode)
    }
    
    func handleTouchFor(node: SCNNode) {
        node.geometry?.materials.first?.diffuse.contents = UIColor.red
        
        //game.playSound(node: scnScene.rootNode, name: "SpawnGood")
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let location = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        
        if hitResults.count > 0 {
            let result = hitResults.first!
            handleTouchFor(node: result.node)
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    func setupSounds() {
        game.loadSound(name: "ExplodeGood",
                       fileNamed: "Graph.scnassets/Sounds/ExplodeGood.wav")
        game.loadSound(name: "SpawnGood",
                       fileNamed: "Graph.scnassets/Sounds/SpawnGood.wav")
        game.loadSound(name: "ExplodeBad",
                       fileNamed: "Graph.scnassets/Sounds/ExplodeBad.wav")
        game.loadSound(name: "SpawnBad",
                       fileNamed: "Graph.scnassets/Sounds/SpawnBad.wav")
        game.loadSound(name: "GameOver",
                       fileNamed: "Graph.scnassets/Sounds/GameOver.wav")
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //spawnShape()
        //game.updateHUD()
    }
}

extension SCNNode {
    
    func normalizeVector(_ iv: SCNVector3) -> SCNVector3 {
        let length = sqrt(iv.x * iv.x + iv.y * iv.y + iv.z * iv.z)
        if length == 0 {
            return SCNVector3(0.0, 0.0, 0.0)
        }
        
        return SCNVector3( iv.x / length, iv.y / length, iv.z / length)
        
    }
    
    func buildLineInTwoPointsWithRotation(from startPoint: SCNVector3,
                                          to endPoint: SCNVector3,
                                          radius: CGFloat,
                                          color: UIColor) -> SCNNode {
        let w = SCNVector3(x: endPoint.x-startPoint.x,
                           y: endPoint.y-startPoint.y,
                           z: endPoint.z-startPoint.z)
        let l = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))
        
        if l == 0.0 {
            // two points together.
            let sphere = SCNSphere(radius: radius)
            sphere.firstMaterial?.diffuse.contents = color
            self.geometry = sphere
            self.position = startPoint
            return self
            
        }
        
        let cyl = SCNCylinder(radius: radius, height: l)
        cyl.firstMaterial?.diffuse.contents = color
        
        self.geometry = cyl
        
        //original vector of cylinder above 0,0,0
        let ov = SCNVector3(0, l/2.0,0)
        //target vector, in new coordination
        let nv = SCNVector3((endPoint.x - startPoint.x)/2.0, (endPoint.y - startPoint.y)/2.0,
                            (endPoint.z-startPoint.z)/2.0)
        
        // axis between two vector
        let av = SCNVector3( (ov.x + nv.x)/2.0, (ov.y+nv.y)/2.0, (ov.z+nv.z)/2.0)
        
        //normalized axis vector
        let av_normalized: SCNVector3 = normalizeVector(av)
        let q0 = Float(0.0) //cos(angel/2), angle is always 180 or M_PI
        let q1 = Float(av_normalized.x) // x' * sin(angle/2)
        let q2 = Float(av_normalized.y) // y' * sin(angle/2)
        let q3 = Float(av_normalized.z) // z' * sin(angle/2)
        
        let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
        let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
        let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
        let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
        let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
        let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
        let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
        let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
        let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3
        
        self.transform.m11 = r_m11
        self.transform.m12 = r_m12
        self.transform.m13 = r_m13
        self.transform.m14 = 0.0
        
        self.transform.m21 = r_m21
        self.transform.m22 = r_m22
        self.transform.m23 = r_m23
        self.transform.m24 = 0.0
        
        self.transform.m31 = r_m31
        self.transform.m32 = r_m32
        self.transform.m33 = r_m33
        self.transform.m34 = 0.0
        
        self.transform.m41 = (startPoint.x + endPoint.x) / 2.0
        self.transform.m42 = (startPoint.y + endPoint.y) / 2.0
        self.transform.m43 = (startPoint.z + endPoint.z) / 2.0
        self.transform.m44 = 1.0
        return self
    }
}
