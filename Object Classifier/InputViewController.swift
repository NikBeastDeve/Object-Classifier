//
//  InputViewController.swift
//  Object Classifier
//
//  Created by Nikita Galaganov on 28.02.2020.
//  Copyright © 2020 Nikita Galaganov. All rights reserved.
//

import AVFoundation
import UIKit
import SwiftUI
import CoreML
import Vision

final class InputViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    /*
     SINCE FOR SOME MYSTERY REASON ENVIROMENT OBJ
     DOESNT WORK ILL USE THE DUMBEST SOLUTION
     POSSIBLE FOR EXCANGING DATA
    */
    
    //@EnvironmentObject var envData: EnviromentData
    
    var info: String = ""
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    let screenSize:CGRect = UIScreen.main.bounds
    
    //typealias obsReturn = (_ observation: VNClassificationObservation) ->()
    //typealias obsReturn = (_ observation: VNClassificationObservation) -> Void
    var obsReturn: (VNClassificationObservation) -> (VNClassificationObservation) = { observation in
        return observation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        view.frame.size.height = screenSize.height
        view.frame.size.width = screenSize.width
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean13, .code128]

        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //previewLayer.frame = view.layer.bounds
        previewLayer.frame = CGRect(x: 0, y: 50, width: screenSize.width, height: screenSize.height - 50)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.cornerRadius = 40
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()

        let button:UIButton = UIButton(frame: CGRect(x: 20, y: screenSize.height - 120, width: 100, height: 100))
        button.setTitle("⚡", for: .normal)
        button.titleLabel?.font = button.titleLabel?.font.withSize(40)
        button.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
        //let boltImage = UIImage(named: "bolt")
        //button.setImage(boltImage, for: .normal)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width // add the round corners in proportion to the button size

        let blur = UIVisualEffectView(effect: UIBlurEffect(style:
            UIBlurEffect.Style.dark))
        blur.frame = button.bounds
        blur.isUserInteractionEnabled = false //This allows touches to forward to the button.
        blur.layer.cornerRadius = 0.5 * button.bounds.size.width
        blur.clipsToBounds = true
        button.insertSubview(blur, at: 0)
        
        view.addSubview(button)
        
        //_____________________________________________________________________________________________________________
        //VISION RECOGNISION CODE
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoQuene"))
        captureSession.addOutput(dataOutput)
        
        //_____________________________________________________________________________________________________________
    }
    
    @objc func buttonClicked() {
        toggleFlash()
    }
    
//_____________________________________________________________________________________________________________
    //VISION RECOGNISION CODE
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //print("Camera captured output: ", Date())
        //CMSamleBufferGetImageBuffer
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
        let request = VNCoreMLRequest(model: model)
        {   (finishedReq, err) in
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            guard let firstObservations: VNClassificationObservation = results.first else { return }
            DataWriter().setObj(object: firstObservations)
            self.info = String(firstObservations.identifier) + "\n" + String(firstObservations.confidence)
            print(self.info)
            
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

    //_____________________________________________________________________________________________________________
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

        dismiss(animated: true)
    }

    func found(code: String) {
        print(code)
    }
}

extension InputViewController: UIViewControllerRepresentable {

    public typealias UIViewControllerType = InputViewController

    func makeUIViewController(context: UIViewControllerRepresentableContext<InputViewController>) -> InputViewController {
        
        return InputViewController()
    }
    
    func updateUIViewController(_ uiViewController: InputViewController, context: UIViewControllerRepresentableContext<InputViewController>) {
        
    }
    
    func toggleFlash() {
        let device = AVCaptureDevice.default(for: AVMediaType.video)!
        if (device.hasTorch) {
             do {
                 try device.lockForConfiguration()
                if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                    device.torchMode = AVCaptureDevice.TorchMode.off
                 } else {
                     do {
                        try device.setTorchModeOn(level: 1.0)
                     } catch {
                         print(error)
                     }
                 }
                 device.unlockForConfiguration()
             } catch {
                 print(error)
             }
         }
     }
    
}

