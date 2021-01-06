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
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow.init(frame: UIScreen.main.bounds)
        window.rootViewController = ViewController.init()
        window.makeKeyAndVisible()
        self.window = window
        
        // hook
        do {
            try hookBefore(targetClass: UIViewController.self, selector: #selector(UIViewController.viewDidAppear(_:)), closure: { viewController, _, _ in
                print("UIViewController did appear")
                print("Title: \(viewController.title ?? "")")
            } as @convention(block) (UIViewController, Selector, Bool) -> Void)
        } catch {}
        
        return true
    }

}
