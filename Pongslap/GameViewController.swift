//
//  GameViewController.swift
//  Pongslap
//
//  Created by Mateo Marin on 3/16/16.
//  Copyright (c) 2016 Mateo Marin. All rights reserved.
//
//
//  GameViewController.swift
//  Pongo II
//
//  Created by Mateo Marin on 3/15/16.
//  Copyright (c) 2016 Mateo Marin. All rights reserved.
//

import UIKit
import SpriteKit
import iAd

class GameViewController: UIViewController, ADBannerViewDelegate {
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.view)
        
        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            self.canDisplayBannerAds = false
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            var scene2 = scene as GameSceneDelegate
            scene2.controller = self
            
            
            skView.presentScene(scene)
        }
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        print("success")
        self.view.addSubview(banner) //Add banner to view (Ad loaded)
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError
        error: NSError!) {
            print("failed to load ad")
            banner.removeFromSuperview() //Remove the banner (No ad)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

