//
//  QRScanner.swift
//  Authenticator
//
//  Created by Alexey Galaev on 11/24/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import AVFoundation

protocol QRScannerDelegate: class {
    func handleDecodedText(text: String)
    func handleError(error: Error)
}

class QRScanner: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: QRScannerDelegate?
    private let serialQueue = DispatchQueue(label: "QRScannerSerialQueue")

    private lazy var captureSession: AVCaptureSession? = {
        do {
            return try QRScanner.createCaptureSessionWithDelegate(delegate: self)
        } catch {
            DispatchQueue.main.async {
                self.delegate?.handleError(error: error)
            }
            return nil
        }
    }()

    func start(completion:@escaping (AVCaptureSession?) -> ()) {
        serialQueue.async {
            self.captureSession?.startRunning()
            DispatchQueue.main.async {
                completion(self.captureSession)
            }
        }
    }

    func stop() {
        serialQueue.async {
            print(self.serialQueue)
            self.delegate = nil
            self.captureSession?.stopRunning()
        }
    }
    // MARK: Capture
    enum CaptureSessionError: Error {
        case InputError
        case OutputError
    }

    private class func createCaptureSessionWithDelegate(delegate: AVCaptureMetadataOutputObjectsDelegate) throws -> AVCaptureSession {
        let captureSession = AVCaptureSession()

        guard let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo),
            let captureInput = try? AVCaptureDeviceInput(device: captureDevice) else {
                throw CaptureSessionError.InputError
        }
        captureSession.addInput(captureInput)

        let captureOutput = AVCaptureMetadataOutput()
        // The output must be added to the session before it can be checked for metadata types
        captureSession.addOutput(captureOutput)
        guard let availableTypes = captureOutput.availableMetadataObjectTypes, (availableTypes as NSArray).contains(AVMetadataObjectTypeQRCode) else {
                throw CaptureSessionError.OutputError
        }
        captureOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        captureOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)

        return captureSession
    }

    class var deviceCanScan: Bool {
        return (AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) != nil)
    }

    // MARK: AVCaptureMetadataOutputObjectsDelegate
  
    internal func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        guard let metadataObjects = metadataObjects else {
            return
        }
        
        for metadata in metadataObjects {
            if let metadata = metadata as? AVMetadataMachineReadableCodeObject, metadata.type == AVMetadataObjectTypeQRCode,
                let string = metadata.stringValue {
                // Dispatch to the main queue because setMetadataObjectsDelegate doesn't
                DispatchQueue.main.async {
                    self.delegate?.handleDecodedText(text: string)
                }
            }
        }
    }
}
