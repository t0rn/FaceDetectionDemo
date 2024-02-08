//
//  VideoCaptureService.swift
//  FaceDetectionDemo
//
//  Created by Alexey Ivanov on 7/2/24.
//

import Foundation
import AVFoundation
import Vision

final class VideoCaptureService: VideoCaptureServiceProtocol {
    enum Errors: Error {
        case restrictedPermission
    }
    
    weak var delegate: VideoCaptureServiceDelegate?
    
    private(set) var cameraPosition: CameraPosition
    private lazy var faceDetector: FaceDetector = {
        FaceDetector(devicePosition: .init(cameraPosition)) { [weak self] result in
            self?.handleFaceObservation(result: result)
        }
    }()
    private var session: AVCaptureSession?
    
    init(delegate: VideoCaptureServiceDelegate? = nil,
         cameraPosition: CameraPosition = .front) {
        self.delegate = delegate
        self.cameraPosition = cameraPosition
    }
    
    //MARK: VideoCaptureServiceProtocol
    func prepare() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            setupSession()
          
        case .notDetermined:
            requestAccess()
            
        case .denied, .restricted:
            failed(with: Errors.restrictedPermission)
        @unknown default:
            failed(with: Errors.restrictedPermission)
        }
    }
    func startCapture() {
        guard let session = session, !session.isRunning else { return }

        DispatchQueue.global(qos: .background).async {
            session.startRunning()
        }
    }
    
    func stopCapture() {
        DispatchQueue.global(qos: .background).async {
            guard let session = self.session, session.isRunning else { return }
            session.stopRunning()
        }
    }
    
    func toggleCamera() {
        let newPosition: CameraPosition
        switch cameraPosition {
        case .back:
            newPosition = .front
        case.front:
            newPosition = .back
        }
        change(cameraPosition: newPosition)
    }
    
    //MARK: Private
    
    fileprivate func requestAccess() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    self.setupSession()
                } else {
                    self.failed(with: Errors.restrictedPermission)
                }
            }
        }
    }
    
    fileprivate func setupSession() {
        let output = AVCaptureVideoDataOutput(delegate: faceDetector)
        let camera = AVCaptureDevice.Position(cameraPosition)
        do {
            let device = try AVCaptureDevice.DiscoverySession.defaultVideoDevice(position: camera)
            let session = try AVCaptureSession(device: device, captureOutput: output)
            self.session = session
            ready(with: session)
        }
        catch {
            failed(with: error)
            session = nil
        }
    }
    
    fileprivate func handleFaceObservation(result: Result<[VNFaceObservation], Error>) {
        switch result {
        case .success(let observations):
            DispatchQueue.main.async {
                self.delegate?.facesWith(boundingBoxes: observations.map(\.boundingBox))
            }
        case .failure(let error):
            //don't delegate observation errors to a View layer
            //TODO: log error?
            print(error)
        }
    }
    
    fileprivate func ready(with session: AVCaptureSession) {
        DispatchQueue.main.async {
            self.delegate?.ready(with: session)
        }
        startCapture()
    }
    
    fileprivate func failed(with error: Error) {
        DispatchQueue.main.async {
            self.delegate?.showError(error: error)
        }
    }
    
    fileprivate func change(cameraPosition: CameraPosition) {
        guard cameraPosition != self.cameraPosition else { return }
        DispatchQueue.global(qos: .background).async {
            guard let session = self.session else { return }
            
            session.inputs.forEach { input in
                session.removeInput(input)
            }
            session.beginConfiguration()
            do {
                let camera = AVCaptureDevice.Position(cameraPosition)
                let device = try AVCaptureDevice.DiscoverySession.defaultVideoDevice(position: camera)
                let videoDeviceInput = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(videoDeviceInput) {
                    session.addInput(videoDeviceInput)
                    self.cameraPosition = cameraPosition
                    self.faceDetector.devicePosition = .init(cameraPosition)
                }
            } catch {
                self.failed(with: error)
            }
            session.commitConfiguration()
        }
        startCapture()
    }
}
