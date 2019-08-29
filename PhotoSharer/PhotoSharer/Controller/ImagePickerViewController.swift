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

class ImagePickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, Sharer {
    
    var sideSize: CGFloat = 80
    var collectionView: UICollectionView!
    let imageButton = UIButton()
    let activityData = ActivityData()
    var noPhotoImage = #imageLiteral(resourceName: "noPhoto")
    var currentImage = UIImage()
    var currentImageIndexPath: IndexPath?
    var small = true
    var currentImageisActual = false
    
    var tabBarHeight: CGFloat {
        return tabBarController?.tabBar.frame.height ?? 0
    }
    
    
    fileprivate var assets: PHFetchResult<AnyObject>?
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentImage = noPhotoImage
        view.backgroundColor = .lightGray
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImagePickerCell.self, forCellWithReuseIdentifier: "ImagePickerCell")
        collectionView.backgroundColor = .gray
        imageButton.contentMode = .scaleAspectFit
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
            make.height.equalTo((view.frame.height / 2 ) - 40)
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
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .authorized:
                    self.reloadAssets()
                default:
                    self.showNeedAccessMessage()
                }
            }
        }
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        upSwipe.direction = .up
        downSwipe.direction = .down
        
        imageButton.addGestureRecognizer(leftSwipe)
        imageButton.addGestureRecognizer(rightSwipe)
        imageButton.addGestureRecognizer(upSwipe)
        imageButton.addGestureRecognizer(downSwipe)
        imageButton.adjustsImageWhenHighlighted = false
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case .up:
            guard !small else {
                return
            }
            imageButtonTap()
            break
        case .down:
            guard small else {
                return
            }
            imageButtonTap()
            break
        case .left,
             .right:
            guard !small else {
                return
            }
            
            guard let indexPath = currentImageIndexPath else {
                return
            }
            
            let preCell = collectionView.cellForItem(at: indexPath)
            preCell?.contentView.layer.borderColor = UIColor.black.cgColor
            
            var newIndexPath = indexPath
            
            if (sender.direction == .left) {
                if indexPath.row < (collectionView.numberOfItems(inSection: 0) - 1) {
                    newIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
                }
                print("Swipe Left")
            }
            
            if (sender.direction == .right) {
                if indexPath.row > 0 {
                    newIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
                }
                print("Swipe Right")
            }
            collectionView.cellForItem(at: newIndexPath)?.contentView.layer.borderColor = UIColor.white.cgColor
            currentImageIndexPath = newIndexPath
            
            if newIndexPath != indexPath {
                setImageWithAnimate(for: newIndexPath, to: sender.direction)
            }
            break
        default:
            break
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sideSize = min((view.frame.width / 3) - 20, 100)
        print(sideSize)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    // MARK: - Actions
    
    @objc func imageButtonTap() {
        if small {
            imageButton.snp.updateConstraints { (update) in
                update.height.equalTo(view.frame.height - tabBarHeight)
            }
        } else {
            imageButton.snp.updateConstraints { (update) in
                update.height.equalTo((view.frame.height / 2) - 40)
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        small = !small
    }
    
    func showNeedAccessMessage() {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        })
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            (_) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        })
        showAlertWith(title: "Image picker", message: "App need get access to photos", actions: [cancelAction, okAction])
    }
    
    
    func showAlertWith(title: String, message: String, actions: [UIAlertAction] = []) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if actions.count == 0 {
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        } else {
            for action in actions {
                alert.addAction(action)
            }
        }
        present(alert, animated: true)
    }
    
    func fetchOptions() ->  PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        return options
    }
    
    func setImageWithAnimate(for indexPath: IndexPath, to direction: UISwipeGestureRecognizer.Direction) {
        guard let indexPath = currentImageIndexPath else {
            return
        }
        
        print(indexPath.row)
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(self.activityData, nil)
            PHImageManager.default().requestImage(for: self.assets?[indexPath.row] as! PHAsset, targetSize: CGSize(width: self.view.frame.width, height: self.view.frame.height), contentMode: .aspectFit, options: self.requestOptions()) { (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                var newImage: UIImage
                if image == nil {
                    newImage = self.noPhotoImage
                    self.currentImageisActual = false
                } else {
                    newImage = image!
                    self.currentImageisActual = true
                }
                self.nextImageAnimationFor(newImage, to: direction)
            }
        }
    }
    
    func nextImageAnimationFor(_ image: UIImage, to direction: UISwipeGestureRecognizer.Direction) {
        var pathLength: CGFloat = 0
        
        if direction == .left {
            pathLength = -self.view.frame.width
        } else {
            pathLength = self.view.frame.width
        }
        
        let imageFrame = self.imageButton.frame
        
        let currentImageButton = UIButton()
        let nextImageButton = UIButton()
        
        currentImageButton.frame = imageFrame
        nextImageButton.frame = CGRect(x: imageFrame.minX - pathLength, y: imageFrame.origin.y, width: imageFrame.width, height: imageFrame.height)
        
        currentImageButton.setImage(self.currentImage, for: .normal)
        nextImageButton.setImage(image, for: .normal)
        
        self.view.addSubview(nextImageButton)
        self.view.addSubview(currentImageButton)
        
        currentImageButton.backgroundColor = .clear
        nextImageButton.backgroundColor = .clear
        
        currentImageButton.layer.borderWidth = 1
        nextImageButton.layer.borderWidth = 1
        
        currentImageButton.contentMode = .scaleAspectFit
        nextImageButton.contentMode = .scaleAspectFit
        
        currentImageButton.imageView?.contentMode = .scaleAspectFit
        nextImageButton.imageView?.contentMode = .scaleAspectFit
        
        currentImageButton.adjustsImageWhenHighlighted = false
        nextImageButton.adjustsImageWhenHighlighted = false
        
        self.imageButton.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            currentImageButton.transform = currentImageButton.transform.translatedBy(x: pathLength, y: 0)
            nextImageButton.transform = nextImageButton.transform.translatedBy(x: pathLength, y: 0)
            self.imageButton.setImage(image, for: .normal)
            self.currentImage = image
        }, completion: { (_) in
            self.imageButton.alpha = 1
            currentImageButton.removeFromSuperview()
            nextImageButton.removeFromSuperview()
        })
    }
    
    func reloadAssets() {
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(self.activityData, nil)
            self.assets = nil
            self.assets = (PHAsset.fetchAssets(with: PHAssetMediaType.image, options: self.fetchOptions()) as! PHFetchResult<AnyObject>)
            
            self.collectionView.reloadData()
            self.collectionView.contentOffset = CGPoint(x: 0, y: 0)
            PHImageManager.default().requestImage(for: self.assets?[0] as! PHAsset, targetSize: CGSize(width: self.view.frame.width, height: self.view.frame.height), contentMode: .aspectFit, options: self.requestOptions()) { (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                var newImage: UIImage
                if image == nil {
                    newImage = self.noPhotoImage
                    self.currentImageisActual = false
                } else {
                    newImage = image!
                    self.currentImageisActual = true
                }
                self.imageButton.setImage(newImage, for: .normal)
                self.currentImage = newImage
                self.currentImageIndexPath = IndexPath(row: 0, section: 0)
                print(self.currentImageIndexPath ?? "N/A")
                print(self.currentImage)
                
            }
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
        PHImageManager.default().requestImage(for: assets?[indexPath.row] as! PHAsset, targetSize: CGSize(width: sideSize, height: sideSize), contentMode: .aspectFit, options: self.requestOptions()) { (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
            var newImage: UIImage
            if image == nil {
                newImage = self.noPhotoImage
            } else {
                newImage = image!
            }
            DispatchQueue.main.async {
                guard let imageCell = cell as? ImagePickerCell else {
                    return
                }
                if indexPath == self.currentImageIndexPath {
                    imageCell.contentView.layer.borderColor = UIColor.white.cgColor
                } else {
                    imageCell.contentView.layer.borderColor = UIColor.black.cgColor
                }
                imageCell.backgroundColor = .lightGray
                imageCell.contentMode = .scaleAspectFit
                imageCell.image = newImage
            }
        }
    }
    
    private func requestOptions() -> PHImageRequestOptions {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        return requestOptions
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let currentIndexPath = currentImageIndexPath {
            let preCell = collectionView.cellForItem(at: currentIndexPath)
            preCell?.contentView.layer.borderColor = UIColor.black.cgColor
        }
        currentImageIndexPath = indexPath
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.2,
                       animations: {
                        cell?.alpha = 0.5
                        cell?.contentView.layer.borderColor = UIColor.white.cgColor
        }) { (_) in
            UIView.animate(withDuration: 0.2,
                           animations: {
                            cell?.alpha = 1
            })
        }
        
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
        
        PHImageManager.default().requestImage(for: assets?[indexPath.row] as! PHAsset, targetSize: CGSize(width: view.frame.width, height: view.frame.height), contentMode: .aspectFit, options: self.requestOptions()) { (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            DispatchQueue.main.async {
                var newImage: UIImage
                if image == nil {
                    newImage = self.noPhotoImage
                    self.currentImageisActual = false
                } else {
                    newImage = image!
                    self.currentImageisActual = true
                }
                self.imageButton.setImage(newImage, for: .normal)
                self.currentImage = newImage
                self.currentImageIndexPath = indexPath
                print(self.currentImageIndexPath ?? "N/A")
                print(self.currentImage)
            }
            
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: sideSize, height: sideSize)
    }
    
    // MARK: - Sharer
    
    func share() {
        guard currentImageisActual else {
            showAlertWith(title: "Info", message: "Failed to upload photo")
            return
        }
        let sharer = ShareViewController(shareImage: currentImage)
        navigationController?.pushViewController(sharer, animated: true)
    }
    
}

