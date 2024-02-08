//
//  FaceDetector.swift
//  FaceDetectionDemo
//
//  Created by Alexey Ivanov on 8/2/24.
//

import UIKit
import AVFoundation
import Vision

final class FaceDetector: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    typealias ObservationHandler = ((Result<[VNFaceObservation], Error>) -> Void)
    
    var devicePosition: AVCaptureDevice.Position
    
    private var detectionRequests: [VNRequest]
    
    init(devicePosition: AVCaptureDevice.Position,
         observationHandler: @escaping ObservationHandler) {
        self.devicePosition = devicePosition
        let request = VNDetectFaceRectanglesRequest(completionHandler: { (request, error) in
            if let error = error {
                observationHandler(.failure(error))
                return
            }
            let results = request.results as? [VNFaceObservation] ?? []
            observationHandler(.success(results))
        })
        self.detectionRequests = [request]
        super.init()
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let exifOrientation = CGImagePropertyOrientation(rawValue: exifOrientationFromDeviceOrientation(devicePosition: devicePosition)) else { return }
        var requestOptions: [VNImageOption : Any] = [:]
        
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics : cameraIntrinsicData]
        }
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: requestOptions)
        do {
            try imageRequestHandler.perform(detectionRequests)
        }
        catch {
            //TODO: should we handle observation error?
            print(error)
        }
    }
    
    private func exifOrientationFromDeviceOrientation(devicePosition: AVCaptureDevice.Position) -> UInt32 {
        enum DeviceOrientation: UInt32 {
            case top0ColLeft = 1
            case top0ColRight = 2
            case bottom0ColRight = 3
            case bottom0ColLeft = 4
            case left0ColTop = 5
            case right0ColTop = 6
            case right0ColBottom = 7
            case left0ColBottom = 8
        }
        var exifOrientation: DeviceOrientation
        
        switch UIDevice.current.orientation {
        case .portraitUpsideDown:
            exifOrientation = .left0ColBottom
        case .landscapeLeft:
            exifOrientation = devicePosition == .front ? .bottom0ColRight : .top0ColLeft
        case .landscapeRight:
            exifOrientation = devicePosition == .front ? .top0ColLeft : .bottom0ColRight
        default:
            exifOrientation = devicePosition == .front ? .left0ColTop : .right0ColTop
        }
        return exifOrientation.rawValue
    }
}
