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



class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    var captureSession = AVCaptureSession()
    var cameraOutput = AVCapturePhotoOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var currentImage: (image: Data, imageName: String)?
    
    var previewing = false
    var highResolutionEnabled = true
    var rawEnabled = false
    var flashMode = AVCaptureDevice.FlashMode.off
    var cameraPosition = AVCaptureDevice.Position.back
    let cameraButton = UIButton()
    let rotateButton = UIButton()
    let zoomInButton = UIButton()
    let zoomOutButton = UIButton()
    let previewView = UIView()
    
    
    let backDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
    
    let frontDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
    
    var currentDevice: AVCaptureDevice!
    
    var scale: CGFloat = 1
    
    //MARK: - UIViewController
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraButton.addTarget(self, action: #selector(makeSnapshot), for: .touchUpInside)
        
        view.addSubview(previewView)
        previewView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
                make.bottom.equalTo(bottomLayoutGuide.snp.top)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        view.addSubview(cameraButton)
        cameraButton.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            } else {
                make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-20)
            }
            make.centerX.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        
        cameraButton.layer.cornerRadius = 30
        cameraButton.layer.masksToBounds = true
        
        cameraButton.layer.borderWidth = 5
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.backgroundColor = .lightGray
        
        rotateButton.setImage(UIImage(named: "rotate"), for: .normal)
        rotateButton.addTarget(self, action: #selector(rotateButtonTap), for: .touchUpInside)
        
        view.addSubview(rotateButton)
        rotateButton.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.width.equalTo(40)
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalTo(cameraButton)
        }
        
        zoomInButton.setImage(UIImage(named: "zoomIn"), for: .normal)
        zoomInButton.addTarget(self, action: #selector(zoomInTap), for: .touchUpInside)
        
        view.addSubview(zoomInButton)
        zoomInButton.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.width.equalTo(40)
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalTo(cameraButton)
        }
        
        zoomOutButton.setImage(UIImage(named: "zoomOut"), for: .normal)
        zoomOutButton.addTarget(self, action: #selector(zoomOutTap), for: .touchUpInside)
        
        view.addSubview(zoomOutButton)
        zoomOutButton.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.width.equalTo(40)
            make.trailing.equalTo(zoomInButton.snp.leading).offset(-10)
            make.centerY.equalTo(cameraButton)
        }
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPreview()
    }
    
    
    // MARK: - Action
    
    func loadPreview() {
        
        guard frontDevice != nil || backDevice != nil else {
            showBackAlert()
            return
        }
        
        if cameraPosition == .back {
            if backDevice != nil {
                currentDevice = backDevice
            } else {
                showCameraAlert(cameraPosition)
                cameraPosition = .front
                currentDevice = frontDevice
            }
        } else {
            if frontDevice != nil {
                currentDevice = frontDevice
            } else {
                showCameraAlert(cameraPosition)
                cameraPosition = .back
                currentDevice = backDevice
            }
        }
        
        if let preInput = captureSession.inputs.first {
            captureSession.removeInput(preInput)
            print("remove")
        }
        
        if let input = try? AVCaptureDeviceInput(device: currentDevice) {
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                if (captureSession.canAddOutput(cameraOutput)) {
                    
                    cameraOutput.isHighResolutionCaptureEnabled = self.highResolutionEnabled
                    captureSession.addOutput(cameraOutput)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer.frame = previewView.bounds
                    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    previewView.clipsToBounds = true
                    previewView.layer.addSublayer(previewLayer)
                    captureSession.startRunning()
                }
            } else {
                print("Cannot add output")
            }
        }
    }
    
    @objc func rotateButtonTap() {
        if cameraPosition == .back {
            cameraPosition = .front
        } else {
            cameraPosition = .back
        }
        loadPreview()
    }
    
    func changeScaleTo(_ scale: CGFloat) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.01)
        previewLayer.setAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
        CATransaction.commit()
        
        
        do {
            try currentDevice.lockForConfiguration()
            currentDevice.videoZoomFactor = scale
            currentDevice.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    @objc func zoomInTap() {
        guard scale < 4 else {
            return
        }
        scale += 0.25
        changeScaleTo(scale)
    }
    
    @objc func zoomOutTap() {
        guard scale > 1 else {
            return
        }
        scale -= 0.25
        changeScaleTo(scale)
    }
    
    @objc func makeSnapshot() {
        print("_____")
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func backToImagePicker() {
        if let parentTabBar = parent as? TabBarViewController {
            if let imagePickerIndex = parentTabBar.viewControllers?.firstIndex(of: parentTabBar.imagePickerVC) {
                parentTabBar.selectedIndex = imagePickerIndex
                parentTabBar.shareButton.isHidden = false
                parentTabBar.countLabel.isHidden = false
            }
        }
    }
    
    func showBackAlert() {
        let alert = UIAlertController(title: "Info", message: "No camera available, you will be returned to the photo library", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.backToImagePicker()
        }))
        present(alert, animated: true)
    }
    
    func showCameraAlert(_ position: AVCaptureDevice.Position) {
        var positionString = ""
        if position == .back {
            positionString = "back"
        } else {
            positionString = "front"
        }
        let alert = UIAlertController(title: "Info", message: "No \(positionString) camera available, camera will be switched", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    //MARK: - AVCapturePhotoCaptureDelegate
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        let imageData = photo.fileDataRepresentation()
        guard let dataImage = imageData else {
            return
        }
        guard let image = UIImage(data: dataImage) else {
            return
        }

        print(image.size)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        let vc = CameraImageViewController(presentImage: image)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


