//
//  SwitchCell.swift
//  PhotoSharer
//
//  Created by Serhii Ostrovetskyi on 8/27/19.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit
import SnapKit

class SwitchCell: UITableViewCell {
    
    let cellSwitch = UISwitch()
    let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        constructor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        constructor()
    }
    
    func constructor() {
        let container = UIView()
        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        container.addSubview(cellSwitch)
        cellSwitch.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(10)
        }
        
        contentView.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

}
