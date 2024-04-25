//
//  SplineViewWrapper.swift
//  StepVision
//
//  Created by Adwait Relekar on 4/9/24.
//  Copyright © 2024 Snap. All rights reserved.
//

import SplineRuntime
import SwiftUI

struct ContentView: View {
    var body: some View {
        // fetching from cloud
        let url = URL(string: "https://build.spline.design/X9CupgrDK5siQWpJMQAx/scene.splineswift")!

        // // fetching from local
        // let url = Bundle.main.url(forResource: "scene", withExtension: "splineswift")!

        try? SplineView(sceneFileURL: url).ignoresSafeArea(.all)
    }
}



