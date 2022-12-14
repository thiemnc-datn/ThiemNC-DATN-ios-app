//
//  QRCodeScannerViewController.swift
//  datn-app
//
//  Created by ThiemJason on 12/11/22.
//  Copyright © 2022 VNPT Technology. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRCodeScannerViewControllerDelegte: NSObjectProtocol {
    func qrScanResponse(_ value: String?)
}

class QRCodeScannerViewController: UIViewController {
    
    @IBOutlet weak var vQRCodescanner   : UIView!
    
    var captureSession                  = AVCaptureSession()
    var videoPreviewLayer               : AVCaptureVideoPreviewLayer?
    var qrCodeFrameView                 : UIView?
    weak var delegate                   : QRCodeScannerViewControllerDelegte?
    
    deinit {
        print("QRCodeScannerViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .white;
        
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInDualWideCamera, .builtInTelephotoCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            self.delegate?.qrScanResponse(nil)
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            self.captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            self.captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.videoPreviewLayer?.videoGravity        = .resizeAspectFill
            self.videoPreviewLayer?.frame               = self.vQRCodescanner.bounds
            
            // Initialize QR Code Frame to highlight the QR code
            self.qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = self.qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
            if let videoPreviewLayer = self.videoPreviewLayer {
                self.vQRCodescanner.layer.insertSublayer(videoPreviewLayer, at: 0)
            }
            // Start video capture.
            self.captureSession.startRunning()
            
        } catch {
            self.delegate?.qrScanResponse(nil)
            self.navigationController?.popViewController(animated: true)
            return
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("Layout subview")
        self.videoPreviewLayer?.frame               = self.vQRCodescanner.bounds
    }
}

extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            self.qrCodeFrameView?.frame = CGRect.zero
            self.delegate?.qrScanResponse(nil)
            return
        }
        
        // Get the metadata object.
        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else { return }
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            guard let barCodeObject = self.videoPreviewLayer?.transformedMetadataObject(for: metadataObj) else { return }
            self.qrCodeFrameView?.frame = barCodeObject.bounds
            
            if metadataObj.stringValue != nil {
                self.captureSession.stopRunning()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.qrScanResponse(metadataObj.stringValue)
                }
            }
        }
    }
}
