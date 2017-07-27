//
//  AppDelegate.swift
//  Connect
//
//  Created by Alexey Galaev on 11/9/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    private let window = UIWindow(frame: UIScreen.main.bounds)
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupAppearance()
        setupLaunchScreen()
        Fabric.with([Crashlytics.self])
        return true
    }
    
    func setupLaunchScreen() {
        
        let firstRun = isFirstRun()
       
        let story = UIStoryboard(name:"MainStoryBoard", bundle: nil)
    
        let  loginVC = story.instantiateViewController(withIdentifier: "LoginViewController") as! MTLoginViewController
     
        let  singinViewControler = story.instantiateViewController(withIdentifier: "singinViewControler") as! MTSinginViewController
            singinViewControler.title = "Register".localized
        let navController = UINavigationController(rootViewController:firstRun ? loginVC : singinViewControler)
        
        window.rootViewController = navController
        window.makeKeyAndVisible()
        
        if(!firstRun) {
            keychain.delete(Keys.persistentKey)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }
    
    func isFirstRun() -> Bool {
        return     UserDefaults.standard.bool(forKey: Keys.firstRunKey)
    }
}




