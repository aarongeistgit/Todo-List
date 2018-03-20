//
//  AppDelegate.swift
//  Todo List
//
//  Created by Aaron Geist on 3/5/18.
//  Copyright © 2018 Aaron Geist. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        do {
            _ = try Realm()
        } catch {
            print("Error creating Realm: \(error)")
        }
        
        
        return true
    }


}

