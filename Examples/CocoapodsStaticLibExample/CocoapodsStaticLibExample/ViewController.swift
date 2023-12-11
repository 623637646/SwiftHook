//
//  ViewController.swift
//  CocoapodsStaticLibExample
//
//  Created by Wang Ya on 9/12/23.
//

import UIKit
import EasySwiftHook

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.title = "I am the title"
        hook()
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


}

