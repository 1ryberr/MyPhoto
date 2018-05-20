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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
   
    func applicationWillTerminate(_ application: UIApplication) {
        stack.saveContext()
    }
    
}

