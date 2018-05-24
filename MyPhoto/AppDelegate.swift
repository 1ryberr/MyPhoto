//
//  AppDelegate.swift
//  MyPhoto
//
//  Created by Ryan Berry on 4/27/18.
//  Copyright © 2018 Ryan Berry. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var stack = CoreDataStack()
     var orientationLock = UIInterfaceOrientationMask.all
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
   
    func applicationWillTerminate(_ application: UIApplication) {
        stack.saveContext()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
        
    }
    

}

