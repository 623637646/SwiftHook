//
//  ViewController.swift
//  MacCocoapodsStaticExample
//
//  Created by Wang Ya on 31/12/23.
//

import Cocoa
import EasySwiftHook

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "I am the title"
        hook()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func hook() {
        // hook
        do {
            try ObjectHook(self).hookBefore(#selector(NSViewController.viewDidAppear), closure: { viewController, _ in
                print("ViewController did appear")
                print("Title: \(viewController.title ?? "")")
            })
        } catch {
            assertionFailure()
        }
    }

}


