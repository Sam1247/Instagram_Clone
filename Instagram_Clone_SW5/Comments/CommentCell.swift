//
//  CommentCell.swift
//  Instagram_Clone_SW5
//
//  Created by Abdalla Elsaman on 1/24/20.
//  Copyright © 2020 Dumbies. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            let attributedText = NSMutableAttributedString(string: comment.user.username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.label])
            attributedText.append(NSAttributedString(string: " " + comment.text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]))

            CommentLabel.attributedText = attributedText
            profileImageView.loadImage(urlString: comment.user.profileImageUrl)
        }
    }
    
    let bubbleBackgroundView = UIView()
    
    let CommentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

     required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupConstraints()
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        //iv.backgroundColor = .blue
        return iv
    }()
    
    func setupConstraints() {
        backgroundColor = .clear
        addSubview(bubbleBackgroundView)
        addSubview(CommentLabel)
        addSubview(profileImageView)
        bubbleBackgroundView.layer.cornerRadius = 12
        profileImageView.layer.cornerRadius = 36/2
        CommentLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 16, paddingLeft: 32 + 24, paddingBottom: 16, paddingRight: 0, width: 0, height: 0)
        CommentLabel.widthAnchor.constraint(lessThanOrEqualToConstant: frame.width - 36 - 36).isActive = true
        bubbleBackgroundView.anchor(top: CommentLabel.topAnchor, left: CommentLabel.leftAnchor, bottom: CommentLabel.bottomAnchor, right: CommentLabel.rightAnchor, paddingTop: -8, paddingLeft: -8, paddingBottom: -8, paddingRight: -8, width: 0, height: 0)
        
        profileImageView.anchor(top: bubbleBackgroundView.topAnchor, left: nil, bottom: nil, right: bubbleBackgroundView.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 6, width: 36, height: 36)
        bubbleBackgroundView.backgroundColor = .tertiarySystemBackground
    }

    
    
}

//class CommentCell: UICollectionViewCell {
//
//    var comment: Comment? {
//        didSet {
//            guard let comment = comment else { return }
//
//            let attributedText = NSMutableAttributedString(string: comment.user.username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.label])
//            attributedText.append(NSAttributedString(string: " " + comment.text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]))
//
//            textView.attributedText = attributedText
//            profileImageView.loadImage(urlString: comment.user.profileImageUrl)
//        }
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        sharedInit()
//    }
//
//     required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        sharedInit()
//    }
//
//    private func sharedInit() {
//        addSubview(profileImageView)
//        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
//        profileImageView.layer.cornerRadius = 40 / 2
//
//         addSubview(textView)
//        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
//    }
//
//    let textView: UITextView = {
//        let textView = UITextView()
//        textView.backgroundColor = .tertiarySystemBackground
//        textView.layer.cornerRadius = 12
//        textView.font = UIFont.systemFont(ofSize: 14)
//        textView.isScrollEnabled = false
//        return textView
//    }()
//
//     let profileImageView: CustomImageView = {
//        let iv = CustomImageView()
//        iv.clipsToBounds = true
//        iv.contentMode = .scaleAspectFill
//        iv.backgroundColor = .blue
//        return iv
//    }()
//}
