//
//  ViewController.swift
//  FaceDetectionDemo
//
//  Created by Alexey Ivanov on 7/2/24.
//

import UIKit

class ViewController: UIViewController {
    let service: VideoCaptureServiceProtocol
    
    private(set) lazy var previewView: PreviewView = {
        let view = PreviewView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }()
    
    private(set) lazy var cameraButton: UIButton = {
        let action = UIAction { [weak self] _ in
            self?.cameraButtonPressed()
        }
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Toggle camera"
        let button = UIButton(configuration: configuration, primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func loadView() {
        let contentView = UIView()
        contentView.addSubview(previewView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: previewView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: previewView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: previewView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: previewView.bottomAnchor, constant: -20)
        ])
        contentView.addSubview(cameraButton)
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: cameraButton.centerXAnchor),
            contentView.bottomAnchor.constraint(equalTo: cameraButton.bottomAnchor, constant: 70)
        ])
        self.view = contentView
    }
    
    init(service: VideoCaptureServiceProtocol) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
        service.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Deprecated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        service.prepare()
    }
    
    func cameraButtonPressed() {
        service.toggleCamera()
    }
}
