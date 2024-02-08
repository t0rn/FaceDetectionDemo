//
//  AVCaptureVideoDataOutput+Init.swift
//  FaceDetectionDemo
//
//  Created by Alexey Ivanov on 8/2/24.
//

import AVFoundation

extension AVCaptureVideoDataOutput {
    //Create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured.
    //A serial dispatch queue must be used to guarantee that video frames will be delivered in order.
    convenience init(delegate: AVCaptureVideoDataOutputSampleBufferDelegate? = nil,
                     dispatchQueue: DispatchQueue = DispatchQueue(label: "com.alexey.ivanov.CaptureOutputQ"),
                     connectionMediaType: AVMediaType = .video) {
        self.init()
        self.alwaysDiscardsLateVideoFrames = true
        self.setSampleBufferDelegate(delegate, queue: dispatchQueue)
        let connection = connection(with: connectionMediaType)
        connection?.videoOrientation = .portrait
        connection?.isEnabled = true
        
        if let captureConnection = connection {
            if captureConnection.isCameraIntrinsicMatrixDeliverySupported {
                captureConnection.isCameraIntrinsicMatrixDeliveryEnabled = true
            }
        }
    }
}

