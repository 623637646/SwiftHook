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
        
        self.testCode()
        
        return true
    }
    
    // MARK: Test Code. -
    
    func testCode() {
        try! hookAfter(object: self, selector: #selector(AppDelegate.test), closure: {_, _, b, b2, s in
            print("")
        } as @convention(block) (NSObject, Selector, UnsafePointer<Bool>?, Bool, MyStruct) -> Void)
        
        self.test(bool: nil, b2:true, b3: MyStruct.init(b: true))
    }
     
    @objc dynamic func test(bool: UnsafePointer<Bool>?, b2: Bool, b3: MyStruct) {
        print("")
    }

}
