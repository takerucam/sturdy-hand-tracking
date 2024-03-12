//
//  ImmersiveView.swift
//  sturdy-hand-tracking
//
//  Created by 三宅武将 on 2024/03/12.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Environment(ViewModel.self) private var viewModel
    
    var body: some View {
        RealityView { content in
            content.add(viewModel.globalEntity)
            if let scene = try? await Entity(named: "Immersive", in: realityKitContentBundle),
               let sphere = scene.findEntity(named: "Sphere_Left") as? ModelEntity
            {
                viewModel.sphereEntity = sphere
                content.add(sphere)
                
                guard let audioEntity = scene.findEntity(named: "SpatialAudio"),
                      let resource = try? await AudioFileResource(named: "/Root/sound_mp3", from: "Immersive.usda", in: realityKitContentBundle)
                else { return }
                viewModel.audioPlaybackController = audioEntity.prepareAudio(resource)
            }
        }
        .task {
            await viewModel.setup()
        }
        .task {
            await viewModel.publishHandTrackingUpdates()
        }
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
        .environment(ViewModel())
}
