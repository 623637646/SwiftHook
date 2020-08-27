//
//  AppDelegate.swift
//  SwiftHookDemo
//
//  Created by Yanni Wang on 3/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import UIKit
import EasySwiftHook

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // hook
        do {
            try hookBefore(targetClass: UIViewController.self, selector: #selector(UIViewController.viewDidAppear(_:)), closure: { viewController, _, _ in
                print("UIViewController did appear")
                print("Title: \(viewController.title ?? "")")
            } as @convention(block) (UIViewController, Selector, Bool) -> Void)
        } catch {}
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}
