//
//  ImagePickerViewController.swift
//  PhotoSharer
//
//  Created by Serhii Ostrovetskyi on 8/23/19.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit
import Photos
import SnapKit
import NVActivityIndicatorView

class ImagePickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var sideSize: CGFloat = 80
    var collectionView: UICollectionView!
    let imageButton = UIButton()
    let activityData = ActivityData()
    
    var currentImage: UIImage?
    
    var small = true

    fileprivate var assets: PHFetchResult<AnyObject>?
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImagePickerCell.self, forCellWithReuseIdentifier: "ImagePickerCell")
        collectionView.backgroundColor = .gray
        imageButton.imageView?.contentMode = .scaleAspectFit
        imageButton.addTarget(self, action: #selector(imageButtonTap), for: .touchUpInside)
        imageButton.layer.borderWidth = 1
        imageButton.backgroundColor = .lightGray
        view.addSubview(collectionView)
        view.addSubview(imageButton)
        imageButton.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(view.frame.height / 2)
        }
        
        
        collectionView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(bottomLayoutGuide.snp.top)
            }
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(imageButton.snp.bottom)
        }

        if PHPhotoLibrary.authorizationStatus() == .authorized {
            reloadAssets()
        } else {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                if status == .authorized {
                    self.reloadAssets()
                } else {
                    self.showNeedAccessMessage()
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sideSize = (view.frame.width / 3) - 20
    }

    // MARK: - Actions
    
    @objc func imageButtonTap() {
        if small {
            imageButton.snp.updateConstraints { (update) in
                update.height.equalTo(view.frame.height)
            }
        } else {
            imageButton.snp.updateConstraints { (update) in
                update.height.equalTo(view.frame.height / 2)
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        small = !small
    }
    
    fileprivate func showNeedAccessMessage() {
        let alert = UIAlertController(title: "Image picker", message: "App need get access to photos", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (_) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        show(alert, sender: nil)
    }
    
    fileprivate func reloadAssets() {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
        assets = nil
        assets = (PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil) as! PHFetchResult<AnyObject>)
        collectionView.reloadData()
        guard let _assets = assets, _assets.count > 0 else {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            return
        }
        PHImageManager.default().requestImageData(for: assets?[0] as! PHAsset, options: nil) { (_data, _string, orientation, _info) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            guard let data = _data else {
                return
            }
            guard let image = UIImage(data: data) else {
                return
            }
            self.imageButton.setImage(image, for: .normal)
            self.currentImage = image
        }
        
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let availableAssets = assets else {
            return 0
        }
        return availableAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePickerCell", for: indexPath)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        PHImageManager.default().requestImage(for: assets?[indexPath.row] as! PHAsset, targetSize: CGSize(width: sideSize, height: sideSize), contentMode: .aspectFill, options: nil) { (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
            (cell as! ImagePickerCell).image = image
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
        PHImageManager.default().requestImageData(for: assets?[indexPath.row] as! PHAsset, options: nil) { (_data, _string, orientation, _info) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            guard let data = _data else {
                return
            }
            guard let image = UIImage(data: data) else {
                return
            }
            self.imageButton.setImage(image, for: .normal)
            self.currentImage = image
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: sideSize, height: sideSize)
    }

}

