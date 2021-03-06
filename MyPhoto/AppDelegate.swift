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
    private var stack = CoreDataStack()
    private var orientationLock = UIInterfaceOrientationMask.all
    
    func setOrientation(orientation: UIInterfaceOrientationMask){
        self.orientationLock = orientation
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
   
    func applicationWillTerminate(_ application: UIApplication) {
        stack.saveContext()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
        
    }
    

}

