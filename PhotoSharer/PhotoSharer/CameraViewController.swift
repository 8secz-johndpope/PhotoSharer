//
//  CameraViewController.swift
//  PhotoSharer
//
//  Created by Serhii Ostrovetskyi on 8/23/19.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation



class CameraViewController: UIViewController {

    var session: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var previewView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(previewView)
        previewView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(view.frame.height / 2)
        }
        
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSession.Preset.photo
        let backCamera =  AVCaptureDevice.default(for: AVMediaType.video)
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera!)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        if error == nil && session!.canAddInput(input) {
            session!.addInput(input)
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey:  AVVideoCodecType.jpeg]
            if session!.canAddOutput(stillImageOutput!) {
                session!.addOutput(stillImageOutput!)
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session!)
                videoPreviewLayer!.videoGravity =    AVLayerVideoGravity.resizeAspect
                videoPreviewLayer!.connection?.videoOrientation =   AVCaptureVideoOrientation.portrait
                previewView.layer.addSublayer(videoPreviewLayer!)
                session!.startRunning()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoPreviewLayer!.frame = previewView.bounds
    }
}

