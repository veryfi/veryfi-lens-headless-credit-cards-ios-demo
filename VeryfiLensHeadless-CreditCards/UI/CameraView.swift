//
//  CameraView.swift
//  Veryfi-Lens
//
//  Created by Alex Levnikov on 4/4/22.
//  Copyright © 2022 Veryfi. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewDelegate: AnyObject {
    func cameraView(_ cameraView: CameraView, didCapture frame: CMSampleBuffer)
    func cameraView(_ cameraView: CameraView, didFail error: String)
}

class CameraView: UIView {
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    private let sessionQueue = DispatchQueue(label: "session queue")
    private var setupResult: SessionSetupResult = .success
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    private var shapeLayer: CAShapeLayer?
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    weak var delegate: CameraViewDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.previewLayer.frame = self.bounds
    }
    
    func configure() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer.frame = self.bounds
        self.layer.insertSublayer(self.previewLayer, at: 0)
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
            
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
        default:
            setupResult = .notAuthorized
        }
        
        sessionQueue.async { [weak self] in
            self?.configureSession()
        }
    }
    
    func startSession() {
        shapeLayer?.removeFromSuperlayer()
        
        shapeLayer = CAShapeLayer()
        self.layer.addSublayer(shapeLayer!)
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async {
                    self.delegate?.cameraView(self, didFail: "LensDemo doesn't have permission to use the camera, please change privacy settings")
                }
                break
            case .configurationFailed:
                DispatchQueue.main.async {
                    self.delegate?.cameraView(self, didFail: "Camera is not available. Make sure the real device is used.")
                }
                break
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subjectAreaDidChange),
                                               name: .AVCaptureDeviceSubjectAreaDidChange,
                                               object: videoDeviceInput.device)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: session)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        
        print("Capture session runtime error: \(error)")
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                } else {
                    
                }
            }
        } else {
        }
    }
    
    private func configureSession() {
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        
        session.sessionPreset = .high
        
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                defaultVideoDevice = backCameraDevice
            }
            guard let videoDevice = defaultVideoDevice else {
                print("Default video device is unavailable.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                print("Couldn't add video device input to the session.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Couldn't create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.alwaysDiscardsLateVideoFrames = true
        dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA]
        dataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        
        if (session.canAddOutput(dataOutput)) {
            session.addOutput(dataOutput)
        } else {
            print("Couldn't add video data output to the session.")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        dataOutput.connections.first?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        session.commitConfiguration()
    }
    
    private func focus(with focusMode: AVCaptureDevice.FocusMode,
                       exposureMode: AVCaptureDevice.ExposureMode,
                       at devicePoint: CGPoint,
                       monitorSubjectAreaChange: Bool) {
        
        sessionQueue.async {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
}


extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
    
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}

extension CameraView: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.cameraView(self, didCapture: sampleBuffer)
    }
}
