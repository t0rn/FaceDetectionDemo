//
//  AVCaptureDevice.DiscoverySession+DefaultVideo.swift
//  FaceDetectionDemo
//
//  Created by Alexey Ivanov on 8/2/24.
//

import AVFoundation

extension AVCaptureDevice.DiscoverySession {
    enum VideoDeviceDiscoveryError: Error, LocalizedError {
        case videoDeviceNotFound
        
        var errorDescription: String? {
            switch self {
            case .videoDeviceNotFound:
                String.localizedStringWithFormat("Video device not found. Are you running on a simulator?")
            }
        }
    }
    
    class func defaultVideoDevice(position: AVCaptureDevice.Position) throws -> AVCaptureDevice {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position)
        
        if let firstDevice = session.devices.first {
            return firstDevice
        }
        
        if let defaultDevice = AVCaptureDevice.default(for: .video) {
            return defaultDevice
        }
        
        throw VideoDeviceDiscoveryError.videoDeviceNotFound
    }
}
