//
//  AVCaptureDevice+Lookup.swift
//  FaceDetectionDemo
//
//  Created by Alexey Ivanov on 8/2/24.
//

import AVFoundation

extension AVCaptureDevice {
    func highestFormatResolution(mediaSubType: OSType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) -> (format: AVCaptureDevice.Format, resolution: CGSize)? {
        formats
            .compactMap { format -> (format: AVCaptureDevice.Format, formatDescription: CMFormatDescription)? in
                let formatDescription = format.formatDescription
                guard CMFormatDescriptionGetMediaSubType(formatDescription) == mediaSubType else {
                    return nil
                }
                return (format, formatDescription)
            }
            .max { left, right in
                return CMVideoFormatDescriptionGetDimensions(left.formatDescription).width < CMVideoFormatDescriptionGetDimensions(right.formatDescription).width
            }
            .map { (format, formatDescription) in
                let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
                let resolution = CGSize(width: CGFloat(dimensions.width), height: CGFloat(dimensions.height))
                return (format, resolution)
            }
    }
}

