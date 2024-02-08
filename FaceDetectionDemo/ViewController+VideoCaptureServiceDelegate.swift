//
//  ViewController+VideoCaptureServiceDelegate.swift
//  FaceDetectionDemo
//
//  Created by Alexey Ivanov on 8/2/24.
//

import UIKit
import AVFoundation

extension ViewController: VideoCaptureServiceDelegate {
    func ready(with session: AVCaptureSession) {
        previewView.previewLayer.session = session
    }
    
    func showError(error: Error) {
        let alert = UIAlertController(title: "Error",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(closeAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
        previewView.previewLayer.session = nil
    }
    
    func facesWith(boundingBoxes: [CGRect]) {
        previewView.removeMask()
        boundingBoxes.forEach { box in
            self.previewView.drawFace(boundingBox: box)
        }
    }
}
