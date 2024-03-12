//
//  sturdy_hand_trackingApp.swift
//  sturdy-hand-tracking
//
//  Created by 三宅武将 on 2024/03/12.
//

import SwiftUI

@main
struct sturdy_hand_trackingApp: App {
    @State private var viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environment(ViewModel())
        }
    }
}
