//
//  UserProfileHeader.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 11/24/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit

class UserProfileHeader: UICollectionViewCell {
    
    var user: User? {
        didSet {
           setupProfileImage()
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.layer.cornerRadius = 80 / 2
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    fileprivate func setupProfileImage() {
        guard let profileImageUrl = user?.profileImageUrl else { return }
        guard let url = URL(string: profileImageUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let error = err {
                print("Failed to fetch profile image:", error)
                return
            }
            
            guard let data = data else { return }
            let image = UIImage(data: data)

            DispatchQueue.main.async {
                self.profileImageView.image = image
            }

        }.resume()
    }
}
