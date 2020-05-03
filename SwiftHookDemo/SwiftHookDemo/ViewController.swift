//
//  ViewController.swift
//  SwiftHookDemo
//
//  Created by Yanni Wang on 3/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import UIKit
import SwiftHook

class ViewController: UIViewController {
    
    var context: HookContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            context = try ViewController.hookBefore(selector: #selector(ViewController.viewWillAppear(_:))) {
                print("viewWillAppear")
            }
        } catch SwiftHookError.noRespondSelector(class: let c, selector: let s) {
            print("\(c)  \(s)")
        } catch {
            print("\(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        context?.cancelHook()
    }
}
