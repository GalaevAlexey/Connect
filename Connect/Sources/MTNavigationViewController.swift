//
//  MTNavigationViewController.swift
//  Connect
//
//  Created by Alexey Galaev on 11/17/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import UIKit

class MTNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let transition = CATransition()
        
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.layer.add(transition, forKey: kCATransition)
        super.pushViewController(viewController, animated: true)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let transition = CATransition()
        
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.layer.add(transition, forKey: kCATransition)
         return super.popViewController(animated: true)
        
    }
    
}
