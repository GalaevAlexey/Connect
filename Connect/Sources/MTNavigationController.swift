//
//  RootController.swift
//  Connect
//
//  Created by Alexey Galaev on 11/30/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import Foundation
import UIKit
import OneTimePassword


class MTNavigationController:UINavigationController {
    
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
