//
//  ViewModel.swift
//  sturdy-hand-tracking
//
//  Created by 三宅武将 on 2024/03/12.
//

import Foundation
import ARKit
import RealityKit
import RealityKitContent

@Observable class ViewModel {
    var globalEntity = Entity()
    var sphereEntity: ModelEntity?
    var audioPlaybackController: AudioPlaybackController?
    private var handTracking = HandTrackingProvider()
    private var session = ARKitSession()
    private var leftFingerIndexTipEntity = ModelEntity.createFinger()
    private var rightFingerIndexTipEntity = ModelEntity.createFinger()
    
    @MainActor
    func setup() async {
        globalEntity.addChild(leftFingerIndexTipEntity)
        globalEntity.addChild(rightFingerIndexTipEntity)
        do {
            if HandTrackingProvider.isSupported {
                try await session.run([handTracking])
            }
        } catch {
            
        }
    }
    
    @MainActor
    func publishHandTrackingUpdates() async {
        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .updated:
                let anchor = update.anchor
                guard anchor.isTracked,
                      let indexFingerTipJoint = anchor.handSkeleton?.joint(.indexFingerTip),
                      indexFingerTipJoint.isTracked
                else {
                    return
                }
                let originFromIndexFingerTip = anchor.originFromAnchorTransform * indexFingerTipJoint.anchorFromJointTransform
                
                if anchor.chirality == .left {
                    leftFingerIndexTipEntity.setTransformMatrix(originFromIndexFingerTip, relativeTo: nil)
                } else if anchor.chirality == .right {
                    rightFingerIndexTipEntity.setTransformMatrix(originFromIndexFingerTip, relativeTo: nil)
                }
                guard let sphereEntity else { continue }
                let distance = distance(anchor.originFromAnchorTransform.columns.3.xyz, sphereEntity.transform.translation)
                
                if distance < 0.5 {
                    guard let audioPlaybackController else { continue }
                    if !audioPlaybackController.isPlaying {
                        audioPlaybackController.play()
                    }
                }
            default:
                break
            }
        }
    }
}

extension SIMD4 {
    var xyz: SIMD3<Scalar> {
        self[SIMD3(0, 1, 2)]
    }
}

extension ModelEntity {
    class func createFinger() -> ModelEntity {
        let entity = ModelEntity(
            mesh: .generateSphere(radius: 0.005),
            materials: [UnlitMaterial(color: .cyan)],
            collisionShape: .generateSphere(radius: 0.005),
            mass: 0.0
        )
        entity.components.set(OpacityComponent(opacity: 1.0))
        return entity
    }
}
