//
//  ContentView.swift
//  SPMExample
//
//  Created by Wang Ya on 31/12/23.
//

import SwiftUI
import SwiftHook

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
            Text("Hello, world!")
        }
        .padding()
        .onAppear(perform: {
            hook()
        })
    }
    
    func hook() {
        class MyObject {
            @objc dynamic func test() {
                print("test is called")
            }
        }
        let obj = MyObject()
        // hook
        do {
            try ObjectHook(obj).hookBefore(#selector(MyObject.test), closure: { viewController, _ in
                print("hooked")
            })
        } catch {
            assertionFailure()
        }
        obj.test()
    }
}

#Preview {
    ContentView()
}
