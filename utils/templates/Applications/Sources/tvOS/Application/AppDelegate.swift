//
//  AppDelegate.swift
//  KN_TEMPLATE_TVOS_NAME
//
//  Created by Jonathan Lee on 6/16/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = NavigationController(rootViewController: TableViewController())
        window?.makeKeyAndVisible()
        return true
    }
}
