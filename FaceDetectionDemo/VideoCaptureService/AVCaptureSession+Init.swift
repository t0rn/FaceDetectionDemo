//
//  AVCaptureSession+Init.swift
//  FaceDetectionDemo
//
//  Created by Alexey Ivanov on 8/2/24.
//

import AVFoundation

extension AVCaptureSession {
    enum InitErrors: Error {
        case invalidDeviceInput
    }
    
    convenience init(device: AVCaptureDevice,
                     captureOutput: AVCaptureVideoDataOutput) throws {
        self.init()
        do {
            let deviceInput = try AVCaptureDeviceInput(device: device)
            guard self.canAddInput(deviceInput) else {
                throw InitErrors.invalidDeviceInput
            }
            self.addInput(deviceInput)
            
            if let highestResolution = device.highestFormatResolution() {
                try device.lockForConfiguration()
                device.activeFormat = highestResolution.format
                device.unlockForConfiguration()
            }
            guard canAddOutput(captureOutput) else {
                throw InitErrors.invalidDeviceInput
            }
            addOutput(captureOutput)
        }
    }
}

