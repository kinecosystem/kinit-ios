//
//  QRCodeScannerViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRCodeScannerDelegate: class {
    func scannerDidFind(code: String)
    func scannerDidFail()
}

class QRCodeScannerViewController: UIViewController {
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: QRCodeScannerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCaptureSession()
    }

    private func configureCaptureSession() {
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            setupFailed()
            return
        }

        guard configureInput(with: videoCaptureDevice) else {
            setupFailed()
            return
        }

        guard configureOutput() else {
            setupFailed()
            return
        }

        configurePreview()
    }

    private func configureInput(with device: AVCaptureDevice) -> Bool {
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: device)
        } catch {
            return false
        }

        guard captureSession.canAddInput(videoInput) else {
            return false
        }

        captureSession.addInput(videoInput)
        return true
    }

    private func configureOutput() -> Bool {
        let metadataOutput = AVCaptureMetadataOutput()

        guard captureSession.canAddOutput(metadataOutput) else {
            return false
        }

        captureSession.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        metadataOutput.metadataObjectTypes = [.qr]

        return true
    }

    private func configurePreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        start()
    }

    private func setupFailed() {
        delegate?.scannerDidFail()
    }

    func start() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
}

extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.scannerDidFind(code: stringValue)
        }
    }
}
