//
//  LoadingCell.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 2/13/20.
//  Copyright © 2020 Dumbies. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {
    
    var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.color = .systemBlue
        return spinner
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        sharedInit()
    }
    
    private func sharedInit() {
        addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        spinner.topAnchor.constraint(equalTo: topAnchor, constant: 24).isActive = true
        spinner.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
