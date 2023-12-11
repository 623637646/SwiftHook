//
//  ViewController.swift
//  SPMExample
//
//  Created by Wang Ya on 11/12/23.
//

import UIKit
import SwiftHook

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.title = "I am the title"
        hook()
        try! test_before_deinit()
    }

    func hook() {
        // hook
        do {
            try hookBefore(object: self, selector: #selector(UIViewController.viewDidAppear(_:)), closure: { viewController, _ in
                print("ViewController did appear")
                print("Title: \(viewController.title ?? "")")
            })
        } catch {
            assertionFailure()
        }
    }
    
    func test_before_deinit() throws {
        class MyObject: NSObject {
            static var isReleased = false
            deinit {
                MyObject.isReleased = true
            }
        }
        weak var reference: MyObject?
        var run = false
        try autoreleasepool {
            let obj = MyObject()
            reference = obj
            try hookDeallocBefore(object: obj) {
                run = true
            }
        }
        print("reference: \(String(describing: reference))")
        print("run: \(run)")
    }
}

