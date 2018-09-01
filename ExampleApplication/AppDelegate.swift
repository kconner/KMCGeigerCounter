//
//  AppDelegate.swift
//  ExampleApplication
//
//  Created by Kevin Conner on 9/1/18.
//  Copyright © 2018 Kevin Conner. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        KMCGeigerCounter.shared().isEnabled = true

        return true
    }

}
