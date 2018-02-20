//
//  LandingViewController.swift
//  Graph
//
//  Created by Fraser King on 2018-02-20.
//  Copyright © 2018 Fraser King. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {

    @IBOutlet var background: UIImageView!
    @IBOutlet var lines: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        background.addParallaxToView(amount: 10)
        lines.addParallaxToView(amount: 20)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
