//
//  ShareViewController.swift
//  PhotoSharer
//
//  Created by Serhii Ostrovetskyi on 8/27/19.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit
import SnapKit
import TwitterKit
import FacebookShare

class ShareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Sharer {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = items[section]
        switch item {
        case .photo,
             .description:
            return 1
        case .share:
            return socials.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        switch item {
        case .photo:
            let cell = UITableViewCell()
            cell.imageView?.image = shareImage
            cell.tag = 999
            return cell
        case .description:
            let cell = tableView.dequeueReusableCell(withIdentifier: textViewCellIdentifier) as! TextViewCell
            return cell
        case .share:
            let social = socials[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: switchCellIdentifier) as! SwitchCell
            cell.titleLabel.text = social.rawValue
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let item = items[section]
        return item.rawValue
    }
    
    enum item: String {
        case photo = "Photo"
        case description = "Description"
        case share = "Share"
    }
    
    enum social: String {
        case facebook = "Facebook"
        case twitter = "Twitter"
    }
    
    var items: [item] = [.photo, .description, .share]
    var socials: [social] = [.facebook, .twitter]
    var shareTo: [Bool] = []
    
    let switchCellIdentifier = "SwitchCell"
    let textViewCellIdentifier = "TextViewCell"
    
    var shareImage: UIImage
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    init(shareImage: UIImage) {
        self.shareImage = shareImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        setupTableView()
        let shareButton = UIButton(type: .system)
        shareButton.addTarget(self, action: #selector(shareButtonTap), for: .touchUpInside)
        shareButton.setTitle("Share", for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SwitchCell.self, forCellReuseIdentifier: switchCellIdentifier)
        tableView.register(TextViewCell.self, forCellReuseIdentifier: textViewCellIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 40
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func checkSelections() {
        shareTo = []
        for i in 0..<socials.count {
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: items.firstIndex(of: .share)!)) as! SwitchCell
            shareTo.append(cell.cellSwitch.isOn)
        }
    }
    
    @objc func shareButtonTap() {
        checkSelections()
        guard shareTo.contains(true) else {
            return
        }
        share()
    }
    
    func share() {
        print("Share")
        var descriptionText = ""
        if let descriptionCell = tableView.cellForRow(at: IndexPath(row: 0, section: items.firstIndex(of: .description) ?? 0)) as? TextViewCell {
            descriptionText = descriptionCell.textView.text
        }
        
        if shareTo[socials.firstIndex(of: .facebook)!] {
            var photo = Photo(image: shareImage, userGenerated: true)
            photo.caption = descriptionText
            var content = PhotoShareContent()
            content.photos.append(photo)
            let shareDialog = ShareDialog(content: content)
            shareDialog.mode = .automatic
            shareDialog.failsOnInvalidData = true
            shareDialog.completion = { result in
                switch result {
                    
                case .success(_):
                    break
                case .failed(_):
                    break
                case .cancelled:
                    break
                }
            }
            
            do {
                try shareDialog.show()
            } catch {
                print(error)
            }
            
            
        }
        if shareTo[socials.firstIndex(of: .twitter)!] {
            //        let composer = TWTRComposer()
            //        composer.setText(descriptionText)
            //        composer.setImage(shareImage)
            //
            //        composer.show(from: navigationController!) { (result) in
            //            switch result {
            //
            //            case .cancelled:
            //                print("Cancelled")
            //            case .done:
            //                print("Done")
            //            }
            //        }
        }
        
        if let tabBarVC = navigationController?.viewControllers.first(where: { (vc) -> Bool in
            return vc is TabBarViewController
        }) {
            navigationController?.popToViewController(tabBarVC, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let photoCell = tableView.cellForRow(at: indexPath), photoCell.tag == 999 {
            let presenter = PresentImageViewController(presentImage: photoCell.imageView?.image, autoDismiss: false)
            present(presenter, animated: true)
        }
        
    }

}
