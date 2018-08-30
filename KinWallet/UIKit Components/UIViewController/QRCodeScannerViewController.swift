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
    func scannerDidFailWithPermissionsRejected()
    func scannerDidFail()
}

class QRCodeScannerViewController: UIViewController {
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: QRCodeScannerDelegate?
    var foundCode = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        requestPermissionsAndConfigureInput()
    }

    private func requestPermissionsAndConfigureInput() {
        if let session = captureSession {
            if session.isRunning {
                return
            }

            startIfNeeded()
        }

        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let `self` = self else {
                return
            }

            DispatchQueue.main.async {
                guard granted else {
                    self.delegate?.scannerDidFailWithPermissionsRejected()

                    return
                }

                self.configureCaptureSession()
            }
        }
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
        guard let session = captureSession else {
            return false
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: device)
        } catch {
            return false
        }

        guard session.canAddInput(videoInput) else {
            return false
        }

        session.addInput(videoInput)
        return true
    }

    private func configureOutput() -> Bool {
        guard let session = captureSession else {
            return false
        }

        let metadataOutput = AVCaptureMetadataOutput()

        guard session.canAddOutput(metadataOutput) else {
            return false
        }

        session.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        metadataOutput.metadataObjectTypes = [.qr]

        return true
    }

    private func configurePreview() {
        guard let session = captureSession, previewLayer == nil else {
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer!.frame = view.layer.bounds
        previewLayer!.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)

        startIfNeeded()
    }

    private func setupFailed() {
        delegate?.scannerDidFail()
    }

    func startIfNeeded() {
        foundCode = false

        guard let session = captureSession else {
            return
        }

        if !session.isRunning {
            session.startRunning()
        }
    }
}

extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard !foundCode, let session = captureSession else {
            return
        }

        session.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            foundCode = true
            FeedbackGenerator.notifySuccessIfAvailable()
            delegate?.scannerDidFind(code: stringValue)
        }
    }
}
