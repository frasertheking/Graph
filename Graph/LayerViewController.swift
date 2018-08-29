//
//  LayerViewController.swift
//  Graph
//
//  Created by Fraser King on 2018-08-28.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import UIKit

private let reuseIdentifier = "LayerCell"

class LayerViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        collectionView.register(UINib(nibName: "LevelLayerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.layer.masksToBounds = false
        collectionView.alpha = 0
        
        GraphAnimation.delayWithSeconds(0.2) {
            UIView.animate(withDuration: 1) {
                self.collectionView.alpha = 1
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func settingsPressed() {
        print("settingsPressed")
    }
    
    @IBAction func layerPressed() {
        UIView.animate(withDuration: 0.5, animations: {
            self.collectionView.alpha = 0
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
        return CGSize(width: 235, height: 235)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LevelLayerCollectionViewCell
        cell.backgroundColor = UIColor.white
    
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
