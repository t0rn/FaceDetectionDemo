//
//  AVCaptureDevice.Position+CameraPosition.swift
//  FaceDetectionDemo
//
//  Created by Alexey Ivanov on 8/2/24.
//

import Foundation
import AVFoundation

extension AVCaptureDevice.Position {
    init(_ position: CameraPosition) {
        switch position {
        case .front:
            self = .front
        case .back:
            self = .back
        }
    }
}
