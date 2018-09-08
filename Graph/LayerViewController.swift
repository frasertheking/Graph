//
//  LayerViewController.swift
//  Graph
//
//  Created by Fraser King on 2018-08-28.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import UIKit

private let reuseIdentifier = "LayerCell"
private let layerNames: [String] = ["ALEPH", "CHIBA", "PRIM", "NINSEI", "KUANG"]
private let percentages: [CGFloat] = [0.9, 0.6, 0.75, 0.1, 0.25]
private let layerColors: [(UIColor, UIColor)] = [(.red, .blue), (.orange, .green), (.purple, .yellow), (.cyan, .magenta), (.white, .black)]

class LayerViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var prevButton: UIButton!
    @IBOutlet var nextImageView: UIImageView!
    @IBOutlet var prevImageView: UIImageView!
    var firstLoad: Bool = true
    var currentPosition = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "LevelLayerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.layer.masksToBounds = false
        collectionView.alpha = 0
        collectionView.isScrollEnabled = false
        collectionView.scrollToItem(at:IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
        nextButton.alpha = 0
        prevButton.alpha = 0
        nextImageView.alpha = 0
        prevImageView.alpha = 0

        GraphAnimation.delayWithSeconds(0.2) {
            UIView.animate(withDuration: 1) {
                self.collectionView.alpha = 1
                self.nextButton.alpha = 1
                self.prevButton.alpha = 1
                self.nextImageView.alpha = 1
                self.prevImageView.alpha = 1
            }
        }
    }
    
    func updatePosition() {
        if let cell = collectionView.cellForItem(at: IndexPath(item: currentPosition, section: 0)) as? LevelLayerCollectionViewCell {
            cell.setIdleAnimation()
        }
        collectionView.scrollToItem(at: IndexPath(item: currentPosition, section: 0), at: .centeredHorizontally, animated: true)
        nextButton.isUserInteractionEnabled = false
        prevButton.isUserInteractionEnabled = false
        GraphAnimation.delayWithSeconds(0.2) {
            self.nextButton.isUserInteractionEnabled = true
            self.prevButton.isUserInteractionEnabled = true
        }
    }

    @IBAction func nextPressed() {
        if currentPosition < 4 {
            currentPosition += 1
            updatePosition()
        }
    }
    
    @IBAction func prevPressed() {
        if currentPosition > 0 {
            currentPosition -= 1
            updatePosition()
        }
    }
    
    @IBAction func settingsPressed() {
        print("settingsPressed")
    }
    
    @IBAction func layerPressed() {
        UIView.animate(withDuration: 0.5, animations: {
            self.collectionView.alpha = 0
            self.prevButton.alpha = 0
            self.nextButton.alpha = 0
            self.nextImageView.alpha = 0
            self.prevImageView.alpha = 0
        }) { (finished) in
            self.performSegue(withIdentifier: "unwindToLevelSelect", sender: self)
        }
    }
}

extension LayerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 240, height: 275)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LevelLayerCollectionViewCell
        cell.backgroundColor = .white
        UIColor.insertGradient(for: cell.containerView, color1: layerColors[indexPath.row].0, color2: layerColors[indexPath.row].1)
        UIColor.setupBackgrounds(view: cell.containerView, skView: cell.skView)
        cell.title.text = layerNames[indexPath.row]
        cell.setPercentComplete(percentage: percentages[indexPath.row])
        cell.layoutIfNeeded()        
        if firstLoad {
            cell.setAppearAnimation()
            firstLoad = false
        } else {
            cell.setIdleAnimation()
        }
        
        return cell
    }
}

extension LayerViewController: UICollectionViewDelegate {

    // MARK: UICollectionViewDelegate

    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
}
