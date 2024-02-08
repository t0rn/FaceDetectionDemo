//
//  VideoCaptureServiceProtocol.swift
//  FaceDetectionDemo
//
//  Created by Alexey Ivanov on 8/2/24.
//

import Foundation
import AVFoundation

protocol VideoCaptureServiceDelegate: AnyObject {
    func ready(with session: AVCaptureSession)
    func facesWith(boundingBoxes: [CGRect])
    func showError(error: Error)
}

protocol VideoCaptureServiceProtocol: AnyObject {
    var delegate: VideoCaptureServiceDelegate? {get set}

    func prepare()
    func startCapture()
    func stopCapture()
    func toggleCamera()
}

